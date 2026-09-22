# Lab 15 · Parent POM, BOM & Resource Filtering

📖 **Read first:** [19 Parameterization, Parent POM & BOM](../concepts/19-parent-pom-bom-parameterization.md) · [18 Maven Build Fundamentals](../concepts/18-maven-build.md)
🎯 **End state:** `check-in-papi`'s `pom.xml` is under 80 lines, contains no plugin versions and no duplicated API coordinates, and still builds and deploys exactly as in [Lab 14](lab-14-maven-parameterize-deploy.md).

> Extension of [Lab 14](lab-14-maven-parameterize-deploy.md): Lab 14 got one app building and deploying from Maven. This lab removes the duplication you'd hit the moment a second API exists.

## Steps

### 1. Spot the duplication

In your `pom.xml` (built from `samples/maven/pom-reference.xml`) and your `config-dev.yaml`, find every value written in both. Start with the API spec `groupId` / `artifactId` / `version`.
![Lab15-1](../images/screenshots/lab15-step01-duplicate-values.png)

### 2. Move the coordinates into POM properties

Add `api.groupId` / `api.artifactId` / `api.version` to `<properties>` (Section 2 of the reference POM) and change the Exchange RAML dependency to use `${api.groupId}` etc.
![Lab15-2](../images/screenshots/lab15-step02-pom-properties.png)

### 3. Turn on filtering with `@...@` delimiters

Add the `<resources>` block and the `maven-resources-plugin` configuration from [`samples/maven/parent-pom.xml`](../samples/maven/parent-pom.xml), then rewrite the `api:` block of `config-dev.yaml` to use `@api.version@` — see [`samples/maven/config-filtered.yaml`](../samples/maven/config-filtered.yaml).

```bash
mvn process-resources
cat target/classes/config-dev.yaml
```

`@...@` must be gone; every `${secure::...}` must still be there. If the `${...}` are blank, `useDefaultDelimiters` is still `true`.
![Lab15-3](../images/screenshots/lab15-step03-filtered-output.png)

### 4. Create and install the BOM

Copy [`samples/maven/bom-pom.xml`](../samples/maven/bom-pom.xml) to `anyairline-mule-bom/pom.xml`, set the connector versions to the ones your app currently uses, then:

```bash
cd anyairline-mule-bom && mvn clean install
```

![Lab15-4](../images/screenshots/lab15-step04-bom-install.png)

### 5. Create and install the parent POM

Copy [`samples/maven/parent-pom.xml`](../samples/maven/parent-pom.xml) to `anyairline-mule-parent/pom.xml`. Move the repositories, `distributionManagement`, the `dev`/`qa`/`prod` profiles and the plugin blocks out of your app POM into it (they're already there in the sample — just delete them from the app).

```bash
cd anyairline-mule-parent && mvn clean install
```

![Lab15-5](../images/screenshots/lab15-step05-parent-install.png)

### 6. Slim the application POM

Replace your `pom.xml` with [`samples/maven/pom-child-with-parent.xml`](../samples/maven/pom-child-with-parent.xml), keeping only this app's GAV, `api.*` properties, `applicationName`, and the connectors it actually uses. Delete every `<version>` on connectors and plugins.

```bash
mvn help:effective-pom > effective.xml
```

Check that the plugin versions, repositories and profiles are still present — inherited, not written.
![Lab15-6](../images/screenshots/lab15-step06-effective-pom.png)

### 7. Rebuild and redeploy unchanged

```bash
mvn clean verify
mvn deploy -DmuleDeploy -Pdev
```

Same result as Lab 14, from a much smaller file.
![Lab15-7](../images/screenshots/lab15-step07-deploy-unchanged.png)

## ✅ Verify

- `grep -c "<version>" pom.xml` returns only the app's own version and the parent's
- `grep "1.0.3" -r . --include=pom.xml --include=*.yaml` returns exactly one hit
- `mvn clean verify -Pdev` passes after `rm -rf ~/.m2/repository/com/anyairline`
- The deployed app in Runtime Manager behaves identically to Lab 14

## 🧠 Self-check

1. Why does `import` scope only work inside `<dependencyManagement>` — and what would break if you used it in `<dependencies>`?
2. Studio shows the literal `@api.version@` in the running app. What happened, and what's the fix?
3. You need `mule-db-connector` at a newer version than the BOM says, for this app only. Where do you put it, and why doesn't that defeat the point of the BOM?
4. Which of these belongs in the parent POM, and which in the app POM: `applicationName`, `ch.region`, `app.runtime`, `api.version`?

**Related →** [Lab 14](lab-14-maven-parameterize-deploy.md) (Maven deploy) · [Lab 13](lab-13-coding-conventions.md) (DRY in the Mule XML — same principle, different file)
