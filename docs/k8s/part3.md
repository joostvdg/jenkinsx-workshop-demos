# Kubernetes Basics - Part III

!!! Info
    This workshop segment expect you to be inside a cloned repository of `k8s-specs`.

    ```bash
    git clone https://github.com/vfarcic/k8s-specs.git
    cd k8s-specs
    ```

## Points to cover

* Persisting State
* Deploying Stateful Applications At Scale

## Persisting State

### Without state preservation

```bash
cat pv/jenkins-no-pv.yml
```

```bash
kubectl create -f pv/jenkins-no-pv.yml --record --save-config
```

```bash
kubectl -n jenkins get events
```

```bash
kubectl -n jenkins create secret generic jenkins-creds \
    --from-literal=jenkins-user=jdoe \
    --from-literal=jenkins-pass=incognito
```

```bash
kubectl -n jenkins rollout status deployment jenkins
```

### Retrieve Jenkins Address

```bash tab="GKE"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

```bash tab="EKS"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
```

```bash tab="Minikube"
JENKINS_ADDR=$(minikube ip)
```

### Log into Jenkins

!!! Warning
    If you're on windows, `open` probably doesn't work.
    Copy paste the url printed and open that in a browser.

```bash
echo $JENKINS_ADDR
open "http://$JENKINS_ADDR/jenkins"
```

* use `jdoe` as username and `incognito` as password
* create a job, doesn't matter what

### Kill the pod

```bash
kubectl -n jenkins get pods --selector=app=jenkins -o json
```

```bash
POD_NAME=$(kubectl -n jenkins get pods --selector=app=jenkins \
    -o jsonpath="{.items[*].metadata.name}")
```

```bash
echo $POD_NAME
```

```bash
kubectl -n jenkins exec -it $POD_NAME pkill java
```

```bash
echo "http://$JENKINS_ADDR/jenkins"
open "http://$JENKINS_ADDR/jenkins"
```

### Create Volume

#### GKE

```bash
CLUSTER_NAME=
```

```bash
gcloud compute instances list --filter="name:('${CLUSTER_NAME}')" \
    --format 'csv[no-heading](zone)' | tee zones
```

```bash
AZ_1=$(cat zones | head -n 1)
```

```bash
AZ_2=$(cat zones | tail -n 2 | head -n 1)
```

```bash
AZ_3=$(cat zones | tail -n 1)
```

Replace `???` with your name to make sure the disk name is unique.

```bash
PREFIX=???
```

```bash
gcloud compute disks create ${PREFIX}-disk1 --zone $AZ_1
```

```bash
gcloud compute disks create ${PREFIX}-disk2 --zone $AZ_2
```

```bash
gcloud compute disks create ${PREFIX}-disk3 --zone $AZ_3
```

!!! Warning
    Later commands will depend on these variables.
    So stay in the same console session or make sure you recreate these!

```bash
VOLUME_ID_1=${PREFIX}-disk1
VOLUME_ID_2=${PREFIX}-disk2
VOLUME_ID_3=${PREFIX}-disk3
```

```bash
gcloud compute disks describe VOLUME_ID_1
```

#### EKS

...

### Create Persistent Volume

#### GKE

```bash
YAML=pv/pv-gke.yml
cat $YAML
```

```bash
cat $YAML \
    | sed -e "s@REPLACE_ME_1@$VOLUME_ID_1@g" \
    | sed -e "s@REPLACE_ME_2@$VOLUME_ID_2@g" \
    | sed -e "s@REPLACE_ME_3@$VOLUME_ID_3@g" \
    | kubectl create -f - --save-config --record
```

```bash
kubectl get pv
```

### Claim Persistent Volume

```bash
cat pv/pvc.yml
```

```bash
kubectl create -f pv/pvc.yml --save-config --record
```

```bash
kubectl -n jenkins get pvc
```

```bash
kubectl get pv
```

### Attach PVC

```bash
cat pv/jenkins-pv.yml
```

```bash
kubectl apply -f pv/jenkins-pv.yml --record
```

```bash
kubectl -n jenkins rollout status deployment jenkins
```

### Demonstrate the persistent part

* open Jenkins `open "http://$JENKINS_ADDR/jenkins"`
* create a job

```bash
POD_NAME=$(kubectl -n jenkins get pod --selector=app=jenkins \
    -o jsonpath="{.items[*].metadata.name}")
```

```bash
kubectl -n jenkins exec -it $POD_NAME pkill java
```

```bash
kubectl -n jenkins delete deploy jenkins
```

* confirm job is still there
* open Jenkins `open "http://$JENKINS_ADDR/jenkins"`

```bash
kubectl -n jenkins get pvc
```

```bash
kubectl get pv
```

### Cleanup

```bash tab="ALL"
kubectl -n jenkins delete pvc jenkins
kubectl get pv
kubectl delete -f pv/pv.yml
```

```bash tab="GKE"
gcloud compute disks delete $VOLUME_ID_1 --zone $AZ_1 --quiet
gcloud compute disks delete $VOLUME_ID_2 --zone $AZ_2 --quiet
gcloud compute disks delete $VOLUME_ID_3 --zone $AZ_3 --quiet
```

```bash tab="EKS"
aws ec2 delete-volume --volume-id $VOLUME_ID_1
aws ec2 delete-volume --volume-id $VOLUME_ID_2
aws ec2 delete-volume --volume-id $VOLUME_ID_3
```

## Storage Classes

### View

```bash tab="ALL - before others"
kubectl get sc
```

```bash tab="GKE"
cat pv/jenkins-dynamic-gke.yml
```

```bash tab="EKS"
cat pv/jenkins-dynamic.yml
```

### Create

```bash tab="GKE"
kubectl apply -f pv/jenkins-dynamic-gke.yml --record
```

```bash tab="EKS"
kubectl apply -f pv/jenkins-dynamic.yml --record
```

```bash tab="ALL - after others"
kubectl -n jenkins rollout status deployment jenkins
```

### Use

```bash tab="ALL - before others"
kubectl -n jenkins get events

