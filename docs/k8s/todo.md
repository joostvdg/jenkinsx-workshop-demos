# Kubernetes basics

## Slide notes

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
