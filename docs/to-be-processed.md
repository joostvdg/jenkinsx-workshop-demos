# Jenkins X Introduction

## Notes from Slack

## Tips & Tricks

* https://github.com/jenkinsci/kubernetes-credentials-provider-plugin
* volume storage with Heptio's Valerio
* debugging: https://jenkins-x.io/contribute/development/#debugging
* `--gitops` mode <-- have to check this
* `jx upgrade platform`
* [knative authentication](https://github.com/knative/docs/blob/master/build/auth.md#basic-authentication-git)
* `--git-username` & `--org` are complimentary, `--organisations` is unrelated
    * username = the user for the repo's (apps & env)
    * org = the organization for the repo's (apps & env)
    * e.g.: `--git-username joostvdg --org demomon`
    * `--organisations` is used to query GitHub for Quickstarts (no need to specify unless you have alternatives)
* Jenkins configurations do not persist
    * you can specify them in a ConfigMap though
    * https://github.com/jenkins-x/charts/blob/jenkins/stable/jenkins/templates/config.yaml#L8
* credentials used for config can be found here: `~/.jx/jenkinsAuth.yam`
* PodTemplates (static Jenkins) are from the [Jenkins Kubernetes Plugin](https://github.com/jenkinsci/kubernetes-plugin)
* cleanup GKE `jx gc gke`
* you can create separate teams with `--no-tiller` even if the installation was done with Tiller
* `jx init` to "fix" a outdated `~/.jx` folder
* https://jenkins-x.io/commands/jx_step_credential/
* don't do mono repo's
    * why? -> https://medium.com/@mattklein123/monorepos-please-dont-e9a279be011b
    * but if you do, https://fuchsia.googlesource.com/jiri/
* using a different git provider
    * --git-provider-url .... --git-provider-kind bitbucketserver --git-username foo --git-api-token whatever
    * https://jenkins-x.io/developing/git/#using-a-different-git-provider-for-environments
* `jx start pipeline` to manually trigger a pipeline (I assume static Jenkins only)
* enable GCS for chartmuseum backend
    * https://github.com/jenkins-x/cloud-environments/blob/master/env-jx-infra/myvalues.yaml#L10-L17
* `jx` wraps `kubectx` tool, so you can use `jx ns <namespace>` to change your context to a different namespace
* faq for diagnosing `exposecontroller` issues:
    * https://jenkins-x.io/faq/issues/#how-can-i-diagnose-exposecontroller-issues
    * controller is used to generate ingress resources
* https://github.com/lvlstudio/jenkins-x-builders/tree/master/builder-nodejs-mysql
* https://github.com/jenkins-x/jx/issues/2550
* https://github.com/jenkins-x/jenkins-x-platform/issues/4768
* Tillerless: https://jenkins-x.io/news/helm-without-tiller/
* difference between `jx create quickstart` and selecting spring vs. `jx create spring`
    * `jx create spring` is an interactive wizard that uses the spring initialiser https://start.spring.io/
    * `jx create quickstart` uses a configurable github org to list available existing quickstarts i.e. https://github.com/jenkins-x-quickstarts (edited)
* multi-cluster support: 
    * https://github.com/jenkins-x-charts/environment-controller
    * https://github.com/jenkins-x/jx/issues/479
* `jx create user`?
* https://jenkins-x.io/commands/jx_create_jenkins_token/
* for problems with wild card certificates doing only one segment (i.e., `*.example.com` instead of `*.*.example.com`)
    * no - we can tweak that. It’s easiest with wildcard - then any exposed service at `svc.ns.domain` just works - but you could register each namespace in DNS
    * we’ve not exposed that property to the `jx install` CLI yet - but you could try `kubectl edit cm ingress-config`
    * `urltemplate: "{{.Service}}-{{.Namespace}}.{{.Domain}}"`
    * and then `jx upgrade ingress`
    * doesn't seem to work yet? (customization gets reverted)
    * alternative, add dns entries to the ingress resources
    * https://jenkins-x.io/getting-started/install-on-cluster/#installing-jenkins-x-on-premise
* Helm tips & tricks for changing secrets
    * https://github.com/helm/helm/blob/master/docs/charts_tips_and_tricks.md#user-content-automatically-roll-deployments-when-configmaps-or-secrets-change
* how to run integration tests
    * I've answered this in a previous thread. Basically you use the helm chart (which includes the service dependencies as requirements). You create a preview but set the replicaCount for your service to 0 (that way, just the requirements are started). Then just run your tests against the requirements and delete the preview afterwards. Search the channel history for my messages and replicaCount. You should find it.
    * https://jenkins-x.io/faq/develop/#how-do-i-add-other-services-into-a-preview
* managing static jenkins config has some issues
    * https://github.com/jenkins-x/jx/issues/2991
    * https://github.com/jenkins-x/jx-docs/issues/1039
    * https://github.com/helm/charts/pull/9296/files

> we’re super close from recommending folks use `jx create cluster ... --vault --gitops`  which uses a git repository to store all the configuration changes + versions of stuff - and uses Vault to store all secrets

> we just merged the last few fixes so it should work for static jenkins servers with the latest `jx` binary - feb 7

!!! Info
    It is Ready: `jx create cluster gke --vault --gitops --no-tiller`

### Multiple Micro-services

> if 1 microservice was 1 helm chart with a few different containers for example; you may have a few repos that just make binaries/docker images - then 1 repo which contains the helm chart of the microservice - you can also easily combine microservices together into an uber helm chart - James Strachan

> we prefer to use multiple repositories so that things are more microservice based. The problem with monorepos is everything gets released on every change; with separate repos its easier to manage change etc

> to handle changing versions of things across repositories we use `updatebot` ourselves to do ‘CI/CD of dependencies’ - we kinda think of it as promotion of dependencies like we promote microservices into environments - its PRs generated as part of the release process

> the main decision to make really is, , if you have, say, 3 microservices that are fairly tightly coupled; do you combine 3 versions of them all into 1 chart and then release that 1 chart when its all tested together; or do you release the 3 things totally independently - it depeends on coupling and team structure really & you can switch from one to the other at any time really

* https://github.com/jenkins-x/updatebot

```bash
# Setup:
$ jx create cluster gke -n team1 --default-environment-prefix team1 
$ jx create quickstart -p app1
$ jx create quickstart -p app2
$ jx create quickstart -p app3

# The 5 repos:
environment-team1-staging
environment-team1-production
app1
app2
app3
```

## Practices & Principles

### Principles

* Faster time to market
* Improved deployment frequency
* Shorter time between fixes
* Lower failure rate of releases
* Faster Mean Time To Recovery

### Practices

* Loosely-coupled Architectures
* Self-service Configuration
* Automated Provisioning
* Continuous Build / Integration and Delivery
* Automated Release Management
* Incremental Testing
* Infrastructure Configuration as Code
* Comprehensive configuration management
* Trunk based development and feature flags

## Prerequisites

Primary

* jx
* Git
* Docker
* Kubernetes
* Helm

Secondary

* Nexus
* GitOps
* Skaffold
* KNative
* Prow
* KSync

### JX

### Git


### Docker

### Kubernetes

* any public cloud will do
* GKE is recommended

#### Validate Cluster for Jenkins X Compliance

You can [read this article from Viktor Farcic](https://www.cloudbees.com/blog/your-cluster-ready-jenkins-x) on how to confirm if your cluster is compliant with Jenkins X's requirements.

Jenkins X has a binary, called `jx`, which includes some facilities from the [Sonobuoy SDK](https://github.com/heptio/sonobuoy) to provide some validation capabilities.

##### Run compliance check

To run the compliance check, just use the `jx` command below.

```bash
jx compliance run
```

!!! Warning
    The compliance check will run for about one hour!

##### Check Compliance run status

```bash
jx compliance status
```

##### Check Compliance run logs

```bash
jx compliance logs -f
```

##### See Compliance run results

```bash
jx compliance results
```

##### Cleanup

Once you're done with the compliance run, you can clean up any resources it created for the run.

```bash
jx compliance delete
```

### Helm

* package manager for Kubernetes
* quivalent to `yum install <package>`
* Kubernetes manifest template (Go templates), packaged and versioned, reffered to as `Charts`

#### Use Cases

* manages packages, repositories and installations
* manage dependencies to other Charts
    * meaning: you can create bundles
* allows for customizing standardized installations on Kubernetes
    * for example: MySQL database with specific database, users and settings
* used as building blocks in other tools
* separate packaging (Chart) from runtime (application image)
    * there's the chart version
    * and the application version

#### Architecture

* Helm repository = a hosted `index.yaml`
* client (`helm`) and server (`tiller`) component

#### Chartmuseum

* lightweight Helm chart repository
     * alternatives are Artifactory, Nexus 3, but are heavy "support all package types" kind of tools
* supports different storage options
    * local (e.g., Kubernetes volume)
    * S3 / Minio
    * Google Cloud Storage
    * Azure Blob Store
    * Alibaba Cloud OSS storage
    * Openstack Object Storage

#### Monocular

* UI for Helm repositories
* includes documentation and searching
* can give insight into charts installed in the cluster via helm

### GitOps

* https://www.weave.works/blog/gitops-operations-by-pull-request
* https://www.weave.works/blog/what-is-gitops-really
* https://www.cloudbees.com/blog/gitops-dev-dash-ops
* https://developer.atlassian.com/blog/2017/07/kubernetes-workflow/

#### Thoughts

* declarative specification for each environment
* auditable changes
* ability to verify live what is vs. what should be
    * aside from autoscaling and the like
    * for example, with [Kubediff](https://github.com/weaveworks/kubediff)
* reproducable environments
* helps automate and spead up `Segragation of Duties`
* use PullRequests for change management
* eventual consistency via event based reconciliation
    * e.g., Git commit event -> pipeline -> update based on spec

## Jenkins X - Introduction

The challenges Jenkins X tries to solve:

* good way to setup Kubernetes environments
* containerize your applications
* deploy containerized applications to Kubernetes
* adopt Continuous Delivery / Progressive Delivery
* base platform for automation
* keeping focus on delivering value instead of HOW to deliver the value
* help embed proven practices from the `State of DevOps Report`

### How

* automates installations of all the basic building blocks for CI, CD and PD
    * helm, skaffold, kaniko, jenkins, ksync, knative, nexus, monocular, chartmuseum,...
    * pre-configured, ready to go
* automates CI/CD setup (PD setup is coming)
    * Docker image
    * Helm chart
    * (Jenkins) Pipeline
    * Event trigger management (e.g., GitHub event triggers for Pipelines)
* pre-configured GitOps environments + pipelines for managing environment promotion
* feedback & interaction
    * logs, notification hooks, caches
    * labels and comments on GitHub issue / PR
    * PR chatbot

## Jenkins X - Installation

There's four ways to install Jenkins X.

* install in an existing public cloud Kubernetes cluster `jx install`
* create cluster and installation via public cloud's CLI (e.g., `gcloud`)
* create cluster and installation via [Terraform](https://www.terraform.io/) (where applicable)
* install Jenkins X in an on-premise Kubernetes cluster (requirements apply)

During the installation, the following things will be done via the `jx` binary.

If you're using Mac OS X, the `jx` binary will install any missing tool via `homebrew`.

* install Helm
* install cloud provider cli
* install kubectl
* create cluster (unless an install only option is used)
* create Jenkins X `namespace`
* install Tiller (unless helm 3 or tillerless is specified)
* setup basic ingress controller
* install several CI/CD tools
    * chartmuseum
    * docker-registry
    * jenkins
    * monocular
    * nexus
* configure git source repository
* create admin secrets

The installation can be configured with flags in order to customize how each step is executed.

### Default

### Terraform

### Install only

### On-Premis

### Next Steps

* create and app via quickstart
* import and existing app
* customize your Jenkins X installation

## Jenkins X - IDE Integration

You read all about [Jenkins X's IDE integration in the docs](https://jenkins-x.io/developing/ide/).

### Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com/) is a popular open source IDE from Microsoft.

The Jenkins X team created the [vscode-jx-tools](https://github.com/jenkins-x/vscode-jx-tools) extension for VS Code.

### Intelli J

There's a plugin for [IntelliJ](https://www.jetbrains.com/idea/) and the associated IDEs like WebStorm, GoLand, PyCharm et al from [JetBrains](https://www.jetbrains.com/).

You can find the [Jenkins X plugin for IntelliJ here](https://plugins.jetbrains.com/plugin/11099-jenkins-x).

## Jenkins X - Customization

### Installation Parameters

### Component Configuration

During installation (incl. or excl. cluster creation) Jenkins X will read a `myvalues.yaml` file in the current directory to configure its core components.

You [can read more about all the options here](https://jenkins-x.io/getting-started/config/), but below are some examples.

#### Nexus

You might not want to include Nexus in your installation, the snippet below will exclude it from being installed.

```yaml
nexus:
  enabled: false
nexusServiceLink:
  enabled: true
  externalName: "nexus.jx.svc.cluster.local"
```

#### Chartmuseum

Add the below snippet in order to skip installing Chartmuseum.

```yaml
chartmuseum:
  enabled: false
chartmuseumServiceLink:
  enabled: true
  externalName: "jenkins-x-chartmuseum.jx.svc.cluster.local"
```

#### Jenkins image used

When using the static Jenkins type of installation, Jenkins X uses the [jenkinsxio/jenkinsx](https://hub.docker.com/r/jenkinsxio/jenkinsx/) docker image. You specify an alternative image in the `myvalues.yaml`.

```yaml
jenkins:
  Master:
    Image: "acme/my-jenkinsx"
    ImageTag: "1.2.3"
```

For how to create your custom Jenkins image, [read the Jenkins X docs](https://jenkins-x.io/getting-started/config/#jenkins-image).

#### Alternative Docker Registry

Currently - March 2019 - you can only specify the docker registry during the installation (`jx create cluster` or `jx install`) via a flag.

```bash
jx create cluster gke --docker-registry eu.gcr.io
```

You will have to configure the docker authentication secret as well.
How to do this, [you can read in the Jenkins X documentation](https://jenkins-x.io/architecture/docker-registry/#update-the-config-json-secret).

## Jenkins X - Basic Usage

* import
* quickstart
* console
* pipelines
* promote
* environments
* applications
* teams

## Jenkins X - Other Features


### Teams

* https://jenkins-x.io/about/features/#teams

### JX Shell

> Create a sub shell so that changes to the Kubernetes context, namespace or environment remain local to the shell

```bash
# create a new shell using a specific named context
jx shell prod-cluster
```

### JX Prompt

> Generate the command line prompt for the current team and environment

```bash tab="current"
# Generate the current prompt
jx prompt
```

```bash tab="bash"
# Enable the prompt for bash
PS1="[\u@\h \W \$(jx prompt)]\$ "
```

```bash tab="zsh"
# Enable the prompt for zsh
PROMPT='$(jx prompt)'$PROMPT
```

### Issue Tracker

[Jenkins X can work with issue trackers](https://jenkins-x.io/developing/issues/) such as GitHub issues and Jira.

By default, Jenkins X will use GitHub for projects and issues.
So if you haven't specified anything for either Git provider or Issue tracker, it will use GitHub for issues.

#### GitHub

```bash
jx create issue -t "lets make things more awesome"
```

```bash
jx get issues
```

#### Jira

In order to configure Jenkins X to use Jira as issue tracker, you have to do three steps.

1. create a tracker configuration `jx create tracker server ${trackerName} https://mycompany.atlassian.net/`
1. create a tracker login `jx create tracker token -n ${trackerName}  myEmailAddress`
1. configure your Jenkins X managed project to use this issue tracker instead `jx edit config -k issues`

!!! Info
    A file called jenkins-x.yml will be modified in your project source code which should be added to your git repository.

### Security

Jenkins X [has direct support for some security analysis](https://jenkins-x.io/developing/security-features/).

#### Anchore image scanning

The [Anchore Engine](https://github.com/anchore/anchore-engine) is used to provide image security, by examining contents of containers either in pull request/review state, or on running containers.

This was introduced in this [blog post](https://jenkins.io/blog/2018/05/08/jenkins-x-anchore/).
[Here is a video](https://youtu.be/rB8Sw0FqCQk) demonstrating it live.

```bash
jx create addon anchore
```

To see if it found any problems in a specific environment:

```bash
jx get cve --environment=staging
```

#### OWASP ZAP

ZAP or [Zed Attack Proxy](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project) allows you to scan the public surface of your application for any known vulnerability.

```bash
jx create addon owasp-zap
```

## Jenkins X - Development Cycle


### Versioning

* semver semantics
* using git tags
* https://github.com/jenkins-x/jx-release-version
* https://www.cloudbees.com/blog/automatically-versioning-your-application-jenkins-x

### DevPod

* https://jenkins-x.io/developing/devpods/

### Custom Builder

* https://jenkins-x.io/getting-started/create-custom-builder/

### Preview

A new preview is created when you create a PullRequest (PR) on a Jenkins X managed application.

1. builds the application
1. packages it into a Helm chart
1. creates a unique Kubernetes namespace -only on first build
1. deploys the application into the namespace
1. adds a pull request comment with preview environment URL

* https://jenkins-x.io/about/features/#preview-environments
* https://jenkins-x.io/developing/preview/#adding-more-resources
* https://medium.com/@vbehar/zero-cost-preview-environments-on-kubernetes-with-jenkins-x-and-osiris-bd9ce0148d03
* https://medium.com/@MichalFoksa/jenkins-x-preview-environment-3bf2424a05e4

#### Get current preview environments

```bash
jx get previews
```

#### Post Preview hook

Jenkins X allows you to extend it at several points.
One such extension point is the `preview` process.

You can [extends the preview process with a post preview hook](https://jenkins-x.io/developing/preview/#post-preview-jobs).

#### Add dependencies

Your application might depend on other services or facilities, that are generally present in your staging and production environment. With the move to clusters, these can have become a cluster function,

These cluster functions might not be available in your temporary preview environment.
Or you want to test your application against multiple versions of its dependencies.

So you need the ability to specify these dependencies for the preview of your app which should only be used for the preview environment.

This can be done in two ways.

1. link Kubernetes service from other environment /namespace
1. create an instance of a dependency in the preview environment through Helm chart.

##### Link to a service

Via the `jx` step [link service](https://jenkins-x.io/commands/jx_step_link/) you connect your preview app with a Jenkins X managed service elsewhere in the same cluster.

Example:

```bash
jx step link services --from-namespace jx-staging --includes "*" --excludes "cheese*"
```

#### Add helm chart dependency

The preview environment has its own helm chart, in the folder `charts/preview`.
You can add dependencies in here, just like in any other helm chart.

Just make sure the chart ends with the dependency on your app (in `charts/appName`) and an empty line, as the file's comment says.

### Promotion

* https://jenkins-x.io/faq/develop/#how-does-promotion-actually-work
* https://jenkins-x.io/developing/promote/

## Jenkins X & Secrets

* https://github.com/futuresimple/helm-secrets
* https://developer.epages.com/blog/tech-stories/kubernetes-deployments-with-helm-secrets/
* vault operator / addon?
* secrets for preview example: https://github.com/Zenika/snowcamp-2019-sncf-timesheet-reader
    * or this: https://github.com/Riduidel/snowcamp-2019


> thanks! helm secrets was the only choice available initially but we’re moving more towards using the vault operator instead - though we need some more docs and demos to show how to use secrets in vault from a Preview or Staging environment - James Strachan

## Extending Jenkins X

* https://jenkins-x.io/extending/

## Jenkins X & CloudBees CodeShip

## Jenkins X & The Future

* Serverless Jenkins
* Tekton aka Next Gen(eration) Pipeline

### Serverless

* https://medium.com/@jdrawlings/serverless-jenkins-with-jenkins-x-9134cbfe6870
* https://github.com/jenkinsci/jenkinsfile-runner

### Next Gen Pipeline

* https://www.cloudbees.com/blog/move-toward-next-generation-pipelines
* https://jenkins-x.io/news/jenkins-x-next-gen-pipeline-engine/
* https://github.com/tektoncd/pipeline#-tekton-pipelines
* https://github.com/jenkins-x/jx/issues/3225
* https://jenkins-x.io/getting-started/next-gen-pipeline/
* https://github.com/jenkins-x/jx/issues/3223
