# Security features

## Secure Coding

Jenkins X [has direct support for some security analysis](https://jenkins-x.io/developing/security-features/).

### Anchore image scanning

The [Anchore Engine](https://github.com/anchore/anchore-engine) is used to provide image security, by examining contents of containers either in pull request/review state, or on running containers.

This was introduced in this [blog post](https://jenkins.io/blog/2018/05/08/jenkins-x-anchore/).
[Here is a video](https://youtu.be/rB8Sw0FqCQk) demonstrating it live.

```bash
jx create addon anchore
```

To see if it found any problems in a specific environment:

```bash
jx get cve --environment=staging
```

### OWASP ZAP

ZAP or [Zed Attack Proxy](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project) allows you to scan the public surface of your application for any known vulnerability.

```bash
jx create addon owasp-zap
```