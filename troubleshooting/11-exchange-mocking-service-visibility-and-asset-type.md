# [Stage 10 · Design & Publish] "Mocking Service tab is missing" on an Exchange asset

> **Pipeline position:** 10 — Design & Publish (Anypoint Exchange) · previous in this stage: [10](10-exchange-spec-vs-application-asset-type-conflict.md) · comes **before** [Stage 20](20-maven-exchange-401-unauthorized-settings-xml.md) (Build & Dependency Resolution)

**Confidence:** Observed platform/UI behaviour — not documented by MuleSoft as a named limitation, verify against your own org
**Related:** [concept 21](../concepts/21-exchange-api-manager-tooling-quirks.md) · [concept 04](../concepts/04-exchange-mocking.md)
**Keywords:** exchange, mocking-service, asset-visibility, private, padlock, design-center

## Scenario
You expect a Mocking Service tab/endpoint on an Exchange asset and don't see one.

## Symptom
No error message — the tab/endpoint is simply absent or shows a padlock icon.

## Step-by-step fix
1. Check which **asset type** you're looking at. Only the REST API **specification** asset (published from Design Center, `rest-api` type) has a Mocking Service tab.
2. A Mule **application** asset (e.g. `check-in-papi-impl`, `mule-application` type — see [10](10-exchange-spec-vs-application-asset-type-conflict.md)) never has this tab — that's expected, not a missing feature. Go to the spec asset instead.
3. If the spec asset itself seems to lack the tab: check its **visibility**. A `Private` spec shows a padlock icon on its instances (including Mocking Service) to other org members — that's an access indicator for teammates, not a broken feature for the owner.
4. If a teammate needs the mock endpoint and hits the padlock, either share the asset with them directly or change its visibility to org-wide.

## Root cause
Mocking Service is a feature of the **specification** asset type only, and asset visibility gates it for other org members the same way it gates everything else about a private asset.

## Why it recurs
Confusing the spec asset with its own implementation asset (both often named almost identically, one with `-impl`) is an easy mistake right after Stage 10's asset-type split.
