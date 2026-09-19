# 10 · APIkit & Flow Design *(added: not in deck)*

APIkit turns the RAML into **Mule flows** and enforces the contract at runtime.

```mermaid
flowchart LR
  L[HTTP Listener] --> R[APIkit Router]
  R -->|validates request vs RAML| F1[put:\tickets\PNR\checkin:application/json]
  R -->|no match| E1[APIKIT:NOT_FOUND → 404]
  R -->|bad body| E2[APIKIT:BAD_REQUEST → 400]
```

## Generated structure

| Flow | Role |
|---|---|
| `check-in-papi-main` | Listener + APIkit router + error handlers (**autodiscovery `flowRef`** points here) |
| `check-in-papi-console` | Optional API Console |
| `put:\tickets\(PNR)\checkin:application\json:check-in-papi-config` | Your business logic for that method+resource |

Flow name = `method:\resource:contentType:configName`.

## Recommended layering

```mermaid
flowchart TD
  M[main flow: listener, router] --> I[implementation flow per operation]
  I --> S1[sub-flow: validate + map input]
  I --> S2[sub-flow: call Flights Mgmt SOAP]
  I --> S3[sub-flow: call Passenger Data DB]
  I --> S4[sub-flow: build response DataWeave]
```

Rules of thumb: keep operation flows thin; reusable logic in sub-flows; connectors' configs global; no hardcoded values.

## Local test

Run app → `http://localhost:8081/api/...`. Use Postman/curl. See [Lab 03](../labs/lab-03-implement-apikit.md).

**Next →** [11 DataWeave](11-dataweave-basics.md)
