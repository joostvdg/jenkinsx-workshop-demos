# Go Demo

This is a minimal HelloWorld demo!

First, make sure you have [a Kubernetes cluster with Jenkins X installe](/install/#install-jx-w-cluster)

!!! Warning
    It is easiest to use all the default values, such as a dns on `nip.io` and `Static Jenkins`.

## Create Quickstart

Let's examine what `quickstart` does.

```bash
jx create quickstart # Cancel with ctrl+c
```

Cancel it with `ctr+c`, as it will be very interactive.

Let's create the Go (lang) demo!

```bash
jx create quickstart -l go -p jx-go -b
```

!!! Info
    Go to [github.com/jenkins-x-quickstarts](https://github.com/jenkins-x-quickstarts) to see all the available quickstarts.

### Open repo

Replace ? with your GitHub user.

```bash
export GH_USER=?
```

```bash
open "https://github.com/$GH_USER/jx-go"
```

### View created files

Let's take a look at what was created:

```bash
ls -l jx-go
```

```bash tab="Dockerfile"
cat jx-go/Dockerfile
```

```bash tab="pipeline"
cat jx-go/jenkins-x.yml
```

```bash tab="Makefile"
cat jx-go/Makefile
```

```bash tab="Skaffold"
cat jx-go/skaffold.yaml
```

And let's take a loot at the Helm charts.

```bash tab="Charts root"
ls -l jx-go/charts
```

```bash tab="Application Chart"
ls -l jx-go/charts/jx-go
```

```bash tab="Preview Chart"
ls -l jx-go/charts/preview
```

## Webhook

Jenkins X works with Git and wants to work event based.
This means there should be a webhook, which will be send to our Jenkins X's cluster.

```bash
open "https://github.com/$GH_USER/jx-go/settings/hooks"
```

## Releases

Jenkins X will create releases for you in your Git repository (where applicable).

To view them:

```bash
open "https://github.com/$GH_USER/jx-go/releases"
```

## Explore Application in JX

```bash tab="Jenkins UI"
jx console
```

```bash tab="Activities"
jx get activities
```

```bash tab="Acitivites jx-go"
jx get activities -f jx-go -w # Cancel with ctrl+c
```

```bash tab="Build Logs"
jx get build logs # Cancel with ctrl+c
```

```bash tab="Build Logs jx-go"
jx get build logs -f jx-go # Cancel with ctrl+c
```

```bash tab="Build Logs of Job"
jx get build logs $GH_USER/jx-go/master
```

## General Jenkins X listings

```bash tab="Pipelines"
jx get pipelines
```

```bash tab="Applications"
jx get applications
```

```bash tab="Applications in Env"
jx get applications -e staging
```

```bash tab="Environments"
jx get env
```

## Update the application

First, make sure the application has been build successfully and is running in our staging environment.

### Confirm we're ready

```bash
jx get activities -f jx-go -w
```

You should see something like, after which we can continue the next step.

```bash
STEP                     STARTED AGO DURATION STATUS
joostvdg/jx-go/master #1                      Running Version: 0.0.1
  Release                      4m23s     1m0s Succeeded
  Promote: staging             3m23s    2m26s Succeeded
    PullRequest                3m23s    1m25s Succeeded  PullRequest: https://github.com/joostvdg/environment-jx-staging/pull/1 Merge SHA: f602fd78694fcfef7b59b27469e0e2b8538e1bb7
    Update                     1m58s     1m1s Succeeded  Status: Success at: http://jenkins.jx.35.231.11.119.nip.io/job/joostvdg/job/environment-jx-staging/job/master/2/display/redirect
    Promoted                   1m58s     1m1s Succeeded  Application is at: http://jx-go.jx-staging.35.231.11.119.nip.io
```

```bash
JX_HOST=$(kubectl get ing -n jx-staging jx-go -o jsonpath="{.spec.rules[0].host}")
open "http://$JX_HOST"
```

You should see a very fancy (for 1992) page which says `Hello from:  Jenkins X golang http example`.

### Make the change

We will now create a WIP branch.

```bash
git checkout -b wip
```

Now edit our `main.go` file using your favorite editor - or VIM if you want.

Change the title variable: `title := "Jenkins X golang http example"` to a value you like. For example: `title := "Jenkins X Is Awesome!"`.

```bash
git add main.go
git commit -m "changed our message to be awesome"
git push origin wip
```

### Create PR

We will have to create PR for our change.

When pushing to Git, you should have received a link to create a pr.
If not, see below:

```bash
open "https://github.com/${GH_USER}/jx-go/pull/new/wip"
```

Keep the PR page open, you will see why!

We will watch the activities to see when our `preview` is ready!

```bash
jx get activities -f jx-go -w
```

Once we see something like `Preview Application           0s           http://jx-go.jx-joostvdg-jx-go-pr-1.35.231.11.119.nip.io`
We can go back to our PR page, which should now the link to the preview as well!

Confirm your change is successful and merge the pull request by clicking the merge button.

Go back to the activities feed - in case you closed it. And wait for the PR to land in staging.

```bash
jx get activities -f jx-go -w
```

Once the activity `Promote: staging` is succeeded, we can confirm our application is updated.

```bash
JX_HOST=$(kubectl get ing -n jx-staging jx-go -o jsonpath="{.spec.rules[0].host}")
curl "http://$JX_HOST"
```

To wrap up, go back to the master branch and pull the changes from the PR.

```bash
git checkout master
git pull
```

## Promote to Production

Applications will be automatically promoted to staging, to promote them to production we have to take manual action.

### How do you promote manually

To manually Promote a version of your application to an environment use the jx promote command.

```bash
jx promote --app myapp --version 1.2.3 --env production
```

The command waits for the promotion to complete, logging details of its progress. You can specify the timeout to wait for the promotion to complete via the --timeout argument.

e.g. to wait for 5 hours

```bash
jx promote  --app myapp --version 1.2.3 --env production --timeout 5h
```

You can use terms like 20m or 10h30m for the various duration expressions.

To promote our `jx-go` application, run the following command.

### Promote jx-go to production

```bash
jx promote  --app jx-go --version 0.0.1 --env production --timeout 1h
```

!!! Info
    You will get a warning message stating `Failed to query the Pull Request last commit status for`, which is at this time (April 2019) expected behavior.

Once the promotion is completed successfully, you should be returned to your console.

Let's confirm our application landed in Production!

```bash
JX_HOST=$(kubectl get ing -n jx-production jx-go -o jsonpath="{.spec.rules[0].host}")
curl "http://$JX_HOST"
```