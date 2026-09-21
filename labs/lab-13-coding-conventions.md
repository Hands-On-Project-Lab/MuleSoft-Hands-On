# Lab 13 · Apply Coding Conventions to check-in-papi

📖 **Read first:** [17 Coding Conventions](../concepts/17-coding-conventions.md)
🎯 **End state:** duplicated logic extracted to a sub-flow, naming conventions verified, formatter applied, MUnit still green.

## Steps

### 1. Find duplicated logic
Look for the same validation/error-response processors repeated in two flows in `main.xml`.
![Lab13-1](../images/screenshots/lab13-step01-duplicated-logic.png)

### 2. Extract to flow
Select the repeated processors → right-click → **Extract to flow** → name it `validate-request` (kebab-case).
![Lab13-2](../images/screenshots/lab13-step02-extract-to-flow.png)

### 3. Verify naming conventions
- Flow/sub-flow names: kebab-case (`check-in-by-pnr`, `validate-request`)
- Global element names: camelCase (`apiHttpListenerConfig`)
- Config files unchanged: `api.xml`, `main.xml`, `global.xml`, `error.xml`
![Lab13-3](../images/screenshots/lab13-step03-naming-check.png)

### 4. Rename a flow and confirm flow-ref auto-updates
Rename any non-APIkit-generated flow via **Rename flow**; confirm every `<flow-ref>` updated automatically.
![Lab13-4](../images/screenshots/lab13-step04-rename-flow.png)

### 5. Run the Eclipse formatter
Format the touched files; confirm no unrelated diff noise.
![Lab13-5](../images/screenshots/lab13-step05-formatter.png)

### 6. Re-run MUnit
```bash
mvn test
```
Confirm the same assertions from [Lab 06](lab-06-munit.md) still pass after the refactor.
![Lab13-6](../images/screenshots/lab13-step06-munit-green.png)

## ✅ Verify
Sub-flow exists, is referenced from both call sites, naming matches convention, MUnit green.

## 🧠 Self-check
1. Why must APIkit-generated flow names never be renamed?
2. What breaks silently if you skip re-running MUnit after a flow-ref-changing refactor?

**Next →** [Lab 14](lab-14-maven-parameterize-deploy.md)
