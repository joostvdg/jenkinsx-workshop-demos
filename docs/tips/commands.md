# Useful Commands

## JX Shell

> Create a sub shell so that changes to the Kubernetes context, namespace or environment remain local to the shell

```bash
# create a new shell using a specific named context
jx shell prod-cluster
```

## JX Prompt

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

## JX Helm

As of this writing, April 2019, Tiller is no longer installed by default.
This means Helm cannot find it's releases.

To interact with Helm as you're used to, use `jx step helm` instead.

```bash
jx step helm list
```

For more details, [read the docs](https://jenkins-x.io/commands/jx_step_helm/).

## Single Issue commands

### Get URLS

```bash
jx get urls
```
