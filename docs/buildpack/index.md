# BuildPack notes

* location of jx default packs: https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes
* location of local ones we can edit: ~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes

## Copy existing

First, make a fork of `https://github.com/$GH_USER/jenkins-x-kubernetes` in your own repo.

```bash
GH_USER=?
```

```bash
git clone https://github.com/$GH_USER/jenkins-x-kubernetes
cd jenkins-x-kubernetes
```

Confirm the packs are there:

```bash
ls -1 packs
```

Let's look at the Gradle one - the one closest to what we need.

```bash
ls -1 packs/gradle
```

```bash
cp -R packs/gradle packs/micronaut-gradle-redis
```

```bash
ls -1 packs/micronaut-gradle-redis
```

## Fix Dockerfile

```Dockerfile tab="Raw Dockerfile"
FROM openjdk:8u171-alpine3.7
RUN apk --no-cache add curl
COPY build/libs/*-all.jar complete.jar
CMD java ${JAVA_OPTS} -jar complete.jar
```

```bash tab="CommandLine magic"
rm packs/micronaut-gradle-redis/Dockerfile
echo "FROM openjdk:8u171-alpine3.7
RUN apk --no-cache add curl
COPY build/libs/*-all.jar complete.jar
CMD java ${JAVA_OPTS} -jar complete.jar" | tee packs/micronaut-gradle-redis/Dockerfile
```

## Fix health check

We have to change the value of `probePath`, from `/actuator/health` to `/health`.
So please edit `packs/micronaut-gradle-redis/charts/values.yaml` to reflect the change or use the below `yq` command.


```bash tab="yq"
yq w packs/micronaut-gradle-redis/charts/values.yaml --inplace probePath /health
```

## Configure Redis

### deployment.yaml

`packs/micronaut-gradle-redis/charts/templates/deployment.yaml`

```yaml tab="Raw YAML"
env:
  - name: REDIS_HOST
    value: {{ template "fullname" . }}-redis-master
```

```bash tab="Command Line magic"
cat packs/micronaut-gradle-redis/charts/templates/deployment.yaml | sed -e \
    's@env:@env:\
        - name: REDIS_HOST\
          value: {{ template "fullname" . }}-redis-master@g' \
    | tee packs/micronaut-gradle-redis/charts/templates/deployment.yaml
```

### values.yaml

```yaml tab="Raw YAML"
REPLACE_ME_APP_NAME-redis:
  usePassword: false
```

```bash tab="CommandLine Magic"
echo "REPLACE_ME_APP_NAME-redis:
  usePassword: false
" | tee -a packs/micronaut-gradle-redis/charts/values.yaml
```

### requirements.yaml

`packs/micronaut-gradle-redis/charts/requirements.yaml`

!!! Warning
    Please note the usage of the **REPLACE_ME_APP_NAME** string. 
    Today (April 2019), that is still one of the features that are not documented. When the build pack is applied, it'll replace that string with the actual name of the application. After all, it would be silly to hard-code the name of the application since this pack should be reusable across many.

```YAML tab="Raw YAML"
dependencies:
- alias: REPLACE_ME_APP_NAME-redis
  name: redis
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 6.1.0
```

```bash tab="CommandLine magic"
echo "dependencies:
- alias: REPLACE_ME_APP_NAME-redis
  name: redis
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 6.1.0
" | tee packs/micronaut-gradle-redis/charts/requirements.yaml
```

### Preview requirements

`packs/micronaut-gradle-redis/preview/requirements.yaml`

!!! Info
    The file states:
    > "alias: preview" must be last entry in dependencies array 
    > Place custom dependencies above

We will have to change the file to include our Redis requirement.

Which means, this part:

```yaml
  # !! "alias: preview" must be last entry in dependencies array !!
  # !! Place custom dependencies above !!
- alias: preview
  name: REPLACE_ME_APP_NAME
  repository: file://../REPLACE_ME_APP_NAME
```

Should look like:

```yaml tab="Expected End Result"
- alias: preview-redis
  name: REPLACE_ME_APP_NAME-redis
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 6.1.0

  # !! "alias: preview" must be last entry in dependencies array !!
  # !! Place custom dependencies above !!
- alias: preview
  name: REPLACE_ME_APP_NAME
  repository: file://../REPLACE_ME_APP_NAME
```

```bash tab="CommandLine Magic"
cat packs/micronaut-gradle-redis/preview/requirements.yaml \
    | sed -e \
    's@  # !! "alias@- name: REPLACE_ME_APP_NAME-redis\
  alias: preview-redis\
  version: 6.1.0\
  repository:  https://kubernetes-charts.storage.googleapis.com\
\
  # !! "alias@g' \
    | tee packs/micronaut-gradle-redis/preview/requirements.yaml

echo '
' | tee -a packs/micronaut-gradle-redis/preview/requirements.yaml
```

## Commit and go

```
git add .

git commit -m "Added micronaut-gradle-redis build pack"

git push
```

### Add to known buildpacks

With the new build pack safely stored, we should let Jenkins X know that we want to use the forked repository.

We can use `jx edit buildpack` to change the location of our `kubernetes-workloads` packs. However, at the time of this writing (February 2019), there is a bug that prevents us from doing that ([issue 2955](https://github.com/jenkins-x/jx/issues/2955)). The good news is that there is a workaround. If we omit the name (`-n` or `--name`), Jenkins X will add the new packs location, instead of editing the one dedicated to `kubernetes-workloads` packs.

```bash
jx edit buildpack \
    -u https://github.com/$GH_USER/jenkins-x-kubernetes \
    -r master \
    -b
```

## Test new BuildPack

* make sure we're back at jx-micronaut-seed project
* lets reset it

### Reset application

```bash
git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push
```

### Remove application from Jenkins X

Removes the application from Jenkins X.

```bash
jx delete application $GH_USER/jx-micronaut-seed -b
```

And the following removes the activities of the application from Kubernetes.

```bash
kubectl -n jx delete act -l owner=$GH_USER \
  -l sourcerepository=$GH_USER-jx-micronaut-seed
```

## Import

```bash
jx import --pack micronaut-gradle-redis -b

ls -1 \
  ~/.jx/draft/packs/github.com/$GH_USER/jenkins-x-kubernetes/packs
```

!!! Info
    If you run into the problem that the build fails,
    because the Helm Chart already exists in Chartmuseum:
    `Received 409 response: {"error":"file already exists"}`.
    You can solve this by creating and pushing git tag with a higher version via `jx` binary.
    
    ```bash
    jx step tag --version 0.2.0
    git push
    ```

!!! Info
    For more information on how to version your application,
    please consult [Jenkins X's jx-release-version tool](https://github.com/jenkins-x/jx-release-version).
    Or read [CloudBees' blog on automatic versioning](https://www.cloudbees.com/blog/automatically-versioning-your-application-jenkins-x).

### Confirm it works

Let's watch the activity stream, to see when our application lands in staging.

```bash
jx get activity -f jx-micronaut-seed -w
```

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
