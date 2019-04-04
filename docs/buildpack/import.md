# Import Existing Project

## Tip

As we will have to edit `yaml` files, I can recommend using a commandline yaml editor.
One such is [mikefarah's yq](https://github.com/mikefarah/yq).

```bash tab="Snap"
snap install yq
```

```bash tab="Homebrew"
brew install yq
```

Another tip, for testing URL's, instead of using CURL, I would recommend [HTTPie](https://httpie.org/).

```bash tab="Debian based"
apt-get install httpie
```

```bash tab="RHEL based"
yum install httpie
```

```bash tab="Homebrew"
brew install httpie
```

```bash tab="Windows via Python"
pip install --upgrade pip setuptools
pip install --upgrade httpie
```

## Config

Replace `?` with your GitHub user where you will be working from.

```bash
GH_USER=?
```

## Fork example project

Fork [github.com/demomon/jx-micronaut-seed](https://github.com/demomon/jx-micronaut-seed) as a start.

And then checkout your version of the project and go into the project's directory.

```bash tab="SSH"
git clone git@github.com:${GH_USER}/jx-micronaut-seed.git \
    && cd jx-micronaut-seed
```

```bash tab="https"
git clone https://github.com/${GH_USER}/jx-micronaut-seed.git \
    && cd jx-micronaut-seed
```

## Import in JX

!!! Info
    When in doubt, accept the defaults of the prompts asking questions.

```bash
jx import
```

You should see, among other things, the following logs.

```bash hl_lines="1"
selected pack: /Users/joostvdg/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/gradle
replacing placeholders in directory /Users/joostvdg/Projects/Personal/Github/jx-micronaut-seed
app name: jx-micronaut-seed, git server: github.com, org: joostvdg, Docker registry org: joostvdg
```

Jenkins X - via Draft - automatically detected this application is being build with `Gradle`.
As you can see in the highlighted section in the code snippet above.

## Confirm the application is building

The application will fail to build, as the default `Dockerfile` is not correct.

Use the below code to replace the Dockerfile.

```Dockerfile
FROM openjdk:8u171-alpine3.7
RUN apk --no-cache add curl
COPY build/libs/*-all.jar complete.jar
CMD java ${JAVA_OPTS} -jar complete.jar
```

Commit your change and watch the activity.

```bash
git add Dockerfile
git commit -m "fix Dockerfile"
git push
jx get activity -f jx-micronaut-seed -w
```

Once the `Promote: staging` is completed successfully, we should be able to test if the application is running!

```bash
APP_ADDR=$(kubectl get ing -n jx-staging jx-micronaut-seed -o jsonpath="{.spec.rules[0].host}")
curl "http://$APP_ADDR"
```

You should see something like this:

```html
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.15.8</center>
</body>
</html>
```

Something is wrong...

## Find out what is wrong

To find out what is wrong, lets check the pod status.

```bash
kubectl get pods -n jx-staging -l app=jx-jx-micronaut-seed
```

We should see something as follows.

```bash
NAME                                    READY   STATUS             RESTARTS   AGE
jx-jx-micronaut-seed-68f4bffb7b-mpb57   0/1     CrashLoopBackOff   41         1h
```

Let's describe the pod and see what is causing the `CrashLoopBackOff`.

```bash
kubectl describe pods -n jx-staging -l app=jx-jx-micronaut-seed
```

If we look at the `Events:` section, we will see something like this:

```bash
Events:
  Type     Reason     Age                     From                                              Message
  ----     ------     ----                    ----                                              -------
  Warning  Unhealthy  13m (x1833 over 16h)    kubelet, gke-joostvdg-default-pool-6f512cf8-7l4l  Readiness probe failed: HTTP probe failed with statuscode: 404
  Normal   Pulled     8m43s (x240 over 16h)   kubelet, gke-joostvdg-default-pool-6f512cf8-7l4l  Container image "10.23.250.118:5000/joostvdg/jx-micronaut-seed:0.0.3" already present on machine
  Warning  BackOff    3m34s (x2866 over 16h)  kubelet, gke-joostvdg-default-pool-6f512cf8-7l4l  Back-off restarting failed container
```

One of the things you can spot, is `Readiness probe failed: HTTP probe failed with statuscode: 404`.

Assuming our application is ***flawless*** - it passed it build & test phase - it's likely that Kubernetes is looking at a non-existing endpoint for a health check.

## Fix Health Check

As good as ***Jenkins X*** is, it isn't clairvoyant and cannot detect that our Micronaut application has a different health check endpoint.

You might not know what the ***Micronaut*** framework gives you, but I can tell you. The health check endpoint is located at `/health`, not a bad place to put it.

As the Gradle **BuildPack** is designed with ***Spring Boot*** in mind, it directs Kubernetes health check to `/actuator/health`.
So we have to change this.

Our application is packaged by ***Helm*** and the values for our Kubernetes ***Deployment*** - where the health check is configured - are located in `/charts/jx-micronaut-seed/values.yaml`.

We have to change the value of `probePath`, from `/actuator/health` to `/health`.
So please edit `/charts/jx-micronaut-seed/values.yaml` to reflect the change or use the below `yq` command.
This should be the end result:

```YAML hl_lines="7"
...
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 400m
    memory: 512Mi
probePath: /health
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
...
```

```bash tab="yq"
yq w charts/jx-micronaut-seed/values.yaml --inplace probePath /health
```

Now commit and push our change to fix our deployment!

```bash
git add charts/jx-micronaut-seed/values.yaml
git commit -m "fix health check endpoint"
git push
jx get activity -f jx-micronaut-seed -w
```

Once the applications is successfully promoted to staging, we can try again!

```bash
kubectl get pods -n jx-staging -l app=jx-jx-micronaut-seed
```

Oh no, the application is still not running!

```bash
NAME                                   READY   STATUS    RESTARTS   AGE
jx-jx-micronaut-seed-d5498679f-55b84   0/1     Running   1          2m
```

## Still broken

Let's describe the pod and see what is wrong this time.

```bash
kubectl describe pods -n jx-staging -l app=jx-jx-micronaut-seed
```

```bash
Warning  Unhealthy  94s (x2 over 3m14s)   kubelet, gke-joostvdg-default-pool-6f512cf8-41l4  Readiness probe failed: Get http://10.20.0.24:8080/health: dial tcp 10.20.0.24:8080: connect: connection refused
  Warning  Unhealthy  83s (x2 over 3m3s)    kubelet, gke-joostvdg-default-pool-6f512cf8-41l4  Readiness probe failed: Get http://10.20.0.24:8080/health: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
  Warning  Unhealthy  54s (x11 over 2m54s)  kubelet, gke-joostvdg-default-pool-6f512cf8-41l4  Readiness probe failed: HTTP probe failed with statuscode: 500
```

It seems our application is not getting into ready state: `Readiness probe failed: HTTP probe failed with statuscode: 500`.

Now this is a bit of cheat, because this application actually requires a connection with a **Redis** database in order to function. It can be build without it fine, and it will run fine, but ***Micronaut***'s health check endpoint will incorporate the Redis connection into it's health status.

## Configure Redis database

This means we must make sure our application can talk to a Redis database!

### Add Redis dependency

The easiest way to do this with ***Jenkins X***, is to add a dependency to our ***Helm Chart***. If our dependency exists as a health chart, that is.

Just our luck, looking at [Helm Stable Charts](https://github.com/helm/charts/tree/master/stable), there's a [Redis](https://github.com/helm/charts/tree/master/stable/redis) chart we can add.

To do so, we add a `requirements.yaml` to our Chart.

Create a file `charts/jx-micronaut-seed/requirements.yaml` and fill in the below details.

```YAML tab="Raw YAML"
dependencies:
- alias: jx-micronaut-seed-redis
  name: redis
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 6.1.0
```

```bash tab="CommandLine magic"
echo "dependencies:
- alias: jx-micronaut-seed-redis
  name: redis
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 6.1.0
" | tee charts/jx-micronaut-seed/requirements.yaml
```

### Application Redis config

To be safe that whenever our application gets deployed via ***Helm*** it can find our database, we need to make sure the location it looks for is a variable.

We can add this in three places, either in the application itself, in our `values.yaml` or in our `deployment.yaml` template.
Our application will get deployed via Helm, which means the name it gets and the Redis dependency gets, will depend on the Helm release name.

So in ***this*** particular case, it's best to add an environment variable to the deployment template.
With a default value, that derives its value from the Helm release name.

This makes the default install from Helm work and allows users of our Helm chart, to use a different Redis instance.

To do so, we have to add the environment variable in `charts/jx-micronaut-seed/templates/deployment.yaml`.

Add the below snippet to the `spec.template.spec.containers[0]` section between `imagePullPolicy: {{ .Values.image.pullPolicy }}` and `ports:`.

```yaml
env:
    - name: REDIS_HOST
    value: {{ template "fullname" . }}-redis-master
```

The end result should look like this:

```yaml hl_lines="6 7 8"
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
          - name: REDIS_HOST
            value: {{ template "fullname" . }}-redis-master
        ports:
```

### Redis Chart config

We need to do one last thing.
The Redis chart by default generates a unique password on startup.

This is nice and secure, but makes it difficult for our application to connect to it.
Let's configure our Redis chart to not use a password for now.

Add the below snippet at the bottom of `charts/jx-micronaut-seed/values.yaml` or use the command line magic for automation.

```yaml tab="Raw YAML"
jx-micronaut-seed-redis:
  usePassword: false
```

```bash tab="Command Line magic"
echo "jx-micronaut-seed-redis:
  usePassword: false
" | tee -a charts/jx-micronaut-seed/values.yaml
```

### Commit and confirm

Let's commit and push our changes and see if this was enough!

```bash
git add charts/jx-micronaut-seed/templates/deployment.yaml
git add charts/jx-micronaut-seed/values.yaml
git add charts/jx-micronaut-seed/requirements.yaml
git commit -m "add and configure redis dependency"
git push
jx get activity -f jx-micronaut-seed -w
```

## Confirm it works

Once it succeeds, we can see if the applications does run now.

```bash
kubectl get pods -n jx-staging -l app=jx-jx-micronaut-seed
```

It should now be running:

```bash
NAME                                    READY   STATUS    RESTARTS   AGE
jx-jx-micronaut-seed-75ffd4fbc4-66sgr   1/1     Running   0          9m
```

Let's see if we can talk to it.

```bash tab="curl"
APP_ADDR=$(kubectl get ing -n jx-staging jx-micronaut-seed -o jsonpath="{.spec.rules[0].host}")
curl "http://$APP_ADDR/health"
```

```bash tab="httpie"
APP_ADDR=$(kubectl get ing -n jx-staging jx-micronaut-seed -o jsonpath="{.spec.rules[0].host}")
http "$APP_ADDR/health"
```

The answer is:

```json
{
  "status": "UP"
}
```

We've done it!

Now lets use the Redis database in a wholefully inappropriate way.

```bash tab="curl"
APP_ADDR=$(kubectl get ing -n jx-staging jx-micronaut-seed -o jsonpath="{.spec.rules[0].host}")
curl --header "Content-Type: application/json" \
  --request POST --data '{"body":"Something curl","sender":"Joost"}' \
  "http://$APP_ADDR/message"
curl "http://$APP_ADDR/message"
```

```bash tab="httpie"
APP_ADDR=$(kubectl get ing -n jx-staging jx-micronaut-seed -o jsonpath="{.spec.rules[0].host}")
http POST ${APP_ADDR}/message body="Something httpie" sender="Joost"
http ${APP_ADDR}/message
```

Now, in order to avoid having to this kind of ritual for every Micronaut based application, we should probably make a better starting point. Let's move on to create a [BuildPack](/docs/buildpack/)
