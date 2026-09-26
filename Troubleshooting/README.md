# 🩺 Troubleshooting

Scenario-based runbooks arranged **in the order you actually hit them** while taking check-in-papi from a RAML spec to a running CloudHub 2.0 deployment — not alphabetically, not by MuleSoft component. Each file is a self-contained unit: **exact Symptom → numbered Step-by-step fix → Root cause → Why it recurs**, so you can jump straight to the one matching your error text.

This is the step-by-step companion to the narrative write-ups in
[`concepts/20`](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md) and
[`concepts/21`](../concepts/21-exchange-api-manager-tooling-quirks.md) — read
those for the *why* in depth; come here mid-incident for the *what do I do
right now*.

## Pipeline sequence

```mermaid
flowchart LR
  S10["10 · Design & Publish\n(Exchange)"] --> S20["20 · Build & Dependency\nResolution (Maven)"]
  S20 --> S30["30 · Local Run, TLS &\nSecure Properties"]
  S30 --> S40["40 · CI/CD Authentication\n(Connected Apps)"]
  S40 --> S50["50 · CloudHub 2.0\nDeployment"]
  S50 --> S60["60 · Runtime Networking &\nTLS Termination"]
  S60 --> S70["70 · API Manager &\nConsumer-Facing Config"]
  S70 --> S80["80 · Tooling & Local\nClient Testing"]
```

Stage 80 is marked cross-cutting because its issue (shell quoting) can bite at any point you're testing from Windows — it's placed last only because that's typically when you're actively poking the API with `curl`.

## Index — every file, in sequence

| # | Stage | File | One-line symptom |
| --- | --- | --- | --- |
| 10 | Design & Publish | [10-exchange-spec-vs-application-asset-type-conflict.md](10-exchange-spec-vs-application-asset-type-conflict.md) | Exchange publish fails: "Expected type is: rest-api" |
| 11 | Design & Publish | [11-exchange-mocking-service-visibility-and-asset-type.md](11-exchange-mocking-service-visibility-and-asset-type.md) | Mocking Service tab missing / padlocked |
| 20 | Build & Dependency Resolution | [20-maven-exchange-401-unauthorized-settings-xml.md](20-maven-exchange-401-unauthorized-settings-xml.md) | Maven 401 resolving an Exchange dependency |
| 30 | Local Run, TLS & Secure Properties | [30-local-self-signed-tls-certificate-untrusted.md](30-local-self-signed-tls-certificate-untrusted.md) | `certificate_unknown` locally without `curl -k` |
| 31 | Local Run, TLS & Secure Properties | [31-gatekeeper-blocked-missing-platform-credentials.md](31-gatekeeper-blocked-missing-platform-credentials.md) | GateKeeper stuck "blocked (unavailable)" |
| 32 | Local Run, TLS & Secure Properties | [32-secure-properties-userandomivs-decryption-mismatch.md](32-secure-properties-userandomivs-decryption-mismatch.md) | `BadPaddingException` / `UnrecoverableKeyException` with a correct key |
| 33 | Local Run, TLS & Secure Properties | [33-secure-properties-encryption-key-unresolved.md](33-secure-properties-encryption-key-unresolved.md) | `PropertyNotFoundException` for `${encryption.key}` |
| 40 | CI/CD Authentication | [40-cloudhub2-connected-app-business-group-not-valid.md](40-cloudhub2-connected-app-business-group-not-valid.md) | "the business group is not valid" |
| 50 | CloudHub 2.0 Deployment | [50-cloudhub2-deploy-generic-404-region-version-redeploy.md](50-cloudhub2-deploy-generic-404-region-version-redeploy.md) | Generic 404 "no asset matching given parameters" |
| 60 | Runtime Networking & TLS Termination | [60-cloudhub-shared-domain-502-listener-protocol-mismatch.md](60-cloudhub-shared-domain-502-listener-protocol-mismatch.md) | 502 on shared domain, listener still HTTPS |
| 61 | Runtime Networking & TLS Termination | [61-cloudhub2-last-mile-security-502.md](61-cloudhub2-last-mile-security-502.md) | 502 even with a correct listener |
| 70 | API Manager & Consumer-Facing Config | [70-api-manager-consumer-endpoint-uri-validation.md](70-api-manager-consumer-endpoint-uri-validation.md) | "must be a valid URI" on a CH2 subdomain |
| 80 | Tooling & Local Client Testing | [80-windows-cmd-curl-quoting-mismatch.md](80-windows-cmd-curl-quoting-mismatch.md) | `curl -d` body mangled on `cmd.exe` |

## Naming & numbering convention (read this before adding a new file)

This exists so a new scenario — yours or one I write from further context you give me — slots in without renumbering everything else.

1. **Filename shape:** `NN-topic-symptom-slug.md` — two-digit stage number, hyphen, then a short slug naming the *topic and symptom*, not a generic label. `secure-properties-userandomivs-decryption-mismatch`, not `secure-props-issue-2`.
2. **Stage number (tens digit) = where it sits in the pipeline**, picked from the table above. A new *stage* (something that doesn't fit 10–80) gets the next multiple of 10 (`90`, `100`, ...) appended to the pipeline diagram and this table — don't renumber existing stages to insert one in the middle.
3. **Sub-sequence number within a stage** = the next unused integer after the stage's tens digit (Stage 30 already runs 30/31/32/33 → a fifth Stage-30 scenario becomes `34`). Order within a stage should still reflect *when in that stage* you'd hit it, same as across stages.
4. **Every file's header carries a `Pipeline position` line** (previous/next in stage, comes-after/comes-before neighbouring stages) — copy the pattern from any existing file and update the two neighbours' files too, so the chain stays walkable in both directions without needing this index open.
5. **Every file states a `Confidence` line** — `Confirmed` (checked against official MuleSoft docs or independently reproduced end-to-end) or `Observed` (real, but not documented by MuleSoft — flag it so it gets re-verified against the reader's own version/org before being trusted blindly).
6. **`Related` and `Sample` lines** point back to the matching `concepts/` narrative and any `samples/` file backing it — add both when they exist rather than inlining large config blocks a second time.
7. **`Keywords` line** — lowercase, hyphenated, comma-separated terms an LLM or search would match this file on (error type, component, platform). Not the same as the slug; more exhaustive.

When you bring further context (a new error, a new platform quirk, a correction to one of these), the fastest way to fold it in is: tell me which stage it belongs to (or describe the scenario and let me place it), and whether it confirms, corrects, or adds a new cause to an existing file versus needing a new one — the taxonomy above is built so either path is a small, localized edit.
