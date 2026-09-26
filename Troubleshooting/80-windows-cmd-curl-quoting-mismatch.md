# [Stage 80 · Tooling & Local Client Testing] Windows `cmd.exe` mangles a `curl -d` JSON body

> **Pipeline position:** 80 — Tooling & Local Client Testing (cross-cutting, applies at any stage) · comes **after** [Stage 70](70-api-manager-consumer-endpoint-uri-validation.md) (API Manager & Consumer-Facing Configuration) · final stage in this taxonomy

**Confidence:** Confirmed — standard `cmd.exe` shell-quoting behaviour, unrelated to MuleSoft
**Related:** [concept 21](../concepts/21-exchange-api-manager-tooling-quirks.md)
**Keywords:** windows, cmd.exe, curl, quoting, powershell, local-testing

## Scenario
Testing a deployed or locally-running API on Windows, using a `curl` command copied from Linux/macOS documentation, a README, or a bash-flavoured tool's export.

## Symptom
The request silently sends the wrong body, or `curl` itself errors on argument parsing, when the exact same command works fine on Linux/macOS.

## Step-by-step fix
1. Recognize the cause first: `cmd.exe` does not interpret single-quoted strings as one token the way bash does — a `'...'`-wrapped JSON body gets torn apart at each internal space/quote.
2. Rewrite the body using escaped double quotes:
   ```cmd
   curl -X PUT "https://<host>/api/v1/tickets/PNR12345/checkin" -H "Content-Type: application/json" -d "{\"PNR\": \"PNR12345\"}" -v
   ```
3. Or sidestep quoting entirely by writing the body to a file and referencing it:
   ```cmd
   curl -X PUT "https://<host>/api/v1/tickets/PNR12345/checkin" -H "Content-Type: application/json" -d @body.json -v
   ```
4. If you're scripting this for local CI or a test harness, pick **one shell** and stay in it — bash, `cmd.exe`, and PowerShell each have different quoting rules, and mixing snippets copied from different sources is what causes this in the first place.
5. In PowerShell specifically, don't assume `cmd.exe` snippets work as-is either — PowerShell has its own quoting rules, different again from both bash and `cmd.exe`.

## Root cause
Shell-level string quoting differs between bash, `cmd.exe`, and PowerShell. A command string built for one shell's quoting rules is not portable to another without rewriting the quoting, regardless of how correct the underlying `curl` flags are.

## Why it recurs
Documentation, blog posts, and AI-generated snippets default to bash-style single quotes because that's the most common target. Anyone testing from a Windows machine without adjusting quoting style hits this on the very first copy-pasted example with a JSON body.
