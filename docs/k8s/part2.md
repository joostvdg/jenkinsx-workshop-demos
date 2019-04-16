# Kubernetes Basics - Parts II

!!! Info
    This workshop segment expect you to be inside a cloned repository of `k8s-specs`.

    ```bash
    git clone https://github.com/vfarcic/k8s-specs.git
    cd k8s-specs
    ```

## Points to cover

* Using ConfigMaps To Inject Configuration Files
* Using Secrets To Hide Confidential Information
* Dividing A Cluster Into Namespaces
* Securing Kubernetes Clusters
* Managing Resources

## ConfigMap

### Create from files

```bash
kubectl create cm my-config --from-file=cm/prometheus-conf.yml \
    --from-file=cm/prometheus.yml
```

```bash
cat cm/alpine.yml
```

```bash
kubectl create -f cm/alpine.yml
```

```bash
kubectl exec -it alpine -- ls /etc/config
```

```bash
kubectl exec -it alpine -- cat /etc/config/prometheus-conf.yml
```

```bash
kubectl delete -f cm/alpine.yml
```

```bash
kubectl delete cm my-config
```

### Create from literals

```bash
kubectl create cm my-config \
    --from-literal=something=else --from-literal=weather=sunny
```

```bash
kubectl create -f cm/alpine.yml
```

```bash
kubectl exec -it alpine -- ls /etc/config
```

```bash
kubectl exec -it alpine -- cat /etc/config/something
```

```bash
kubectl delete -f cm/alpine.yml
```

```bash
kubectl delete cm my-config
```

### Create from environment files

```bash
cat cm/my-env-file.yml
```

```bash
kubectl create cm my-config --from-env-file=cm/my-env-file.yml
```

```bash
kubectl get cm my-config -o yaml
```

## Secrets

### Generic secrets

```bash
kubectl create secret generic my-creds \
    --from-literal=username=jdoe --from-literal=password=incognito
```

```bash
kubectl get secrets
```

```bash
kubectl get secret my-creds -o json
```

```bash
kubectl get secret my-creds -o jsonpath="{.data.username}" \
    | base64 --decode
```

```bash
kubectl get secret my-creds -o jsonpath="{.data.password}" \
    | base64 --decode
```

```bash
cat secret/jenkins.yml
```

```bash
kubectl apply -f secret/jenkins.yml
```

```bash
kubectl rollout status deploy jenkins
```

```bash
POD_NAME=$(kubectl get pods -l service=jenkins,type=master \
    -o jsonpath="{.items[*].metadata.name}")
```

```bash
kubectl exec -it $POD_NAME -- ls /etc/secrets
```

```bash
kubectl exec -it $POD_NAME -- cat /etc/secrets/jenkins-user
```

```bash
IP=$(minikube ip) # If minikube
```

```bash
open "http://$IP/jenkins"
```

### Cleanup

```bash
kubectl delete -f secret/jenkins.yml

kubectl delete secret my-creds
```

## Namespaces

### Create initial release

```bash
cat ns/go-demo-2.yml
```

```bash
IMG=vfarcic/go-demo-2
TAG=1.0
```

```bash
cat ns/go-demo-2.yml | sed -e "s@image: $IMG@image: $IMG:$TAG@g" \
    | kubectl create -f -
```

```bash
kubectl rollout status deploy go-demo-2-api
```

### Retrieve existing Namespaces

```bash tab="Shorthand way"
kubectl get ns
```

```bash tab="Verbose way"
kubectl get namespaces
```

### Explore existing namespaces

```bash
kubectl -n kube-public get all
```

```bash
kubectl -n kube-system get all
```

```bash
kubectl -n default get all
```

```bash
kubectl get all
```

### Create new namespace

```bash
kubectl create ns testing

kubectl get ns
```

### Change default namespace

```bash tab="JX"
jx ns testing
```

```bash tab="Kubectx"
kubens testing
```

```bash tab="GKE"
DEFAULT_CONTEXT=$(kubectl config current-context)
kubectl config set-context testing --namespace testing \
    --cluster $DEFAULT_CONTEXT --user $DEFAULT_CONTEXT
```

```bash tab="EKS"
kubectl config set-context testing --namespace testing \
    --cluster devops24.$AWS_DEFAULT_REGION.eksctl.io \
    --user iam-root-account@devops24.$AWS_DEFAULT_REGION.eksctl.io
```

```bash tab="Minikube"
kubectl config set-context testing --namespace testing \
    --cluster minikube --user minikube
```

### Deploy to a new namespace

```bash
kubectl config view
```

```bash
kubectl config use-context testing
```

```bash
kubectl get all
```

```bash
TAG=2.0
DOM=go-demo-2.com
```

```bash
cat ns/go-demo-2.yml | sed -e "s@image: $IMG@image: $IMG:$TAG@g" \
    | sed -e "s@host: $DOM@host: $TAG\.$DOM@g" \
    | kubectl create -f -
```

