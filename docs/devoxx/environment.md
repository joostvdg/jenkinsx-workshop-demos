# Environment

## Show Environments

```
jx get environments
```

## Make a PR

### Create New Branch

```
git checkout -b helloworld-controller
```

### Add Model

```java
GreetGrasd
```

### Add controller

```java
@RestController
@RequestMapping("/hello")
public class HelloWorldController {
    @GetMapping
    public Greeting hello() {
        return new Greeting("Hello Devoxx!");
    }
}
```

### Make the PR

```
git add src/
git commit -m "add helloworld controller"
```

```
git push --set-upstream origin helloworld-controller
```

```
jx create pullrequest --title "my PR" --body "What are we doing" --batch-mode
```

```
jx get activity -f jx-qs-spring-boot -w
```

```
jx get build log
```

```
http http://jx-qs-spring-boot-7.jx-joostvdg-jx-qs-spring-boot-7-pr-1.dev.cjxd.kearos.net/hello
```

## Promote to production

* show environments: `jx get environments`
    * look at `KIND` and `PROMOTE`
* show repository

```
jx get applications -e staging
```

```
jx get applications -e production
```

```
jx promote jx-qs-spring-boot-7 --env production --version 
```

```
jx get activity -f env-cjxd-prod -w
```

```
jx ui -p 8082
```

```
jx get applications -e production
```

## Add PR

* show applications: `jx get applications`
* show environments: `jx get environments`
* `git checkout -b helloworld-controller`
* make changes
* `git push --set-upstream origin helloworld-controller`
* create pull request `jx create pullrequest --title "my PR" --body "What are we doing" --batch-mode`
* open URL of pull request
* add `/meow`
* add `/assign @joostvdg`
* add `/lgtm`
* watch activity `jx get activity -f jx-qs-spring-boot-1 -w`
* look for Preview in GitHub PR page
* show namespaces: `kubectl get namespaces`
* approve PR & merge

## References

* https://docs.cloudbees.com/docs/cloudbees-jenkins-x-distribution/latest/developer-guide/spring-boot