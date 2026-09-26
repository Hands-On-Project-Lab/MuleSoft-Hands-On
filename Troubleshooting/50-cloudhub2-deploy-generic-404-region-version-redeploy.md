# [Stage 50 · CloudHub 2.0 Deployment] Generic 404 "no asset matching given parameters"

> **Pipeline position:** 50 — CloudHub 2.0 Deployment (Maven → Runtime Manager) · comes **after** [Stage 40](40-cloudhub2-connected-app-business-group-not-valid.md) (CI/CD Authentication) · comes **before** [Stage 60](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md) (Runtime Networking & TLS Termination)

**Confidence:** Mixed — region cause confirmed, deleted-version lock confirmed, create-vs-redeploy divergence observed but not fully verified
**Related:** [concept 20 §3](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#3--the-generic-cloudhub-20-404--three-different-causes-one-message)
**Sample:** [`samples/maven/pom-cloudhub2-deploy-snippet.xml`](../samples/maven/pom-cloudhub2-deploy-snippet.xml)
**Keywords:** cloudhub2, 404, region, deleted-asset, redeploy, deployment-id, exchange

## Scenario
`mvn clean deploy -DmuleDeploy` to CloudHub 2.0 Shared Space, on a trial or standard org, once authentication (Stage 40) is already passing.

## Symptom
```
Caused by: org.mule.tools.client.core.exception.ClientException: 404 Not Found:
{"timestamp":...,"status":404,"error":"Not Found",
"message":"Failed to retrieve artifact information from Exchange.
Reason: 404 There is no asset matching given parameters.",
"path":"/organizations/<orgId>/environments/<envId>/deployments[/<deploymentId>]"}
```
**This is a generic wrapper message reused for at least three unrelated causes.** Diagnose in this order — don't stop at the first plausible-sounding cause.

## Step-by-step fix

### 1. Rule out a region mismatch first
Check whether an **earlier** attempt in your logs showed:
```
400 Bad Request: "Deployment target (located in us-east-1) is not in the
configured default region us-east-2"
```
If so: open Runtime Manager → **Deploy Application**, note the exact Shared Space region name shown there, and set `<target>` in `cloudhub2Deployment` to that exact value — don't assume `us-east-1` from a tutorial. A trial org is typically pinned to one specific region.

### 2. Rule out a deleted-version lock
Check the Runtime Manager UI (try deploying the same jar manually) for:
```
Deploy failed: Cannot create a new asset with the provided groupId, assetId,
version, state - There is a deleted asset with the same version number.
Try creating your new asset with a higher version number.
```
If so: Exchange permanently reserves `groupId+artifactId+version` once anything is published-then-deleted under it, even though it disappears from the UI. Bump the **application's** `<version>` (not the API spec dependency's version — leave that alone):
```xml
<version>1.0.1-SNAPSHOT</version> <!-- was 1.0.0-SNAPSHOT -->
```

### 3. Rule out create-vs-redeploy path divergence
The tell: deploying the exact same jar **manually through the Runtime Manager UI succeeds**, but Maven still 404s, for an app name that already exists in Runtime Manager.
- Maven's deploy goal switches from "create" to "redeploy" once the app name already exists, and the redeploy call resolves the existing deployment differently than a fresh create.
- If that existing deployment record was originally created by a **manual raw-jar UI upload** rather than by Maven/Exchange, it may lack the artifact linkage the redeploy lookup expects.
- Fix: fully delete the app from Runtime Manager (not just stop it), then let Maven create it fresh:
  ```powershell
  anypoint-cli-v4 runtime-mgr:application:list --environment Dev
  anypoint-cli-v4 runtime-mgr:application:delete <app-name> --environment Dev
  # confirm it's gone from the list, THEN:
  mvn clean deploy -DmuleDeploy -Dap.client_id=<id> -Dap.client_secret=<secret>
  ```
- Watch the log immediately after `mule:deploy` starts: a fresh **create** should NOT print `Checking app ... / Redeploying...`. If it still does, the app wasn't fully deleted — check again.

### Don't waste time on this
`<distributionManagement>` pointing at the Exchange Maven Facade is a real prerequisite for spec compliance, but `mule-maven-plugin`'s `deploy` goal talks to the CloudHub 2.0 REST API directly — there is no "Uploading to Repository..." line in the log for this goal. Adding/fixing this block will not resolve this 404 by itself.

## Root cause
Three separate failure types share one error string in the Mule tooling: a region config mismatch, Exchange's permanent lock on deleted GAVs, and a divergence between the "create" and "redeploy" code paths depending on how the existing deployment record was originally created.

## Why it recurs
Region names and shared-space assignment differ per org and aren't always what a tutorial assumes. Deleted-and-retried version numbers are common during iterative development. And any app first deployed manually via the UI (a common "let's just get it up" first step) sets up the redeploy-divergence trap for the first subsequent Maven deploy.

## Once this is fixed
Successful deploy means moving on to Stage 60 for whether the endpoint actually answers correctly: [60](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md).