```bash
kubectl rollout status deploy go-demo-2-api
```

```bash
curl -H "Host: go-demo-2.com" "http://$IP/demo/hello"
```

```bash
curl -H "Host: 2.0.go-demo-2.com" "http://$IP/demo/hello"
```

### Communicate accross namespaces

Make sure we use the `default` namespace again.

```bash tab="JX"
jx ns default
```

```bash tab="Kubectx"
kubens default
```

```bash tab="GKE"
kubectl config use-context $DEFAULT_CONTEXT
```

```bash tab="EKS"
kubectl config use-context iam-root-account@devops24.$AWS_DEFAULT_REGION.eksctl.io
```

```bash tab="Minikube"
kubectl config use-context minikube
```

Now we run a new container, and make sure it has curl.

```bash
kubectl run test --image=alpine --restart=Never sleep 10000
```

```bash
kubectl get pod test

kubectl exec -it test -- apk add -U curl
```

Now, lets **exec** into the container (`kubectl exec`) and use curl to test the services' DNS.

```bash tab="Service in Default ns"
kubectl exec -it test -- curl "http://go-demo-2-api:8080/demo/hello"
```


```bash tab="Service in Testing ns"
kubectl exec -it test \
    -- curl "http://go-demo-2-api.testing:8080/demo/hello"
```

### Delete a Namespace

```bash
kubectl delete ns testing
```

```bash
kubectl -n testing get all
```

```bash
kubectl get all
```

```bash
curl -H "Host: go-demo-2.com" "http://$IP/demo/hello"
```

```bash
kubectl set image deployment/go-demo-2-api \
    api=vfarcic/go-demo-2:2.0 --record
```

```bash
curl -H "Host: go-demo-2.com" "http://$IP/demo/hello"
```

### Cleanup

```bash
kubectl delete -f ns/go-demo-2.yml
kubectl delete pod test
```

## Securing Kubernetes

### GKE

