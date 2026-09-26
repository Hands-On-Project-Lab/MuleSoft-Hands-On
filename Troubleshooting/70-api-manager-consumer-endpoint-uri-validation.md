# [Stage 70 · API Manager & Consumer-Facing Configuration] "must be a valid URI" on a CloudHub 2.0 endpoint field

> **Pipeline position:** 70 — API Manager & Consumer-Facing Configuration (post-deploy) · comes **after** [Stage 60](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md) (Runtime Networking & TLS Termination) · comes **before** Stage 80 (Tooling & Local Client Testing)

**Confidence:** Observed platform/UI behaviour — not documented by MuleSoft as a named limitation, verify against your own org
**Related:** [concept 21](../concepts/21-exchange-api-manager-tooling-quirks.md)
**Keywords:** api-manager, uri-validation, cloudhub2, autodiscovery, consumer-endpoint, upstream-endpoint

## Scenario
Registering or editing a CloudHub 2.0 API instance in API Manager, entering the app's Shared Space URL into the Consumer or Upstream endpoint field.

## Symptom
API Manager rejects the URL with a client-side validation error: **"must be a valid URI"** — even though the same URL resolves correctly in a browser or via `curl`.

## Step-by-step fix
1. Check whether the CloudHub-generated subdomain's **first label starts with a digit**, e.g. `5sc6y6-2....usa-e2.cloudhub.io`. That's valid DNS but can fail API Manager's stricter client-side regex, which is not the same as DNS validity.
2. If the API instance relies on **Autodiscovery** (see [concept 06](../concepts/06-autodiscovery.md)) rather than a manually-entered implementation URL, both the Consumer and Upstream endpoint fields are optional — leave them blank and move on. Autodiscovery doesn't need them.
3. If a value must be populated (a specific policy or downstream integration requires it), front the app with a vanity/custom domain that doesn't start with a digit, instead of trying to force the auto-generated one through.
4. If you're stuck without a custom domain and Autodiscovery isn't an option, try appending a trailing slash or protocol prefix as a workaround before escalating — client-side regexes vary by API Manager UI version.

## Root cause
API Manager's Consumer/Upstream endpoint fields apply a client-side URI validation regex that is stricter than plain DNS-label validity. A domain label that legitimately starts with a digit (a common shape for CloudHub 2.0's auto-generated Shared Space subdomains) can fail that regex even though it is a completely valid, resolvable hostname.

## Why it recurs
CloudHub 2.0's auto-generated Shared Space domain naming isn't something you control, so any org relying on those default domains (rather than a custom domain) can hit this the first time someone tries to manually wire up an endpoint field instead of relying on Autodiscovery.
