# Lab 07 · Deploy to CloudHub

📖 **Read first:** [15 Deploy & Operate](../concepts/15-deploy-operate.md) · [07 Networking](../concepts/07-networking-cloudhub.md)
🎯 **End state:** app reachable through the shared LB; policies enforced.

## Steps
### 1. Deploy from Studio (manual) to `dev`
![Lab07-1](../images/screenshots/lab07-step01-deploy-dialog.png)
### 2. Set properties in Runtime Manager
`mule.env=dev`, `mule.key=<secure>`, `anypoint.platform.client_id/secret`, `api.id`.
![Lab07-2](../images/screenshots/lab07-step02-properties.png)
### 3. Watch logs → app started, autodiscovery OK
![Lab07-3](../images/screenshots/lab07-step03-logs.png)
### 4. Call via LB
```bash
curl -i -X PUT https://<app>.<region>.cloudhub.io/api/tickets/ABC123/checkin
```
![Lab07-4](../images/screenshots/lab07-step04-cloudhub-call.png)
### 5. Check API Manager: Active + policies
![Lab07-5](../images/screenshots/lab07-step05-api-manager-active.png)
### 6. Check Analytics
![Lab07-6](../images/screenshots/lab07-step06-analytics.png)

## ✅ Verify
Client-ID policy returns 401 without credentials, 200 with.

**Next →** [Lab 08](lab-08-network-tls-checks.md)
