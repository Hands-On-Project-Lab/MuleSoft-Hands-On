# [Stage 30 · Local Run, TLS & Secure Properties] GateKeeper stuck "blocked" in standalone/local runs

> **Pipeline position:** 30 — Local Run, TLS & Secure Properties · previous in this stage: [30](30-local-self-signed-tls-certificate-untrusted.md) · next in this stage: [32](32-secure-properties-userandomivs-decryption-mismatch.md)

**Confidence:** Confirmed
**Related:** [concept 20 §6](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#6--gatekeeper-blocked--exchange-401-after-clearing-m2)
**Keywords:** gatekeeper, api-manager, autodiscovery, client-id-enforcement, standalone, local-run

## Scenario
A Mule 4 Process API running locally in Anypoint Studio (or standalone) fails to unblock its API Gateway policy after startup.

## Symptom
```
WARN  ... Client ID or Client Secret were not provided. API Platform client is DISABLED.
INFO  ... API ApiKey{id='21194630'} is blocked (unavailable).
```

## Step-by-step fix
1. This is unrelated to any Maven/build credential issue (see [20](20-maven-exchange-401-unauthorized-settings-xml.md)) — it's a **runtime** credential.
2. Pass Anypoint Platform client credentials as VM arguments to the running Mule instance:
   ```
   -M-Danypoint.platform.client_id=<your-client-id> -M-Danypoint.platform.client_secret=<your-client-secret>
   ```
3. In Anypoint Studio, set these under the run configuration's VM arguments, not the application arguments.
4. Restart the app. Look for GateKeeper's own unblock message in the log:
   ```
   BlockingGateKeeper ... API ApiKey{id='...'} is now unblocked (available).
   ```
5. If it's still blocked after credentials are supplied, verify the API instance ID in the log matches the one actually registered in API Manager for this app/environment — a mismatched ID (e.g. copy-pasted from a different environment) blocks silently too.

## Root cause
The GateKeeper (API Manager's local policy-enforcement agent) needs its own Anypoint Platform client credentials to validate the API Key against the platform — independent of any Maven/build credentials.

## Why it recurs
Easy to forget on a new machine or fresh Studio workspace, since it isn't stored in the project itself by design (credentials never belong in committed config).