* Go to [Cloud Identity and Access Management Overview](https://cloud.google.com/iam/docs/overview)
* And [Kubernetes Engine Creating Cloud IAM Policies](https://cloud.google.com/kubernetes-engine/docs/how-to/iam#primitive)
* Create a user and a cluster named jdoe
* When finished, continue from the Deploying go-demo-2 slide.

## Resource limits & requests

### Enable Heapster

> Heapster enables Container Cluster Monitoring and Performance Analysis for Kubernetes (versions v1.0.6 and higher), and platforms which include it.

!!! Info
    **GKE** has heapster installed and enabled by default.

```bash tab="Minkube"
minikube addons enable heapster
```

```bash tab="EKS"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
```

!!! Warning
    Heapster is now EOL, but still serves a purpose for this demo.
    Please do NOT use this in production systems.

### View resources

```bash
cat res/go-demo-2-random.yml
```

```bash
kubectl create -f res/go-demo-2-random.yml --record --save-config
```

```bash
kubectl rollout status deployment go-demo-2-api
```

```bash
kubectl describe deploy go-demo-2-api
```

```bash
kubectl describe nodes
```

### Expose heapster api endpoint

!!! Info
    The version of `heapster` might be different.
    Please confirm the actual name with the command below.
    ```bash
    kubectl get deployment -n kube-system
    ```

```bash tab="GKE"
kubectl -n kube-system expose deployment heapster-v1.6.0-beta.1 \
    --name heapster-api --port 8082 --type LoadBalancer
```

```bash tab="EKS"
kubectl -n kube-system expose deployment heapster \
    --name heapster-api --port 8082 --type LoadBalancer
```

```bash tab="Minikube"
kubectl -n kube-system expose rc heapster \
    --name heapster-api --port 8082 --type NodePort
```

### Measure consumption

!!! Info
    You can also use a tool such as [Kube Capacity](/k8s/tools/#kube-capacity) for easier access to these metrics.

```bash
kubectl -n kube-system get pods
```

```bash
kubectl -n kube-system get svc heapster-api -o json
```

### Measure consumption 2

```bash tab="ALL (first)"
PORT=$(kubectl -n kube-system get svc heapster-api \
    -o jsonpath="{.spec.ports[0].nodePort}")
PORT=8082
```

```bash tab="GKE"
ADDR=$(kubectl -n kube-system get svc heapster-api \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

```bash tab="EKS"
ADDR=$(kubectl -n kube-system get svc heapster-api \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
```

```bash tab="Minikube"
ADDR=$(minikube ip)
```

### Measure consumption 3

```bash
BASE_URL="http://$ADDR:$PORT/api/v1/model/namespaces/default/pods"

curl "$BASE_URL"
```

```bash
DB_POD_NAME=$(kubectl get pods -l service=go-demo-2 -l type=db \
    -o jsonpath="{.items[0].metadata.name}")
```

```bash
curl "$BASE_URL/$DB_POD_NAME/containers/db/metrics"
```

```bash
curl "$BASE_URL/$DB_POD_NAME/containers/db/metrics/memory/usage"
```

```bash
curl "$BASE_URL/$DB_POD_NAME/containers/db/metrics/cpu/usage_rate"
```

### Resource discrepancies

```bash
cat res/go-demo-2-insuf-mem.yml
```

```bash
kubectl apply -f res/go-demo-2-insuf-mem.yml --record
```

```bash
kubectl get pods
```

```bash
kubectl describe pod go-demo-2-db
```

```bash
cat res/go-demo-2-insuf-node.yml
```

```bash
kubectl apply -f res/go-demo-2-insuf-node.yml --record
```

```bash
kubectl get pods
```

```bash
kubectl describe pod go-demo-2-db
```

### Resource discrepancies 2

```bash
kubectl apply -f res/go-demo-2-random.yml --record
```

```bash
kubectl rollout status deployment go-demo-2-db
```

```bash
kubectl rollout status deployment go-demo-2-api
```

### Adjusting resources

```bash
DB_POD_NAME=$(kubectl get pods -l service=go-demo-2 \
    -l type=db -o jsonpath="{.items[0].metadata.name}")
```

```bash
curl "$BASE_URL/$DB_POD_NAME/containers/db/metrics/memory/usage"
```

```bash
curl "$BASE_URL/$DB_POD_NAME/containers/db/metrics/cpu/usage_rate"
```

```bash
API_POD_NAME=$(kubectl get pods -l service=go-demo-2 \
    -l type=api -o jsonpath="{.items[0].metadata.name}")
```

```bash
curl "$BASE_URL/$API_POD_NAME/containers/api/metrics/memory/usage"
```

```bash
curl "$BASE_URL/$API_POD_NAME/containers/api/metrics/cpu/usage_rate"
```

### Adjusting resources 2

```bash
cat res/go-demo-2.yml
```

```bash
kubectl apply -f res/go-demo-2.yml --record
```

```bash
kubectl rollout status deployment go-demo-2-api
```

### QOS

```bash
kubectl describe pod go-demo-2-db
```

```bash
cat res/go-demo-2-qos.yml
```

```bash
kubectl apply -f res/go-demo-2-qos.yml --record
```

```bash
kubectl rollout status deployment go-demo-2-db
```

```bash
kubectl describe pod go-demo-2-db
```

```bash
kubectl describe pod go-demo-2-api
```

```bash
kubectl delete -f res/go-demo-2-qos.yml
```

### Defaults & Limitations

```bash
kubectl create namespace test
```

```bash
cat res/limit-range.yml
```

```bash
kubectl -n test create -f res/limit-range.yml \
    --save-config --record
```

```bash
kubectl describe namespace test
```

```bash
cat res/go-demo-2-no-res.yml
```

```bash
kubectl -n test create -f res/go-demo-2-no-res.yml \
    --save-config --record
```

```bash
kubectl -n test rollout status deployment go-demo-2-api
```

### Defaults & Limitations 2

```bash
kubectl -n test describe pod go-demo-2-db
```

```bash
cat res/go-demo-2.yml
```

```bash
kubectl -n test apply -f res/go-demo-2.yml --record
```

```bash
kubectl -n test get events -w
```

```bash
kubectl -n test run test --image alpine --requests memory=100Mi \
    --restart Never sleep 10000
```

```bash
kubectl -n test run test --image alpine --requests memory=1Mi \
    --restart Never sleep 10000
```

```bash
kubectl delete namespace test
```

### Resource Quotas

```bash
cat res/dev.yml
```

```bash
kubectl create -f res/dev.yml --record --save-config
```

```bash
kubectl -n dev describe quota dev
```

```bash
kubectl -n dev create -f res/go-demo-2.yml --save-config --record
```

```bash
kubectl -n dev rollout status deployment go-demo-2-api
```

```bash
kubectl -n dev describe quota dev
```

### Resource Quotas 2

```bash
cat res/go-demo-2-scaled.yml
```

```bash
kubectl -n dev apply -f res/go-demo-2-scaled.yml --record
```

```bash
kubectl -n dev get events
```

```bash
kubectl describe namespace dev
```

```bash
kubectl get pods -n dev
```

```bash
kubectl -n dev apply -f res/go-demo-2.yml --record
```

```bash
kubectl -n dev rollout status deployment go-demo-2-api
```

### Resource Quotas 3

```bash
cat res/go-demo-2-mem.yml
```

```bash
kubectl -n dev apply -f res/go-demo-2-mem.yml --record
```

```bash
kubectl -n dev get events | grep mem
```

```bash
kubectl describe namespace dev
```

```bash
kubectl -n dev apply -f res/go-demo-2.yml --record
```

```bash
kubectl -n dev rollout status deployment go-demo-2-api
```

```bash
kubectl expose deployment go-demo-2-api -n dev \
    --name go-demo-2-api --port 8080 --type NodePort
```

### Cleanup

```bash
kubectl delete ns dev
```

