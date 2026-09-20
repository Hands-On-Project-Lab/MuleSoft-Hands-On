# Lab 10 · CloudHub 1.0 Custom Domain & TLS Certificate

📖 **Read first:** [16 CloudHub 1.0 vs 2.0 vs RTF](../concepts/16-cloudhub-rtf-deployment-targets.md) · [09 TLS & Certificates](../concepts/09-tls-certificates.md)
🎯 **End state:** Check-In PAPI reachable over `https://checkin.anyairline.com` with a CA-signed certificate, not the shared `*.cloudhub.io` cert.

## Steps

### 1. Confirm the app is already deployed to CloudHub 1.0
Reuse [Lab 07](lab-07-deploy-cloudhub.md); note the worker hostname `<app>.<region>.cloudhub.io`.
![Lab10-1](../images/screenshots/lab10-step01-existing-deploy.png)
- [ ] Done

### 2. Obtain a CA-signed certificate for the custom domain
Use a real CA (e.g. Let's Encrypt via `certbot`) for `checkin.anyairline.com` — a self-signed cert will fail validation for real external clients.
```bash
certbot certonly --manual -d checkin.anyairline.com
```
![Lab10-2](../images/screenshots/lab10-step02-cert-issued.png)

### 3. Upload the certificate
Runtime Manager → environment → **Certificates**, or to a **Dedicated Load Balancer (DLB)** if provisioned.
![Lab10-3](../images/screenshots/lab10-step03-upload-cert.png)

### 4. Add the DNS CNAME
`checkin.anyairline.com` → `<app>.<region>.cloudhub.io`.
![Lab10-4](../images/screenshots/lab10-step04-cname.png)

### 5. Verify TLS termination
```bash
curl -v https://checkin.anyairline.com/api/tickets/ABC123/checkin -X PUT
openssl s_client -connect checkin.anyairline.com:443 -servername checkin.anyairline.com </dev/null | openssl x509 -noout -issuer -subject -dates
```
Issuer should now be your CA, not MuleSoft's wildcard cert.
![Lab10-5](../images/screenshots/lab10-step05-verify-cert.png)

## ✅ Verify
- `curl` succeeds **without** `-k`.
- `openssl` shows your CA as issuer and `checkin.anyairline.com` as subject/SAN.

## 🧠 Self-check
1. Why must this certificate be CA-signed instead of self-signed, unlike your local dev keystore?
2. What's the difference between uploading a cert to Runtime Manager Certificates vs a Dedicated Load Balancer?

**Next →** [Lab 11](lab-11-cloudhub2-private-space.md)
