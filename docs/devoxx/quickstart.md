# Quickstart

## ENVs

```bash
GH_USER=joostvdg
APP_NAME=jx-qs-spring-boot-1
GH_TOKEN=
```

## Check Existing Applications

```
jx get applications
```

## Create

```bash tab="default"
jx create spring
```

```bash tab="preconfigured"
jx create spring --git-username=${GH_USER} --git-api-token=${GH_TOKEN}
```

## See Application in JX

### Watch Activity

```
jx get activity -f jx-qs-spring-boot -w
```

### Get Applications

```
jx get applications -e staging
```

### Test Application

```
http https://jx-qs-spring-boot-7-jx-staging.staging.cjxd.kearos.net
```

### Get Build Log

```
jx get build log
```

## CJXD UI

```
jx ui -p 8082
```

## Add Pipeline step

* Open Application with Intelli J
* open `jenkins-x.yml`

### Build Packs

* https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/tree/master/packs
* https://github.com/jenkins-x-buildpacks/jenkins-x-classic/blob/master/packs/maven/pipeline.yaml

## Add SonarCloud scan

* https://sonarcloud.io/projects/create

### Add env vars

```yaml
pipelineConfig:
    env:
      - name: example
        value: someValue
      - name: fromSecret
        valueFrom:
          secretKeyRef:
            key: SONARCLOUD_APIKEY
            name: sonarcloud-apikey
```

### Add step

```yaml
pipelineConfig:
  pipelines:
    overrides:
      - name: mvn-deploy
        pipeline: release
        stage: build
        step:
          name: sonar
          command: sonar-scanner
          image: fabiopotame/sonar-scanner-cli # newtmitch/sonar-scanner for JDK 10+?
          dir: /workspace/source/
          args:
           - -Dsonar.projectName=jx-qs-spring-boot
           - -Dsonar.projectKey=jx-qs-spring-boot
           - -Dsonar.organization=joostvdg-github
           - -Dsonar.sources=./src/main/java/
           - -Dsonar.language=java
           - -Dsonar.java.binaries=./target/classes
           - -Dsonar.host.url=https://sonarcloud.io
           - -Dsonar.login=bebe633ad6599cbf52f7e0b9ee1bc2bbd3cd9c80
        type: after
```

### Verify existing pipeline

```bash
jx step syntax effective
```

### Make the Change

```
git add jenkins-x.yml
git commit -m "add sonarqube scan"
```

```
git push
```

### Confirm build

```
jx get activity -f jx-qs-spring-boot-7 -w
```

```
jx get build logs
```
