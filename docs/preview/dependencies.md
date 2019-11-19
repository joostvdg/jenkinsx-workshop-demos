# Preview Env Dependencies

## Remarks

> agreed. one cheat to minimise having the front end preview to know the latest backend version and vice versa is for the previews of the front + back ends to use latest image verisons; we generally recommend always using real versions - but for these kinds of front+back end previews it can be handy (then never using latest in real releases post a merge)

## Direct Service Link

Add a Kubernetes `Service` resource in `charts/preview/templates/`.
The application launched in the preview environment can then call the dependency "locally", where the service has a reference to an instance running elsewhere.[^1]

??? example

    ```yaml
    kind: Service
    apiVersion: v1
    metadata:
        name: mysql
    spec:
        type: ExternalName
        # Target service DNS name
        externalName: mysql.jx-staging.svc.cluster.local
        ports:
        - port: 3306
    ```

## Dependency Instance

You can add dependencies in the `charts/preview/requirements.yaml` as for any other chart.

Due to how Jenkins X creates dependencies, you will have to change something somewhere.
Either your `values.yaml` needs to change how the direct dependency is called - to avoid the preview prefix - or you have to change your application's configuration to be able to point to the de Preview instance of your dependency.

## MongoDB

### Install Directly

```
helm repo add bitnami https://charts.bitnami.com
helm install bitnami/mongodb --version 7.4.5
```

### Via Jenkins X

```yaml
# requirements.yaml
- name: mongodb
  repository: https://charts.bitnami.com
  version: 7.4.5
```

```yaml
# values.yaml
mongodb:
  mongodbUsername: someusername
  mongodbPassword: somepassword
  mongodbDatabase: somedatabase
```

## References

[^1]: [Jenkins X Preview Environment - Michal Foksa](https://medium.com/@MichalFoksa/jenkins-x-preview-environment-3bf2424a05e4)
