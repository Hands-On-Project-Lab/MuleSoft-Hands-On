# [Stage 30 · Local Run, TLS & Secure Properties] `useRandomIVs` mismatch between encrypting tool and runtime config

> **Pipeline position:** 30 — Local Run, TLS & Secure Properties · previous in this stage: [31](31-gatekeeper-blocked-missing-platform-credentials.md) · next in this stage: [33](33-secure-properties-encryption-key-unresolved.md)

**Confidence:** Confirmed — `useRandomIVs` semantics verified against MuleSoft's Secure Configuration Properties reference
**Related:** [concept 20 §4](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#4--secure-propertiesencrypt-userandomivs--the-tool-must-match-the-runtime-setting) · [concept 13](../concepts/13-properties-secrets.md)
**Sample:** [`samples/mule/secure-properties-encrypt-config.xml`](../samples/mule/secure-properties-encrypt-config.xml)
**Keywords:** secure-properties, useRandomIVs, encryption, blowfish, keystore, BadPaddingException

## Scenario
Secure properties (e.g. a TLS keystore password) fail to decrypt at startup, even after re-verifying the key, plaintext, and algorithm are all correct.

## Symptom
```
ERROR ... Unable to initialise TLS configuration
java.security.UnrecoverableKeyException: failed to decrypt safe contents entry:
javax.crypto.BadPaddingException: Given final block not properly padded.
Such issues can arise if a bad key is used during decryption.
...
Caused by: java.io.IOException: keystore password was incorrect
```

## Step-by-step fix
1. Find whichever tool generated the ciphertext currently sitting in `*-secure.yaml`.
2. **If it's MuleSoft's hosted Secure Properties web tool** (`secure-properties-api-ch.*.cloudhub.io`): it never prepends a random IV, regardless of what your app's config says. Your `globalConfiguration.xml` must declare:
   ```xml
   <secure-properties:config file="${mule.env}-secure.yaml" key="${encryption.key}">
     <secure-properties:encrypt useRandomIVs="false"/>
   </secure-properties:config>
   ```
   (`false` is the default — the attribute can also be omitted.) No change to the existing `*-secure.yaml` ciphertext is needed once the config matches.
3. **If you actually want random IVs** (better practice against key reuse across multiple values): stop using the hosted web tool. Re-encrypt using Anypoint Studio's built-in **Encrypt Value** action, or `secure-properties-tool.jar` with its random-IV option — both correctly prepend the IV — then set `useRandomIVs="true"` to match.
4. Redeploy/restart after the config change; no rebuild of the ciphertext values is needed for the `useRandomIVs="false"` path.

## Root cause
`useRandomIVs` changes the ciphertext's byte layout itself. `true` means the runtime expects an IV block prepended and strips it before decrypting; `false` means no prepended IV and a fixed key-derived IV instead. Mismatching the setting against the tool that produced the ciphertext corrupts every decrypted block.

## Why it recurs
Whenever a team switches secure-properties tooling (web tool → Studio action, or vice versa) without also flipping `useRandomIVs`.
