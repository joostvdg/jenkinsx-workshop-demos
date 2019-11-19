# Jenkins X Pipeline

## Create Step

```bash
jx create step --help
```

```bash
Creates a step in the Jenkins X Pipeline

Aliases:
step, steps
Examples:
  # Create a new step in the Jenkins X Pipeline interactively
  jx create step

  # Creates a step on the command line: adding a post step to the release build lifecycle
  jx create step -sh "echo hello world"

  # Creates a step on the command line: adding a pre step to the pullRequest promote lifecycle
  jx create step -p pullrequest -l promote -m pre -c "echo before promote"
Options:
  -d, --dir='': The root project directory. Defaults to the current dir
  -l, --lifecycle='': The lifecycle stage to add your step. Possible values: setup, setversion, prebuild, build, postbuild, promote
  -m, --mode='': The create mode for the new step. Possible values: pre, post, replace
  -p, --pipeline='': The pipeline kind to add your step. Possible values: release, pullrequest, feature
  -c, --sh='': The command to invoke for the new step
Usage:
  jx create step [flags] [options]
```

## Create Step For PRs

### Simple Example

```bash
jx create step \
    --pipeline pullrequest \
    --lifecycle promote \
    --mode post \
    --sh 'ls -lath'
```

### Multiline & Wait

```yaml
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        # This was modified
        - name: unit-tests
          command: make unittest
      promote:
        steps:
        # This is new
        - name: rollout
          command: |
            NS=\`echo cd-\$REPO_OWNER-go-demo-6-\$BRANCH_NAME | tr '[:upper:]' '[:lower:]'\`
            sleep 15
            kubectl -n \$NS rollout status deployment preview-preview --timeout 3m
        # This was modified
        - name: functional-tests
          command: ADDRESS=\`jx get preview --current 2>&1\` make functest
```

## Validate Current Pipeline Configuration

```bash
jx step syntax validate pipeline
```

## Add SonarQube Scan

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

## Pipeline Schema

```bash
jx step syntax schema
```

### Build Pack Schema

```bash
jx step syntax schema --buildpack
```

```bash
jx step syntax validate buildpacks
```