# Kubernetes basics

## Slide notes

A few points I forgot, and that we should talk about:

-          Gitops

-          Cron-based Jenkins jobs: we have quite a few right now (I need to go over all our current jobs with you). Prefer event-based over scheduled. What if we have some jobs we really want to schedule?

-          gcloud SDK (CLI). A few of us are used to it, but most people never used it. Because it’s also our client for things like pubsub or GCS, it might be good to have a (small) part about google cloud, and how to use it. There is also the “service account” part that I mentioned (in the “pushing to GCR” part), that is related.

-          static envs vs dynamic envs. For the moment everybody is used to static envs. I think it’s important to show the advantage of dynamic env. Could be a good intro to preview envs

-          in the “Jenkins x” part, it would be great if we can show an example of using updatebot. That’s a great tool, and I love how the Jenkins x project is using it to automate the versions updates everywhere, and I’d love to do the same thing.

* config maps
* labels
* annotations
* secrets
* containers are fun
* buuuuttttt, not enough to really solve problems in a better way
* crash course
    * image vs container vs instance
    * layers, from scratch
* pets vs. cattle
* regional vs. zonal
* slides of kubernetes asynch + event handlers + reconcilliation
* kubernetes imperative vs. declarative
* 12-factor app / container
* even if you don't need scaling:
    * explicit resource reqs
    * auto-restarts
    * homogenous deployment
    * homogenous observability
    * homogenous extension (think istio, flagger)
* rollback vs. rollforward
* namespaces
    * purpose
    * impact on DNS
* QoS: https://vfarcic.github.io/devops23/workshop-short.html#/29/24
* Volumes
    * volumes
    * persistent volumes
    * volume types
    * persistent volume claims
    * attaching persistent volume claims
    * PersistendVolumeClaimTemplates
    * Provisioners, such as NFS (incl. EFS and filestor support)
    * storage Classes
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
* STS:
    * teaches why STS type is needed
    * cannot replicate database on the same data storage
    * so create unique DB's via STS with PVC Templates
    * see: https://vfarcic.github.io/devops23/workshop-short.html#/33/9

## Ideas workshop

* gke does not give cluster-admin by default
* script for generating service account

### Docker build

* pre-requisite
    * install docker (for windows/mac)
    * dockerhub account
* cat a dockerfile
* single-stage
* multi-stage
    * requires 17.5, not supported on GKE (yet)
* tag & push

### Pod

* show imperative
* show declarative
* 


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