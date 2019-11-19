# Preview Environments

## Two Charts

We have two charts, one default chart and one for Preview environments only.


## Three Level Testing

* **Static Validation**
* **Application Specific Tests**
* **System Validation**

!!! quote
    The first group of tests consists of those that do not rely on live applications. I'll call them **static validation**, and they can be unit tests, static analysis, or any other type that needs only code. Given that we do not need to install our application for those types of tests, we can run them as soon as we check out the code and before we even build our binaries. - *Viktor Farcic*

!!! quote 
    The second group is the **application-specific** tests. For those, we do need to deploy a new release first, but we do not need the whole system. Those tests tend to rely heavily on mocks and stubs. In some cases, that is not possible or practical, and we might need to deploy a few other applications to make the tests work. While I could argue that mocks should replace all "real" application dependencies in this phase, I am also aware that not all applications are designed to support that.  - *Viktor Farcic*

!!! quote
    The third group of tests is **system-wide validations**. We might want to check whether one live application integrates with other live applications. We might want to confirm that the performance of the system as a whole is within established thresholds. There can be many other things we might want to validate on the level of the whole system. What matters is that the tests in this phase are expensive. They tend to be slower than others, and they tend to need more resources. What we should not do while running system-wide validations is to repeat the checks we already did. We do not run the tests that already passed, and we try to keep those in this phase limited to what really matters (mostly integration and performance).  - *Viktor Farcic*

## Making Changes

Acceptable ways to make changes to source code.

* directly on *Mainline* (`trunk`, `master`), advocated by Trunk Based Development (**TBD**)
* via short lived feature branches, merging to *Mainline* quickly via an (semi-)automated process
* anything else that works for you -> but don't expect me to support you in your endeavors
    * this has been proven by Accelerate and `State of DevOps Report` to slow you down

## Automated Merging Process

Jenkins X automates the merging process for short lived feature branches via **PullRequests** and **ChatOps**.
It does so via the `jx promote` command.

```bash
Promotes a version of an application to zero to many permanent environments.

For more documentation see: https://jenkins-x.io/about/features/#promotion

Examples:
  # Promote a version of the current application to staging
  # discovering the application name from the source code
  jx promote --version 1.2.3 --env staging

  # Promote a version of the myapp application to production
  jx promote myapp --version 1.2.3 --env production

  # To search for all the available charts for a given name use -f.
  # e.g. to find a redis chart to install
  jx promote -f redis

  # To promote a postgres chart using an alias
  jx promote -f postgres --alias mydb

  # To create or update a Preview Environment please see the 'jx preview' command
  jx preview
Options:
      --alias='': The optional alias used in the 'requirements.yaml' file
      --all-auto=false: Promote to all automatic environments in order
  -a, --app='': The Application to promote
      --build='': The Build number which is used to update the PipelineActivity. If not specified its defaulted from  the '$BUILD_NUMBER' environment variable
  -e, --env='': The Environment to promote to
  -f, --filter='': The search filter to find charts to promote
  -r, --helm-repo-name='releases': The name of the helm repository that contains the app
  -u, --helm-repo-url='': The Helm Repository URL to use for the App
      --ignore-local-file=false: Ignores the local file system when deducing the Git repository
  -n, --namespace='': The Namespace to promote to
      --no-helm-update=false: Allows the 'helm repo update' command if you are sure your local helm cache is up to date with the version you wish to promote
      --no-merge=false: Disables automatic merge of promote Pull Requests
      --no-poll=false: Disables polling for Pull Request or Pipeline status
      --no-wait=false: Disables waiting for completing promotion after the Pull request is merged
      --pipeline='': The Pipeline string in the form 'folderName/repoName/branch' which is used to update the PipelineActivity. If not specified its defaulted from  the '$BUILD_NUMBER' environment variable
      --pull-request-poll-time='20s': Poll time when waiting for a Pull Request to merge
      --release='': The name of the helm release
  -t, --timeout='1h': The timeout to wait for the promotion to succeed in the underlying Environment. The command fails if the timeout is exceeded or the promotion does not complete
  -v, --version='': The Version to promote
Usage:
  jx promote [application] [flags] [options]
Use "jx options" for a list of global command-line options (applies to all commands).
```

## Useful Commands

```bash
jx get previews
```

```bash
jx create pullrequest \
  --title "My PR" \
  --body "This is the text that describes the PR
and it can span multiple lines" \
  --batch-mode
```

```bash
jx get issues -b
```

## Garbage Collection

```bash
kubectl get cronjobs
```

```
jx gc previews
```

## References

* https://medium.com/@MichalFoksa/jenkins-x-preview-environment-3bf2424a05e4
* https://jenkins-x.io/docs/concepts/jenkins-x-pipelines/#customizing-the-pipelines
* https://jenkins-x.io/faq/develop/#how-do-i-add-other-services-into-a-preview
* https://jenkins-x.io/commands/jx_step_create_pullrequest_chart/
* https://github.com/jasonwc-jenkinsx-example/yo-frontend/pull/3/files
* https://jenkins-x.io/about/features/#promotion