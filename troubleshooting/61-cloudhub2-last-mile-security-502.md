# [Stage 60 · Runtime Networking & TLS Termination] 502 even with a correct listener, when TLS end-to-end is required

> **Pipeline position:** 60 — Runtime Networking & TLS Termination (post-deploy) · previous in this stage: [60](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md) · comes **before** [Stage 70](70-api-manager-consumer-endpoint-uri-validation.md) (API Manager & Consumer-Facing Configuration)

**Confidence:** Confirmed — `lastMileSecurity` verified as a real, documented `cloudhub2Deployment` setting
**Related:** [concept 20 §5](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#5--cloudhub-20-shared-ingress-and-502s)
**Sample:** [`samples/maven/pom-cloudhub2-deploy-snippet.xml`](../samples/maven/pom-cloudhub2-deploy-snippet.xml)
**Keywords:** cloudhub2, last-mile-security, 502, mutual-tls, deploymentSettings, ingress

## Scenario
Same 502 as [60](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md), but the app intentionally needs to keep its own TLS listener (e.g. mutual TLS, or a compliance requirement for TLS all the way to the worker) and reverting to plain HTTP isn't an acceptable fix.

## Symptom
```
HTTP/1.1 502 BAD GATEWAY
Content-Length: 0
```
— clean internal startup logs, listener intentionally still HTTPS + `tlsContext`.

## Step-by-step fix
1. Confirm **Last-Mile Security** is enabled for this app: Runtime Manager → app → **Settings** → enable **Last-Mile Security** → **Apply Changes** (this triggers a redeploy with a new config hash).
2. Or set it directly in the Maven deploy config:
   ```xml
   <cloudhub2Deployment>
     ...
     <deploymentSettings>
       <http>
         <inbound>
           <lastMileSecurity>true</lastMileSecurity>
         </inbound>
       </http>
     </deploymentSettings>
   </cloudhub2Deployment>
   ```
3. Keep the app's own `tls:context`/HTTPS listener in place for this path — Last-Mile Security is what makes CloudHub forward over HTTPS all the way to the worker instead of terminating and re-issuing as plain HTTP.
4. This setting only applies to the shared `cloudhub.io` domain. It's irrelevant (not needed, not harmful) with a Dedicated Load Balancer, a custom domain with SSL passthrough, or RTF — those already pass TLS through unterminated.

## Root cause
Whether the *internal* hop from CloudHub's ingress to your worker is plain HTTP (default) or HTTPS (only with Last-Mile Security explicitly enabled) is independent of whether your app started up cleanly.

## Why it recurs
Teams that need end-to-end TLS for compliance reasons often don't know this flag exists, and instead either force plain HTTP (breaking the requirement) or spend time debugging flow logic for a 502 that clean startup logs already rule out.
