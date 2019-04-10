# Kubernetes Basics

## Points to cover

* Building Docker Images
* Creating Pods
* Scaling Pods With ReplicaSets
* Using Services To Enable Communication Between Pods
* Deploying Releases With Zero-Downtime
* Using Ingress To Forward Traffic

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

## Labels

## Deployment



## Service

## Ingress

## Annotations

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