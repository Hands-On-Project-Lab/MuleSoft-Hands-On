# [Stage 30 · Local Run, TLS & Secure Properties] `${encryption.key}` never actually resolves

> **Pipeline position:** 30 — Local Run, TLS & Secure Properties · previous in this stage: [32](32-secure-properties-userandomivs-decryption-mismatch.md) · comes **before** [Stage 40](40-cloudhub2-connected-app-business-group-not-valid.md) (CI/CD Authentication)

**Confidence:** Confirmed — standard Maven/shell environment-variable scoping behaviour
**Related:** [concept 20 §4](../concepts/20-cloudhub2-maven-deploy-troubleshooting.md#4--secure-propertiesencrypt-userandomivs--the-tool-must-match-the-runtime-setting) · [concept 13](../concepts/13-properties-secrets.md)
**Keywords:** secure-properties, encryption-key, env-var, settings.xml, PropertyNotFoundException, deployment-timeout

## Scenario
The encryption key needed to decrypt secure properties is set as an OS environment variable but never actually reaches the running app.

## Symptom
```
PropertyNotFoundException: Couldn't find configuration property value for key ${encryption.key}
```
followed, on CloudHub, by:
```
[ERROR] Failed to deploy check-in-papi-impl-dev: Validation timed out waiting for application to start.
Caused by: java.util.concurrent.TimeoutException: Maximum number of attempts [10] has been exceeded.
```

## Step-by-step fix
1. **Verify the OS environment variable is actually set in the process that runs Maven**, not just in a different shell/window. On Windows, `$env:VAR = ...` in PowerShell is process-local; a separate `cmd.exe` window running `mvn deploy` never sees it. Use `setx` for a persistent value, then **close and reopen the terminal**:
   ```cmd
   setx MULE_ENCRYPTION_KEY "your-key-here"
   ```
2. **Always pass the project's `settings.xml` explicitly** if it defines the profile mapping `encryption.key` to the env var:
   ```cmd
   mvn clean deploy -DmuleDeploy -Pch2,dev,anypoint -s settings.xml
   ```
   Without `-s`, Maven silently falls back to `~/.m2/settings.xml`, which won't have your project's profile.
3. **Verify before deploying, not after a 10-minute timeout:**
   ```cmd
   mvn help:evaluate -Dexpression=env.MULE_ENCRYPTION_KEY -q -DforceStdout
   mvn help:evaluate -Dexpression=encryption.key -Pch2,dev,anypoint -s settings.xml -q -DforceStdout
   ```
   Both must print the real key — not blank, not the literal string `${encryption.key}`.
4. Only once both commands print the real key, re-run the deploy.

## Root cause
Maven does not error on an unresolved `${env.X}` — it silently becomes empty. The build and Exchange publish succeed either way; only the running app, trying to use the (empty) key, fails — and only at runtime.

## Why it recurs
On any new machine, new CI runner, or shell change — nothing in source control enforces that the env var and the `-s settings.xml` flag are both present, so the build "succeeding" gives false confidence right up until deploy validation times out.
