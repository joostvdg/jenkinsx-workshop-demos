# Mulder

## Steps to follow

* fork & clone
* import into jx
* fix redis config
* fix health check endpoint
* add unit tests to pipeline
* add integration tests to pipeline
* test PR
* test staging & production

## Fork & Clone

Go to [github.com/the-jenkins-x-files/mulder](https://github.com/the-jenkins-x-files/mulder) and fork the repository to your own account.

Then, go to the directory you want the source code to be.

```bash
GH_USER=?
```

```bash
git clone https://github.com/${GH_USER}/mulder
cd mulder
```

## JX Import

```bash
jx import
```

## Hints

### Application parameters

For the parameters the application takes for configuration, take a look at the `README.md`.

https://github.com/the-jenkins-x-files/mulder