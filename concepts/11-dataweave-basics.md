# 11 · DataWeave Basics *(added)*

DataWeave is Mule's transformation language: input payload → output payload.

```dw
%dw 2.0
output application/json
---
{
  pnr: attributes.uriParams.PNR,
  status: "CHECKED_IN",
  checkedInAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}
}
```

## Anatomy

| Part | Example |
|---|---|
| Header | `%dw 2.0`, `output application/json`, `import`, `var`, `fun` |
| `---` | separator |
| Body | expression that produces the output |

## Selectors and operators

| Need | DW |
|---|---|
| Field | `payload.name` |
| URI param | `attributes.uriParams.PNR` |
| Query param | `attributes.queryParams.seat` |
| Header | `attributes.headers.'client_id'` |
| Map array | `payload map (p) -> { id: p.id }` |
| Filter | `payload filter ($.status == "OK")` |
| Default | `payload.seat default "UNASSIGNED"` |
| Conditional | `if (x > 1) "a" else "b"` |
| Variable | `vars.myVar` |

## Typical AnyAirline transformations

1. Request JSON → SOAP body for Flights Management
2. DB rows (PostgreSQL) → `CheckInResult` JSON
3. Error → `{ "message": ... }` payload

Samples live in `samples/dataweave/`.

**← Back** [10](10-apikit-flow-design.md) · **Next →** [12 Error Handling](12-error-handling.md)
