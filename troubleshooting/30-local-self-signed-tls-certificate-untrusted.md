# [Stage 30 · Local Run, TLS & Secure Properties] Local self-signed cert rejected without `curl -k`

> **Pipeline position:** 30 — Local Run, TLS & Secure Properties · comes **after** [Stage 20](20-maven-exchange-401-unauthorized-settings-xml.md) (Build & Dependency Resolution) · next in this stage: [31](31-gatekeeper-blocked-missing-platform-credentials.md)

**Confidence:** Confirmed
**Related:** [concept 09](../concepts/09-tls-certificates.md) · [concept 20 §5](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#5--cloudhub-20-shared-ingress-and-502s)
**Keywords:** tls, ssl-handshake, self-signed, keystore, curl, local-dev

## Scenario
Local development of a Mule app exposing an HTTPS endpoint via an HTTP Listener with a self-signed PKCS12 keystore.

## Symptom
```
ERROR ... MuleSslFilter: SSL handshake error: Received fatal alert: certificate_unknown
```
`curl -i https://localhost:8082/...` fails; `curl -k -i https://localhost:8082/...` succeeds.

## Step-by-step fix
1. This is expected, not a bug — a self-signed cert has no chain to a trusted CA, so an unmodified client will always reject it.
2. For local dev, keep using `-k` (or your HTTP client's "trust all"/"skip verification" setting). Acceptable here because client and server are the same machine.
3. Confirm the keystore itself is sound (a separate check from the trust issue):
   ```bash
   keytool -v -genkeypair -keyalg RSA \
     -dname "CN=localhost, OU=Training, O=MuleSoft, C=US" \
     -ext "SAN=DNS:localhost,IP:127.0.0.1" \
     -validity 365 -alias server \
     -keystore check-in-papi-dev.p12 -storetype pkcs12 \
     -storepass "<choose-a-password>"
   ```
   `-ext SAN=...` matters — modern clients (curl included) check the SAN, not just the older `CN` field.
4. Do **not** carry this listener config (HTTPS + `tls:context`) forward to a shared-domain CloudHub deployment — see [60](../troubleshooting/60-cloudhub-shared-domain-502-listener-protocol-mismatch.md) in Stage 60.

## Root cause
No client outside the machine that generated a self-signed certificate has any reason to trust it — TLS's authentication step correctly fails.

## Why it recurs
It's the correct, expected behaviour of TLS — the "fix" is knowing when `-k` is an acceptable bypass (local-only) versus when it masks a real problem (anything reachable by someone else).
