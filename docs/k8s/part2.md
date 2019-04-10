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

## Secrets

## Namespaces

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