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