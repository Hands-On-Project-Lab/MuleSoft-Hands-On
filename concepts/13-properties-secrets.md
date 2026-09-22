# 13 · Properties, Environments & Secure Properties _(added)_

## Per-environment config

```
src/main/resources/
  config-dev.yaml     # non-secret values for dev
  config-test.yaml
  config-prod.yaml
  secure-dev.yaml     # encrypted values, safe to commit
```

```xml
<configuration-properties file="config-${mule.env}.yaml"/><!--  -->
<secure-properties:config name="Secure_Props" file="secure-${mule.env}.yaml" key="${mule.key}">
  <secure-properties:encrypt algorithm="Blowfish" />
</secure-properties:config>
```

`mule.env` = `dev`/`test`/`prod`, set in Studio run config or in Runtime Manager properties.
`mule.key` = encryption key, passed **at runtime only**, never committed.

> Externalising to a property file removes hardcoding, but not _duplication_ — values a Maven dependency and the runtime both need (the API spec's groupId/artifactId/version) still appear twice. Maven resource filtering collapses them to one; because Mule and Maven both use `${…}`, filtering must be switched to `@…@` delimiters first. See [19 Parameterization, Parent POM &amp; BOM](19-parent-pom-bom-parameterization.md).

## Using them

- Plain: `${https.port}`, `${api.id}`
- Secure: `${secure::anypoint.platform.client_secret}`

## Encrypting a value

Use Anypoint Secure Properties tool (jar from MuleSoft docs):

```
java -cp secure-properties-tool.jar com.mulesoft.tools.SecurePropertiesTool \
  string encrypt Blowfish CBC <key> "<value>"
```

Result goes in yaml as `"![encryptedText]"`.

## What must be secret

Client secret, keystore password, truststore password, DB password, SOAP credentials. **Keystore files** live under `src/main/resources` but are **never committed** for real environments (see `.gitignore`).

## Env matrix

| Setting       | dev           | test        | prod      |
| ------------- | ------------- | ----------- | --------- |
| Load balancer | SLB           | SLB         | DLB       |
| Cert          | self-signed   | self-signed | CA-signed |
| Credentials   | dev org creds | test        | prod      |
| `api.id`      | dev instance  | test        | prod      |

**Used by** [06 Autodiscovery](06-autodiscovery.md) · **Do it →** [Lab 05](../labs/lab-05-autodiscovery-secure-props.md)
