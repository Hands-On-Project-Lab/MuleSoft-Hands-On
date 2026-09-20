# Lab 11 · CloudHub 2.0 Private Space

📖 **Read first:** [16 CloudHub 1.0 vs 2.0 vs RTF](../concepts/16-cloudhub-rtf-deployment-targets.md)
🎯 **End state:** Check-In PAPI deployed into a CloudHub 2.0 Private Space with firewall rules and a static outbound IP identified.

## Steps

### 1. Create (or open) a Private Space
Runtime Manager → **Private Spaces** → create one, or use your trial org's existing space.
![Lab11-1](../images/screenshots/lab11-step01-private-space.png)
- [ ] Private Space name: `________`

### 2. Deploy the app into the Private Space
Deploy Check-In PAPI targeting this space instead of the default shared runtime.
![Lab11-2](../images/screenshots/lab11-step02-deploy-into-space.png)

### 3. Configure Firewall Rules
Private Space → **Firewall Rules** → add an inbound/outbound rule (e.g. allow HTTPS from a specific CIDR).
![Lab11-3](../images/screenshots/lab11-step03-firewall-rules.png)

### 4. Locate the Static IP
Private Space → networking settings → note the static outbound IP (this is what you'd hand a partner for IP-allowlisting).
![Lab11-4](../images/screenshots/lab11-step04-static-ip.png)
- [ ] Static IP: `________`

### 5. Upload a custom TLS certificate at the space level
![Lab11-5](../images/screenshots/lab11-step05-tls-upload.png)

### 6. Verify
```bash
curl -i -X PUT https://<app>.<region>.cloudhub.io/api/tickets/ABC123/checkin
```
![Lab11-6](../images/screenshots/lab11-step06-verify.png)

## ✅ Verify
- App reachable through the Private Space.
- Firewall rule visibly restricts/allows traffic as configured.
- Static IP recorded (compare with CH1's rotating shared IP from [08 VPC & On-Prem](../concepts/08-vpc-onprem-targets.md)).

## 🧠 Self-check
1. How does a Private Space's Static IP solve the problem CH1's Anypoint VPC add-on solves — but without a separate paid product?
2. Where do Firewall Rules live in CH2.0 vs where VPC firewall rules live in CH1 (per [08](../concepts/08-vpc-onprem-targets.md))?

**Next →** [Lab 12](lab-12-rtf-ingress-tls.md)
