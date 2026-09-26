# [Stage 20 · Build & Dependency Resolution] Maven 401 resolving an Exchange dependency after clearing `.m2`

> **Pipeline position:** 20 — Build & Dependency Resolution (Maven) · comes **after** [Stage 10](10-exchange-spec-vs-application-asset-type-conflict.md) (Design & Publish) · comes **before** [Stage 30](30-local-self-signed-tls-certificate-untrusted.md) (Local Run, TLS & Secure Properties)

**Confidence:** Confirmed
**Related:** [concept 20 §6](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#6--gatekeeper-blocked--exchange-401-after-clearing-m2)
· [concept 18](../concepts/18-maven-build.md)
**Keywords:** maven, exchange, 401, unauthorized, settings.xml, m2, dependency-resolution

## Scenario

A fresh checkout, or a wiped local Maven repository (`~/.m2/repository`), forces Maven to re-fetch the API spec dependency from Anypoint Exchange instead of using a cached copy.

## Symptom

```
[ERROR] Failed to execute goal on project check-in-papi: Could not collect dependencies for project 713ed815-e409-4a51-9ef2-7a71017fa06e:check-in-papi:mule-application:1.0.0-SNAPSHOT
[ERROR] Failed to read artifact descriptor for 713ed815-e409-4a51-9ef2-7a71017fa06e:check-in-papi:zip:oas:1.0.0
[ERROR] Caused by: The following artifacts could not be resolved: ... status code: 401, reason phrase: Unauthorized (401)
```

## Step-by-step fix

1. Confirm `~/.m2/repository` was actually cleared/missing the artifact — this only triggers a fresh remote fetch, so a warm cache masks the problem.
2. Open `~/.m2/settings.xml` and find the `<server>` entry whose `<id>` is referenced by the `<repository>` (or `<distributionManagement>`) block pulling from `maven.anypoint.mulesoft.com`.
3. If that `<server>` block is missing, or its `<id>` doesn't match exactly (case-sensitive), add/correct it:
   ```xml
   <server>
     <id>anypoint-deploy-server</id>
     <username>your-anypoint-username-or-client-id</username>
     <password>your-anypoint-password-or-client-secret</password>
   </server>
   ```
4. Re-run `mvn clean install` on the API **specification** project first, so it's in your local repo before the dependent application project needs it.
5. If it still 401s, regenerate the Connected App client secret — a silently expired/rotated secret produces the identical error.

## Root cause

Maven resolves the Exchange Maven Facade like any private repository — no matching `settings.xml` server credentials means an anonymous, unauthorized request.

## Why it recurs

Any "clean slate" event — new machine, wiped `.m2`, fresh Studio workspace import — resets this silently, because nothing in source control reminds you `settings.xml` credentials are needed; they live outside the repo by design (see [concept 18](../concepts/18-maven-build.md)).