kubectl -n jenkins get pvc

kubectl get pv
```

```bash tab="GKE"
PV_NAME=$(kubectl get pv -o jsonpath="{.items[0].metadata.name}")
gcloud compute disks list --filter="name:('$PV_NAME')"
```

```bash tab="EKS"
aws ec2 describe-volumes \
    --filters 'Name=tag-key,Values="kubernetes.io/created-for/pvc/name"'
```

### Use 2

```bash tab="ALL - before others"
kubectl -n jenkins delete deploy,pvc jenkins

kubectl get pv
```

```bash tab="GKE"
gcloud compute disks list --filter="name:('$PV_NAME')"
```

```bash tab="EKS"
aws ec2 describe-volumes \
    --filters 'Name=tag-key,Values="kubernetes.io/created-for/pvc/name"'
```

### Use Default

```bash
kubectl get sc
```

```bash
kubectl describe sc
```

```bash
cat pv/jenkins-default.yml
```

```bash
diff pv/jenkins-dynamic.yml pv/jenkins-default.yml
```

```bash
kubectl apply -f pv/jenkins-default.yml --record
```

```bash
kubectl get pv
```

### Prepare alternative SC

```bash tab="All - before others"
kubectl -n jenkins delete deploy,pvc jenkins
```

```bash tab="GKE"
YAML=sc-gke.yml
```

```bash tab="EKS"
YAML=sc.yml
```

### Create alternative SC

```bash
cat pv/$YAML
```

```bash
kubectl create -f pv/$YAML
```

```bash
kubectl get sc
```

### Use alternative SC

```bash tab="All - before others"
cat pv/jenkins-sc.yml
kubectl apply -f pv/jenkins-sc.yml --record
```

```bash tab="EKS"
aws ec2 describe-volumes \
    --filters 'Name=tag-key,Values="kubernetes.io/created-for/pvc/name"'
```

```bash tab="GKE"
PV_NAME=$(kubectl get pv -o jsonpath="{.items[0].metadata.name}")
gcloud compute disks list --filter="name:('$PV_NAME')"
```

### Cleanup

```bash
kubectl delete ns jenkins
```

```bash
kubectl delete sc fast
```

## StatefulSet

### Create StatefulSwet

```bash
cat sts/jenkins.yml
```

```bash
kubectl apply -f sts/jenkins.yml --record
```

```bash
kubectl -n jenkins rollout status sts jenkins
```

```bash
kubectl -n jenkins get pvc
```

```bash
kubectl -n jenkins get pv
```

### Get Jenkins Address

```bash tab="GKE"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

```bash tab="EKS"
JENKINS_ADDR=$(kubectl -n jenkins get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
```

### Use Jenkins

```bash
open "http://$JENKINS_ADDR/jenkins"
```

```bash
kubectl delete ns jenkins
```

### Use DB without STS

```bash
cat sts/go-demo-3-deploy.yml
```

```bash
kubectl apply -f sts/go-demo-3-deploy.yml --record
```

```bash
kubectl -n go-demo-3 rollout status deployment api
```

```bash
kubectl -n go-demo-3 get pods
```

```bash
DB_1=$(kubectl -n go-demo-3 get pods -l app=db \
    -o jsonpath="{.items[0].metadata.name}")
```

```bash
DB_2=$(kubectl -n go-demo-3 get pods -l app=db \
    -o jsonpath="{.items[1].metadata.name}")
```

### Investigate problems

```bash
kubectl -n go-demo-3 logs $DB_1
```

```bash
kubectl -n go-demo-3 logs $DB_2
```

```bash
kubectl get pv
```

```bash
kubectl delete ns go-demo-3
```

### Use DB with STS

```bash
cat sts/go-demo-3-sts.yml
```

```bash
kubectl apply -f sts/go-demo-3-sts.yml --record
```

```bash
kubectl -n go-demo-3 get pods
```

```bash
kubectl get pv
```

### Configure Mongo

If we want MongoDB to use the three instances as single dataplane, we have to tell it the dataplane members.

First, we shell into one of the db containers via `exec`.

```bash
kubectl -n go-demo-3 exec -it db-0 -- sh
```

Then, make sure we're talking with MongoDB, via its REPL, with `mongo`.

```bash
mongo
```

And finally we explain MongoDB what we want to do.

```bash
rs.initiate( {
   _id : "rs0",
   members: [
      {_id: 0, host: "db-0.db:27017"},
      {_id: 1, host: "db-1.db:27017"},
      {_id: 2, host: "db-2.db:27017"}
   ]
})
```

Let's confirm with MongoDB **before** we exit the container.

```bash
rs.status()
```

And now you're free to exit the MongoDB REPL and the container via `ctrl+d` (so twice).

```bash
kubectl -n go-demo-3 get pods
```

### Observe update process

```bash
diff sts/go-demo-3-sts.yml sts/go-demo-3-sts-upd.yml
```

```bash
kubectl apply -f sts/go-demo-3-sts-upd.yml --record
```

```bash
kubectl -n go-demo-3 get pods
```

### Cleanup

```bash
kubectl delete ns go-demo-3
```