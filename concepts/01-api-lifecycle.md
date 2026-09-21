# 01 · The Full API Lifecycle

**Goal:** know where each Anypoint tool fits, and which part this repo covers.

## The 8 phases

```mermaid
flowchart LR
  D[1 Design] --> P[2 Prototype] --> V[3 Validate] --> PB[4 Publish]
  PB --> DEV[5 Develop] --> T[6 Test] --> DP[7 Deploy] --> O[8 Operate]
  O -. feedback .-> D
```

| Phase     | Tool                         | What you do                     |
| --------- | ---------------------------- | ------------------------------- |
| Design    | API Designer (Design Center) | Write the RAML/OAS contract     |
| Prototype | Mocking Service              | Live mock before any code       |
| Validate  | API Console                  | Consumers give feedback on spec |
| Publish   | Exchange & API Portals       | Discoverable assets + docs      |
| Develop   | Anypoint Studio              | Build Mule apps                 |
| Test      | MUnit                        | Unit + integration tests        |
| Deploy    | Runtime Manager              | CloudHub / on-prem              |
| Operate   | API Manager & Analytics      | Policies, SLAs, monitoring      |

![Anypoint lifecycle](../images/general/general-anypoint-api-lifecycle.png)

## Scope of this repo

The AnyAirline APIs are **already designed and published**, so we focus on **Develop + Test**, plus the surrounding pieces you need to make that real (publish walkthrough, governance, TLS, networking, deploy).

## AnyAirline system landscape

```mermaid
flowchart LR
  M[Mobile app] --> X[Check-In Experience API]
  X --> P[Check-In PAPI<br/>PUT /tickets/PNR/checkin]
  P --> F[Flights Management<br/>on-prem SOAP, mutual TLS]
  P --> PD[Passenger Data<br/>on-prem PostgreSQL]
```

**Next →** [02 REST & Richardson](02-rest-richardson.md)
