# 05 · API Manager, Policies, Gateways & Enforcement Patterns

## What it is

API Manager **registers an API instance**, applies **policies** (non-functional rules), and Analytics reports traffic. It works at the **HTTP layer**: HTTP/1.x REST, SOAP, generic HTTP. **Not** WebSocket or HTTP/2.

Because RAML/OAS lists every resource and method, policies can be scoped **per resource** (e.g. only `PUT /tickets/{PNR}/checkin`), in addition to endpoint-level policies.

## Common policies

| Policy | Purpose |
|---|---|
| Client ID Enforcement | Caller must send `client_id` / `client_secret` from a contract |
| Rate limiting / SLA tiers | Cap calls, return `429` |
| Message logging | Audit trail (automated policy = applied to all APIs in env) |
| IP allowlist | Restrict networks |
| JWT / OAuth | Token-based identity |

**Client ID enforcement flow**

```mermaid
sequenceDiagram
  participant C as Consumer (Mobile)
  participant G as Gateway (policy)
  participant A as Check-In PAPI
  C->>G: PUT /tickets/ABC123/checkin + client_id/secret
  G->>G: Validate contract in API Manager
  alt valid
    G->>A: forward request
    A-->>C: 200
  else invalid
    G-->>C: 401
  end
```

## Who enforces? (Gateway runtime per API instance)

| Gateway | Runs | Use when |
|---|---|---|
| **Mule Gateway** (default) | Embedded in the Mule runtime | Mule apps, widest policy set incl. resource-level |
| **Omni Gateway** (was Flex) | Envoy-based standalone: Linux/Docker/K8s | Non-Mule APIs, ingress; also LLM/MCP/agent traffic |
| **Service Mesh** | Istio sidecars | Microservices in Kubernetes |

## Proxy vs Basic Endpoint

```mermaid
flowchart LR
  subgraph Proxy
    C1[Consumer] --> PX[API Proxy app<br/>policies here] --> I1[Any HTTP backend]
  end
  subgraph Basic endpoint
    C2[Consumer] --> I2[Mule app + embedded gateway<br/>policies here]
  end
  AM[API Manager] -. policies .-> PX
  AM -. policies via autodiscovery .-> I2
```

| | Proxy | Basic endpoint |
|---|---|---|
| Backend | Any (non-Mule ok) | Must be Mule app |
| Extra worker | Yes | No |
| Policy delivery | Proxy app | Downloaded at runtime to the app |

**AnyAirline:** Check-In PAPI uses **basic endpoint**; proxies front the non-Mule Flights Management and Passenger Data systems.

![API Manager instance (your screenshot)](../images/screenshots/concept05-api-manager-instance.png)

**Do it →** [Lab 02](../labs/lab-02-api-instance-policy.md) · **Then** [06 Autodiscovery](06-autodiscovery.md) · **← Back** [04](04-exchange-mocking.md)
