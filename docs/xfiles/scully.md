# Scully

## Steps

* fork & clone
* jx import
* fix Dockerfile
* add Mulder as dependency
    * helm repo (see hints below if you doubt)
* fix url to Mulder

## Fork & Clone

Go to [github.com/the-jenkins-x-files/scully](https://github.com/the-jenkins-x-files/scully) and fork the repository to your own account.

Then, go to the directory you want the source code to be.

```bash
GH_USER=?
```

```bash
git clone https://github.com/${GH_USER}/scully
cd mulder
```

## JX Import

```bash
jx import
```

## Hints

### Helm repository

You might need to know the urls for the Helm repository.

#### Internal

For interaction within the cluster.

```bash
kubectl get svc -n jx
```

You should see something like this:

```bash
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
heapster                        ClusterIP   10.23.241.52    <none>        8082/TCP    12d
jenkins                         ClusterIP   10.23.253.164   <none>        8080/TCP    12d
jenkins-agent                   ClusterIP   10.23.249.153   <none>        50000/TCP   12d
jenkins-x-chartmuseum           ClusterIP   10.23.252.63    <none>        8080/TCP    12d
jenkins-x-docker-registry       ClusterIP   10.23.250.118   <none>        5000/TCP    12d
jenkins-x-mongodb               ClusterIP   10.23.250.218   <none>        27017/TCP   12d
jenkins-x-monocular-api         ClusterIP   10.23.249.13    <none>        80/TCP      12d
jenkins-x-monocular-prerender   ClusterIP   10.23.242.95    <none>        80/TCP      12d
jenkins-x-monocular-ui          ClusterIP   10.23.243.161   <none>        80/TCP      12d
```

This name and the port number, is the chart repository you can use for Mulder internally.

#### External

For testing locally, to make sure the `mulder` chart exists in your ChartMuseum repository.

```bash
jx get urls
```

Replace the `?` below, with the url of ChartMusem you got via `jx get urls`.

```bash
CM_ADDR=?
```

```bash
helm repo add jx-workshop $CM_ADDR
helm repo update
helm search mulder
```

### Build & Run

To build and run the application, you can take a look at the `README.md`.

* https://github.com/the-jenkins-x-files/scully

You can also use the `npm` tools.

```bash
npm install
npm run build
```

```bash
npm install -g serve # might have to be run with SUDO
serve -s build
```

### Get a quote in the UI

Click on Scully's "voice box" to get a quote.

### Use environment variables

For the Mulder server url, you can set an environment variable.

There are several places you can set this, in `values.yaml` or in `templates/deployment.yaml`.

### Cannot find module '../lib/utils/unsupported.js'

If you run into this error:

```bash
internal/modules/cjs/loader.js:583
throw err;
^

Error: Cannot find module '../lib/utils/unsupported.js'
    at Function.Module._resolveFilename (internal/modules/cjs/loader.js:581:15)
```

The easiest resolution, is to reinstall `node` via homebrew (assuming MacOS).

```bash
sudo rm -rf /usr/local/lib/node_modules/npm
brew reinstall node
```
