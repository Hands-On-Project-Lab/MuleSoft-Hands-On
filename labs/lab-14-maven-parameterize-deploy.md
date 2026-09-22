# Lab 14 · Parameterize and Deploy via Maven

📖 **Read first:** [18 Maven Build Fundamentals](../concepts/18-maven-build.md) · [13 Properties &amp; Secrets](../concepts/13-properties-secrets.md)
🎯 **End state:** same compiled artifact deployed to `dev` via `mvn deploy`, picking up dev's property file — no Studio manual deploy needed.

> Alternate/extension path to [Lab 07](lab-07-deploy-cloudhub.md): Lab 07 deploys manually from Studio; this lab does the same deploy from the command line via Maven, which is what CI/CD actually runs.

## Steps

### 1. Confirm the app is already parameterized

Check `samples/mule/https-listener.xml` — keystore path/password already use `${secure::keystore.password}`, not hardcoded values.
![Lab14-1](../images/screenshots/lab14-step01-parameterized-xml.png)

### 2. Build a real pom.xml from the reference

Start from `samples/maven/pom-reference.xml` (packaging, connectors, MuleSoft repositories, `mule-maven-plugin`, `munit-maven-plugin` — every block commented with where it's used), then merge the CloudHub deploy block from `samples/maven/pom-cloudhub-deploy-snippet.xml` into the `mule-maven-plugin`'s `<configuration>`.
![Lab14-2](../images/screenshots/lab14-step02-pom-plugin.png)

### 3. Run the build + tests

```bash
mvn clean verify
```

Confirms `validate → compile → test → package → verify` all pass, including MUnit.
![Lab14-3](../images/screenshots/lab14-step03-mvn-verify.png)

### 4. Deploy to CloudHub `dev` from Maven

```bash
export ANYPOINT_USERNAME=<user>
export ANYPOINT_PASSWORD=<pass>
export MULE_KEY=<secure-properties-key>
mvn deploy -DmuleDeploy -Denv=dev
```

![Lab14-4](../images/screenshots/lab14-step04-mvn-deploy.png)

### 5. Verify the right property file was loaded

Check Runtime Manager logs for `mule.env=dev` and the `config-dev.yaml` values (e.g. `https.port`), then call the app the same way as Lab 07.

```bash
curl -i -X PUT https://<app>.<region>.cloudhub.io/api/tickets/ABC123/checkin
```

![Lab14-5](../images/screenshots/lab14-step05-verify-env.png)

## ✅ Verify

`mvn deploy` succeeds without touching Studio; app in Runtime Manager shows `dev` properties applied.

## 🧠 Self-check

1. Why must `ANYPOINT_PASSWORD` and `MULE_KEY` be environment variables, never committed in `pom.xml`?
2. Which Maven lifecycle phase actually produces the `.jar` that gets deployed?

\***\*Related →** [Lab 07](lab-07-deploy-cloudhub.md) (manual deploy) · [Lab 15](lab-15-parent-pom-bom.md) (remove the duplication this lab leaves behind) · [Lab 12](lab-12-rtf-ingress-tls.md) (course finale, RTF path) Related →\*\* [Lab 07](lab-07-deploy-cloudhub.md) (manual deploy) · [Lab 12](lab-12-rtf-ingress-tls.md) (course finale, RTF path
