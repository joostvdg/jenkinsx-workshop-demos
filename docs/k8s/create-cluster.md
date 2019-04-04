
# Install Kubernetes in Public Cloud

## GKE

```bash
CLUSTER_NAME=[...] # Change to a random name (e.g., your user)
```

```bash
gcloud auth login
```

```bash
gcloud container clusters \
    create $CLUSTER_NAME \
    --region us-east1 \
    --machine-type n1-standard-1 \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1
```

```bash
kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)
```

```bash
kubectl get nodes -o wide
```

```bash
gcloud container clusters \
    delete $CLUSTER_NAME \
    --region us-east1 \
    --quiet
```