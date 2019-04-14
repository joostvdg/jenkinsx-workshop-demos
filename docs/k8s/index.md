# Kubernetes Basics

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

```bash
cat pod/db.yml
```

```bash
kubectl create -f pod/db.yml
kubectl create -f pod/db.yml
kubectl apply -f pod/db.yml
```

```bash
kubectl get pod
kubectl get pods
kubectl get po
```

```bash
kubectl get po -o yaml
```

```bash
kubectl get po -o json
```


```bash
kubectl get po -o jsonpath="{}"
```

```bash
kubectl describe pod db
```

```bash
kubectl exec db ps aux

kubectl exec -it db sh

echo 'db.stats()' | mongo localhost:27017/test

exit

kubectl logs db
```

```bash
kubectl exec -it db pkill mongod

kubectl get pods
```

### Cleanup

```bash
kubectl delete -f pod/db.yml
```

## ReplicaSet

```bash
cat rs/go-demo-2.yml

kubectl create -f rs/go-demo-2.yml

kubectl get rs

kubectl describe -f rs/go-demo-2.yml

kubectl get pods
```

```bash
POD_NAME=$(kubectl get pods -o name | tail -1)

kubectl delete $POD_NAME

kubectl get pods
```

### Cleanup

```bash
kubectl delete -f rs/go-demo-2.yml
```

## Labels

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


```bash
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


## Slides

* Infrastructure As Code
* Declarative instead of Imperative
* Self-healing
* High-Availability (HA)
* Dynamic sizing
* Dynamic scaling
* Immutable
* Separate state from process
    * 12-factor app/container
* Automatable
* Standard but Extensible
* Better utilization
    * Serverless even better
    * but more expensive for _predictable load_
* Dynamic Service Discovery
* Think Clusters of Cluster
    * Static = fiction or dead
* Pets vs Cattle
* Self-Service & On-Demand
* Curated instead of Fixed
* Layers of Abstraction
    * to decouple
    * create asynchronisity
    * separate process & state
    * create fundamental building blocks
    * but also provide predefined sets

### Building Docker Images

* Docker
* Docker Multi-stage
* BuildKit
* Docker Socket & security issues
* Alternatives
    * Kaniko
    * Buildah
    * IMG
    * Others?
* Best Practices
    * Smaller is usually better
    * Optimise for short-running 
        * static links
        * `FROM scratch`
        * external state
    * stay up-to-date with base images
    * limit packages used
    * use a (lightweight) process manager
    * do not tie into a Runtime
    * i.e. make the image suitable forn Swarm, Mesos, K8S
    * 