# Kubernetes Basics - Part I

## Points to cover

* Building Docker Images
* Creating Pods
* Scaling Pods With ReplicaSets
* Using Services To Enable Communication Between Pods
* Deploying Releases With Zero-Downtime
* Using Ingress To Forward Traffic

## Prerequisites

This guide borrows heavily from the workshops created by [Viktor Farcic](https://vfarcic.github.io/#/3).

The examples below are build on top of his example repository, so make sure you clone that.

```bash
git clone https://github.com/vfarcic/k8s-specs.git
cd k8s-specs
```

## Build docker images

### Docker

### BuildKit

### Alternatives

## Pod

### View Yaml

```bash
cat pod/db.yml
```

### Create & Update

```bash
kubectl create -f pod/db.yml
```

```bash
kubectl create -f pod/db.yml
```

```bash
kubectl apply -f pod/db.yml
```

### View Pod

```bash tab="Singular"
kubectl get pod
```

```bash tab="Plural"
kubectl get pods
```

```bash tab="Shorthand"
kubectl get po
```

```bash tab="YAML"
kubectl get po db -o yaml
```

```bash tab="JSON"
kubectl get po db -o json
```

```bash tab="JSON Path
kubectl get pod db -o jsonpath="{.metadata.name}"
```

```bash tab="Describe"
kubectl describe pod db
```

### Enter the Pod

```bash
kubectl exec db ps aux
```

```bash
kubectl exec -it db sh
```

```bash
echo 'db.stats()' | mongo localhost:27017/test
```

```bash
exit
```

```bash
kubectl logs db
```

```bash
kubectl exec -it db pkill mongod
```

```bash
kubectl get pods
```

### Cleanup

```bash
kubectl delete -f pod/db.yml
```

## ReplicaSet

### View YAML

```bash
cat rs/go-demo-2.yml
```

### Create ReplicaSet

```bash
kubectl create -f rs/go-demo-2.yml
```

### View ReplicaSet

```bash
kubectl get rs
```

```bash
kubectl describe -f rs/go-demo-2.yml
```

### Delete Pod

```bash
kubectl get pods
```

```bash
POD_NAME=$(kubectl get pods -o name | tail -1)
kubectl delete $POD_NAME
```

```bash
kubectl get pods
```

### Cleanup

```bash
kubectl delete -f rs/go-demo-2.yml
```

## Labels

### Create a Pod

```bash
kubectl create -f pod/db.yml
```

### Get it by Label

```bash
kubectl get po -l type=db
```

### Get multiple

```bash
kubectl get po -n kube-system -l component=kube-proxy,tier=node
```

## Service

### View

```bash tab="GKE/EKS"
cat svc/go-demo-2-lb.yml
```

```bash tab="Minikube"
cat svc/go-demo-2.yml
```

### Create

```bash tab="GKE/EKS"
kubectl create -f svc/go-demo-2-lb.yml
```

```bash tab="Minikube"
kubectl create -f svc/go-demo-2.yml
```

### Inspect

```bash
kubectl get -f svc/go-demo-2.yml
```

### Get LB IP

```bash tab="EKS"
IP=$(kubectl get svc go-demo-2-api \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
```

```bash tab="GKE"
IP=$(kubectl get svc go-demo-2-api \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

```bash tab="Minikube"
IP=$(minikube ip)
```

```bash tab="All - after"
echo $IP
```

### Get Port

```bash tab="GKE/EKS"
PORT=8080
```

```bash tab="Minikube"
PORT=$(kubectl get svc go-demo-2-api \
    -o jsonpath="{.spec.ports[0].nodePort}")
```

### Call Application

```bash tab="curl"
curl -i "http://$IP:$PORT/demo/hello"
```

```bash tab="HTTPie"
http "$IP:$PORT/demo/hello"
```

### Cleanup

```bash
kubectl delete -f svc/go-demo-2.yml
```

## Deployment

```bash
cat deploy/go-demo-2.yml
```

```bash
kubectl create -f deploy/go-demo-2.yml --record --save-config
```

```bash
kubectl describe deploy go-demo-2-api
```

```bash
kubectl get all
```

### Zero downtime deployment

```bash
kubectl set image deploy go-demo-2-api api=vfarcic/go-demo-2:2.0 \
    --record
```

```bash
kubectl rollout status -w deploy go-demo-2-api
```

```bash
kubectl describe deploy go-demo-2-api
```

```bash
kubectl rollout history deploy go-demo-2-api
```

```bash
kubectl get rs
```

### Rollback / Rollforward

```bash
kubectl rollout undo deploy go-demo-2-api
```

```bash
kubectl describe deploy go-demo-2-api
```

```bash
kubectl rollout history deploy go-demo-2-api
```

```bash
kubectl rollout undo -f deploy/go-demo-2-api.yml --to-revision=2
```

```bash
kubectl rollout history deploy go-demo-2-api
```

### Scaling

```bash
kubectl scale deployment go-demo-2-api --replicas 8 --record
```

```bash
kubectl get pods
```

### Cleanup

```bash
kubectl delete -f deploy/go-demo-2.yml
```

## Ingress

### Install ingress controller

```bash tab="GKE"
kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
```

```bash tab="Minikube"
minikube addons enable ingress
```

### Confirm ingress works

!!! Info
    As we're waiting for the LoadBalancer to be created by the Cloud Provider,
    we might have to repeat the command until we get a valid IP address as response.

```bash tab="GKE"
IP=$(kubectl -n ingress-nginx get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $IP
```

```bash tab="Minikube"
IP=$(minikube ip)
curl -i "http://$IP/healthz"
```

### Ingress based on paths

```bash
cat ingress/go-demo-2.yml
```

```bash
kubectl create -f ingress/go-demo-2.yml --record --save-config
```

```bash
kubectl rollout status deployment go-demo-2-api
```

```bash
curl -i "http://$IP/demo/hello"
```

### Ingress based on domains

```bash
cat ingress/devops-toolkit-dom.yml
```

```bash
kubectl apply -f ingress/devops-toolkit-dom.yml --record
```

```bash
kubectl rollout status deployment devops-toolkit
```

```bash
curl -I -H "Host: devopstoolkitseries.com" "http://$IP"
```

```bash
curl -I -H "Host: acme.com" "http://$IP/demo/hello"
```

### Ingress with default backends

```bash
curl -I -H "Host: acme.com" "http://$IP"
```

```bash
cat ingress/default-backend.yml
```

```bash
kubectl create -f ingress/default-backend.yml
```

```bash
curl -I -H "Host: acme.com" "http://$IP"
```

```bash
open "http://$IP"
```

### Cleanup

```bash
kubectl delete -f ingress/default-backend.yml
kubectl delete -f ingress/devops-toolkit-dom.yml
kubectl delete -f ingress/go-demo-2.yml
```