# [Stage 60 · Runtime Networking & TLS Termination] Shared-domain 502, listener still HTTPS + `tls:context`

> **Pipeline position:** 60 — Runtime Networking & TLS Termination (post-deploy) · comes **after** [Stage 50](50-cloudhub2-deploy-generic-404-region-version-redeploy.md) (CloudHub 2.0 Deployment) · next in this stage: [61](61-cloudhub2-last-mile-security-502.md)

**Confidence:** Confirmed
**Related:** [concept 09](../concepts/09-tls-certificates.md) · [concept 20 §5](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#5--cloudhub-20-shared-ingress-and-502s) · [30](30-local-self-signed-tls-certificate-untrusted.md)
**Keywords:** cloudhub, 502, bad-gateway, tls-listener, shared-domain, ingress, load-balancer

## Scenario
The app deployed successfully (Stage 50 passed). Local testing with the same listener config worked over HTTPS; the deployed CloudHub URL does not.

## Symptom
Local: `curl -kv https://localhost:8082/...` succeeds with a full TLS handshake.
CloudHub (`https://check-in-papi-impl-dev-....usa-e2.cloudhub.io/...`): every request returns
```
HTTP/1.1 502 BAD GATEWAY
Content-Length: 0
x-correlation-id: ...
```
despite the public TLS handshake to the LB itself succeeding.

## Step-by-step fix
1. Check `http:listener-config` for the environment actually deployed: does it still declare `protocol="HTTPS"` with a `tlsContext`?
2. If yes, that's the cause. On the standard shared `*.cloudhub.io` domain, CloudHub's own load balancer terminates public TLS and forwards to your worker over **plain HTTP** internally — a listener waiting for a TLS handshake it will never receive 502s at the LB, regardless of whether the cert is valid.
3. Fix the listener for this environment to plain HTTP on the CloudHub-injected port:
   ```xml
   <http:listener-config name="HTTP_Listener_config">
       <http:listener-connection host="0.0.0.0" port="${http.port}" />
   </http:listener-config>
   ```
4. Keep host as `0.0.0.0`, not `localhost` — the listener must accept non-loopback connections.
5. Keep the original HTTPS/`tls:context` listener (from [Stage 30](30-local-self-signed-tls-certificate-untrusted.md)) as a **separate local-only profile** — it's correct for local `curl -k` testing, just not for this deployment target.
6. Redeploy. CloudHub's LB still presents a valid, publicly-trusted HTTPS endpoint externally — only the internal hop changed.
7. If TLS end-to-end is actually a hard requirement, don't revert this fix — go to [61](61-cloudhub2-last-mile-security-502.md) instead.

## Root cause
CloudHub's shared-domain front door always terminates public TLS itself. Your app's listener was configured to expect a TLS handshake it will never receive on that internal hop.

## Why it recurs
Any listener config that was correct for local dev (Stage 30) is, by construction, wrong for a first shared-domain CloudHub deploy unless deliberately paired with Last-Mile Security ([61](61-cloudhub2-last-mile-security-502.md)). This is the single most common "works locally, 502s after deploy" pattern.
