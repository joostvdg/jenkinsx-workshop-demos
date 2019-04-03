
# Tips & Tricks

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

## Multiple Micro-services

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