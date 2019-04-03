# Cluster Validation

You can [read this article from Viktor Farcic](https://www.cloudbees.com/blog/your-cluster-ready-jenkins-x) on how to confirm if your cluster is compliant with Jenkins X's requirements.

Jenkins X has a binary, called `jx`, which includes some facilities from the [Sonobuoy SDK](https://github.com/heptio/sonobuoy) to provide some validation capabilities.

## Run compliance check

To run the compliance check, just use the `jx` command below.

```bash
jx compliance run
```

!!! Warning
    The compliance check will run for about one hour!

## Check Compliance run status

```bash
jx compliance status
```

## Check Compliance run logs

```bash
jx compliance logs -f
```

## See Compliance run results

```bash
jx compliance results
```

## Cleanup

Once you're done with the compliance run, you can clean up any resources it created for the run.

```bash
jx compliance delete
```