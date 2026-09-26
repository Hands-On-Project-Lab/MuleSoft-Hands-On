# 21 · Exchange, API Manager & Tooling Quirks _(added)_

📖 **Read first:** [04 Exchange & Mocking](04-exchange-mocking.md) · [16 CloudHub 1.0 vs 2.0 vs RTF](16-cloudhub-rtf-deployment-targets.md)
🎯 **End state:** three small platform behaviours that look like bugs the first time you hit them, aren't, and cost real time if you don't know that going in.

These are **observed platform/UI behaviours**, not documented MuleSoft guarantees — flagged as such rather than stated as official spec, since MuleSoft doesn't publish a page for any of the three.

> **Step-by-step version:** [Stage 11](../troubleshooting/11-exchange-mocking-service-visibility-and-asset-type.md) · [Stage 70](../troubleshooting/70-api-manager-consumer-endpoint-uri-validation.md) · [Stage 80](../troubleshooting/80-windows-cmd-curl-quoting-mismatch.md) in [`troubleshooting/`](../troubleshooting/README.md).

## 1 · Exchange: "Mocking Service tab is missing"

Only the **REST API specification asset** (published from Design Center, `rest-api` type — see [04](04-exchange-mocking.md)) has a Mocking Service tab in Exchange. A Mule **application** asset (the `-impl` you publish per [20 §1](20-cloudhub2-maven-deploy-troubleshooting.md#1--exchange-gav-collision--spec-asset-vs-application-asset)) never has one — that's not a missing feature, it's the wrong asset type to look at.

If the spec asset's own Mocking Service tab looks unavailable, check the asset's **visibility**: a `Private` spec shows a padlock icon on its instances (including Mocking Service) to other members of the org — that's an access indicator, not a broken/disabled feature for the owner. Share the asset or make it org-visible if teammates need the mock endpoint.

## 2 · API Manager: "must be a valid URI" on a CloudHub 2.0 endpoint field

CloudHub 2.0's auto-generated Shared Space subdomains are sometimes structured so the first label starts with a digit (e.g. `5sc6y6-2....usa-e2.cloudhub.io`). That's valid DNS, but it can fail the client-side validation regex on API Manager's Consumer/Upstream endpoint URI fields, which is stricter than plain DNS validity.

Both fields are optional when the API instance relies on **Autodiscovery** ([06](06-autodiscovery.md)) rather than a manually-entered implementation URI — leave them blank. If a value must be populated, front the app with a vanity/custom domain that doesn't start with a digit instead of fighting the field.

## 3 · Windows `cmd.exe` and `curl -d`

Not a MuleSoft issue at all, but it blocks testing on Windows long enough to be worth writing down: `cmd.exe` does not understand single-quoted strings the way bash does. A `curl` command copied from Linux/macOS docs or Postman's bash snippet silently mis-parses the body on `cmd.exe`. Use escaped double quotes, or write the body to a file and reference it:

```cmd
curl -X PUT "https://<host>/api/v1/tickets/PNR12345/checkin" -H "Content-Type: application/json" -d "{\"PNR\": \"PNR12345\"}" -v
```
```cmd
curl -X PUT "https://<host>/api/v1/tickets/PNR12345/checkin" -H "Content-Type: application/json" -d @body.json -v
```
PowerShell has its own quoting rules again (different from both bash and `cmd.exe`) — if scripting CI locally, pick one shell and stay in it rather than mixing snippets from different sources.

**Related:** [20 CloudHub 2.0 Maven deploy: field notes](20-cloudhub2-maven-deploy-troubleshooting.md)
