# Kubernetes Intermediate

## Points to cover

* Using ConfigMaps To Inject Configuration Files
* Using Secrets To Hide Confidential Information
* Dividing A Cluster Into Namespaces
* Securing Kubernetes Clusters
* Managing Resources
* Persisting State
* Deploying Stateful Applications At Scale

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

```bash tab="GKE"
DEFAULT_CONTEXT=$(kubectl config current-context)
kubectl config set-context testing --namespace testing \
    --cluster $DEFAULT_CONTEXT --user $DEFAULT_CONTEXT
```

```bash tab="JX"
jx ns testing
```

```bash tab="Kubectx"
kubens testing
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

## Service Accounts

## Resource limits & requests

## Volumes

### Volume

### Persistent Volume

## StatefulSet

```YAML
# INSERT Jenkins STS Yaml
```

```bash
cat sts/jenkins.yml

kubectl apply -f sts/jenkins.yml --record

kubectl -n jenkins rollout status sts jenkins

kubectl -n jenkins get pvc

kubectl -n jenkins get pv
```

* look at PVC template
* look at PVC
* look at PV

```bash tab="GKE"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

```bash tab="EKS"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
```

```bash
open "http://$JENKINS_ADDR/jenkins"
```

```bash
kubectl delete ns jenkins
```

### Optional

* teaches why STS type is needed
* cannot replicate database on the same data storage
* so create unique DB's via STS with PVC Templates
* see: https://vfarcic.github.io/devops23/workshop-short.html#/33/9

```bash
cat sts/go-demo-3-deploy.yml

kubectl apply -f sts/go-demo-3-deploy.yml --record

kubectl -n go-demo-3 rollout status deployment api

kubectl -n go-demo-3 get pods

DB_1=$(kubectl -n go-demo-3 get pods -l app=db \
    -o jsonpath="{.items[0].metadata.name}")

DB_2=$(kubectl -n go-demo-3 get pods -l app=db \
    -o jsonpath="{.items[1].metadata.name}")
```

```bash
kubectl -n go-demo-3 logs $DB_1

kubectl -n go-demo-3 logs $DB_2

kubectl get pv

kubectl delete ns go-demo-3
```

### Use STS instead

* See: https://vfarcic.github.io/devops23/workshop-short.html#/33/12

```bash
cat sts/go-demo-3-sts.yml

kubectl apply -f sts/go-demo-3-sts.yml --record

kubectl -n go-demo-3 get pods

kubectl get pv
```

## Annotations

## CRD's