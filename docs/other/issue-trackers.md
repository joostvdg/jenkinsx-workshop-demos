# Issue Trackers

[Jenkins X can work with issue trackers](https://jenkins-x.io/developing/issues/) such as GitHub issues and Jira.

By default, Jenkins X will use GitHub for projects and issues.
So if you haven't specified anything for either Git provider or Issue tracker, it will use GitHub for issues.

## GitHub

```bash
jx create issue -t "lets make things more awesome"
```

```bash
jx get issues
```

## Jira

In order to configure Jenkins X to use Jira as issue tracker, you have to do three steps.

1. create a tracker configuration `jx create tracker server ${trackerName} https://mycompany.atlassian.net/`
1. create a tracker login `jx create tracker token -n ${trackerName}  myEmailAddress`
1. configure your Jenkins X managed project to use this issue tracker instead `jx edit config -k issues`

!!! Info
    A file called jenkins-x.yml will be modified in your project source code which should be added to your git repository.
