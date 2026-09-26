%dw 2.0
output application/json
---
// Minimum standardized shape for every log line across every API, per
// concepts/17-coding-conventions.md ("Structured logging"). Keep this SHAPE
// identical org-wide (correlationId / flow / message) so log aggregation
// (Splunk/Datadog) can query across APIs; the business fields (pnr, orderId,
// ...) differ per API and go alongside the standard ones, not instead of them.
//
// correlationId: Mule sets one per message automatically - log the one that's
// already there (`correlationId`), don't generate a new one per log line.
//
// Do NOT put full request/response payloads or values from secure-*.yaml
// (see samples/mule/secure-properties-encrypt-config.xml) into this shape at
// INFO level - a log aggregator usually has different retention/access rules
// than the API itself.
{
  correlationId: correlationId,
  flow: vars.flowName default "unknown",
  message: "PNR lookup started",
  pnr: attributes.uriParams.PNR
}
