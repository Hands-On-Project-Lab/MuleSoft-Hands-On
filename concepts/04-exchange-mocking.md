# 04 · Anypoint Exchange & Mocking Service

Exchange is the **asset catalog**: APIs, connectors, templates, RAML fragments. It becomes the single source of truth for consumers.

```mermaid
flowchart TD
  DC[Design Center<br/>author spec] -->|Publish| EX[(Exchange<br/>REST API asset)]
  EX --> V1[Version 1.0.5]
  EX --> V2[Version 1.0.6]
  EX --> V3[Version 1.1.0]
  V3 --> I1[Instance: dev]
  V3 --> I2[Instance: test]
  V3 --> I3[Instance: prod]
  V3 --> MK[Mocking Service endpoint]
  EX --> ST[Studio: download / dependency]
```

## What Exchange gives you

| Feature         | Meaning for AnyAirline                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------------------ |
| Versions        | 1.0.5 → 1.0.6 → 1.1.0, each tracked                                                                    |
| Instances       | Which env (dev/test/prod) runs which version                                                           |
| Live docs       | `PUT /tickets/{PNR}/checkin` browsable with types/examples                                             |
| Mocking         | Call the spec before code exists                                                                       |
| Metadata        | Type, org, author, publish date, visibility (private)                                                  |
| Reuse           | Libraries (`checkin`, `paymentid`, `boardingpass`) imported by other specs; Studio downloads the asset |
| Ratings/reviews | Consumer feedback                                                                                      |

## Semantic versioning cheat-sheet

- **Patch** (1.0.5→1.0.6): doc/example fix, no contract change
- **Minor** (1.0.x→1.1.0): backwards-compatible addition
- **Major** (→2.0.0): breaking change → new API version and instance

![Exchange asset page (your screenshot)](../images/screenshots/concept04-exchange-asset.png)

![Exchange Mocking Service](../images/screenshots/concept04-exchange-mocking.png)

**Do it →** [Lab 01](../labs/lab-01-publish-spec.md) · **← Back** [03](03-design-first-raml-oas.md) · **Next →** [05](05-api-manager-policies.md)
