%dw 2.0
output application/json
---
{
  pnr: attributes.uriParams.PNR,
  status: "CHECKED_IN",
  checkedInAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}
}
