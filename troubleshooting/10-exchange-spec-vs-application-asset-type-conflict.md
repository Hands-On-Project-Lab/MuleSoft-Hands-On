# [Stage 10 · Design & Publish] Exchange rejects publish: spec vs. application asset type conflict

> **Pipeline position:** 10 — Design & Publish (Anypoint Exchange) · comes **before** [Stage 20](20-maven-exchange-401-unauthorized-settings-xml.md) (Build & Dependency Resolution) · next in this stage: [11](11-exchange-mocking-service-visibility-and-asset-type.md)

**Confidence:** Confirmed (reproduced; matches Exchange's documented type-per-GAV model)
**Related:** [concept 20 §1](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#1--exchange-gav-collision--spec-asset-vs-application-asset) · [concept 04](../concepts/04-exchange-mocking.md)
**Keywords:** exchange, gav, rest-api, mule-application, asset-type, publish, design-center

## Scenario
You published a RAML/OAS spec to Exchange from Design Center. You now try to `mvn clean deploy` the Mule application that *implements* that spec, using the **same** `groupId:artifactId:version`.

## Symptom
```
[ERROR] Exchange publication failed: Publication ended with errors:
[The asset is invalid, Error while trying to set type: app. Expected type is: rest-api.]
```

## Step-by-step fix
1. Open the implementation project's `pom.xml`.
2. Confirm the `<groupId>` matches your org ID (that part is fine to share) but the `<artifactId>` is identical to the API spec project's — that's the conflict.
3. Rename the implementation project's `<artifactId>`, appending `-impl` (or your org's own suffix convention):
   ```xml
   <groupId>713ed815-e409-4a51-9ef2-7a71017fa06e</groupId>
   <artifactId>check-in-papi-impl</artifactId>
   <version>1.0.0</version>
   <packaging>mule-application</packaging>
   ```
4. Update any `<distributionManagement>`/Exchange-facing references that assumed the old artifactId.
5. Re-run `mvn clean deploy`. The app now publishes as its own `mule-application` asset, separate from the `rest-api` spec asset.
6. Update Autodiscovery / API Manager instance config if it referenced the old artifact coordinates anywhere.

## Root cause
Exchange asset type is fixed per GAV the first time something is published under it. A `rest-api` spec asset and a `mule-application` implementation asset are different types — reusing the exact GAV for both is rejected, not merged.

## Why it recurs
Any time a new API is scaffolded by copying an existing project's `pom.xml` without also renaming the artifactId, if the spec was published first under that name, the implementation's first deploy will hit this. Bake `-impl` (or equivalent) into your project-naming convention from the start.
