# [Stage 40 · CI/CD Authentication] CloudHub 2.0 deploy: "Cannot get the environment, the business group is not valid"

> **Pipeline position:** 40 — CI/CD Authentication (Connected Apps) · comes **after** [Stage 30](30-local-self-signed-tls-certificate-untrusted.md) (Local Run, TLS & Secure Properties) · comes **before** [Stage 50](50-cloudhub2-deploy-generic-404-region-version-redeploy.md) (CloudHub 2.0 Deployment)

**Confidence:** Confirmed (root cause verified end-to-end in this repo's own session)
**Related:** [concept 20 §2](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#2--connected-app-scopes--the-misleading-business-group-is-not-valid)
**Sample:** [`samples/maven/pom-cloudhub2-deploy-snippet.xml`](../samples/maven/pom-cloudhub2-deploy-snippet.xml)
**Keywords:** cloudhub2, connected-app, business-group, scopes, client-credentials, oauth

## Scenario
Deploying via `mvn clean deploy -DmuleDeploy -Pch2,dev,anypoint`, using a `cloudhub2Deployment` config with `client_credentials` auth.

## Symptom
```
[ERROR] Failed to execute goal org.mule.tools.maven:mule-maven-plugin:4.10.0:deploy (default-deploy) on project check-in-papi: Execution default-deploy of goal org.mule.tools.maven:mule-maven-plugin:4.10.0:deploy failed: Cannot get the environment, the business group is not valid -> [Help 1]
```

## Step-by-step fix

**Step 1 — check the element name before the value.**
```xml
<!-- WRONG: an ID inside <businessGroup> is schema-valid but resolves to nothing -->
<businessGroup>713ed815-e409-4a51-9ef2-7a71017fa06e</businessGroup>

<!-- RIGHT: an ID goes in businessGroupId -->
<businessGroupId>713ed815-e409-4a51-9ef2-7a71017fa06e</businessGroupId>
```
`<businessGroup>` expects a `Parent\Sub\Org` **path string**, not a raw ID.

**Step 2 — if the element was already correct, stop looking at the business group and go straight to the Connected App's scopes.** This is the confirmed actual cause in the overwhelming majority of cases:
1. Anypoint Platform → **Access Management** → **Connected Apps** → your CI/CD app.
2. Check **Scopes**. Confirm both are granted:
   - `View Organization`
   - `View Environment`
3. If either is missing, add it, save, and re-run the deploy immediately — the plugin requests a fresh token every run, so no local config change is needed.

**Step 3 — check scope coverage per environment, not just presence.** Open the scope's **Manage** detail (not just the checkbox) and confirm it's granted for the *specific* environment you're deploying to (`Dev`, in this example) — a scope granted for `Prod`/`Sandbox` only reproduces this exact error for `Dev` deploys alone.

**Step 4 — once this error clears, expect a new one to appear** (this is progress, not a regression): a `403` on `.../privatespaces/supportedregions` means `Create Applications` (and friends) also need to be granted for that environment — this is where Stage 40 hands off to Stage 50, [50](50-cloudhub2-deploy-generic-404-region-version-redeploy.md).

## Root cause
The Connected App used for `client_credentials` auth lacked the read scopes needed for the plugin's org/environment lookup calls. The business group ID and environment name can be completely correct — the app simply can't read them back to confirm they're valid, and the plugin reports that as "not valid" rather than "access denied."

## Why it recurs
Anyone provisioning a *new* Connected App for a pipeline, or cloning an existing pipeline's config into a new environment, will hit this if they copy the deploy scopes but forget the read scopes — deploy scopes feel sufficient but aren't.
