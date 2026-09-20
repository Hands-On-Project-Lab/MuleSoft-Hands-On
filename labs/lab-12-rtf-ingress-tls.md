# Lab 12 · RTF: Kubernetes Ingress & TLS Termination (Paper + Commands)

📖 **Read first:** [16 CloudHub 1.0 vs 2.0 vs RTF](../concepts/16-cloudhub-rtf-deployment-targets.md) · [09 TLS & Certificates](../concepts/09-tls-certificates.md)
🎯 **End state:** you can create a TLS Secret, wire it into an Ingress resource, and explain exactly where TLS terminates for an RTF deployment.

> No RTF cluster? This lab works as a paper/command exercise against any Kubernetes cluster (e.g. `minikube`/`kind`) to learn the mechanics — the concepts transfer directly to a real RTF install.

## Steps

### 1. Create the TLS Secret from your certificate
```bash
kubectl create secret tls checkin-tls-secret \
  --cert=checkin.anyairline.com.crt \
  --key=checkin.anyairline.com.key
```
![Lab12-1](../images/screenshots/lab12-step01-tls-secret.png)

### 2. Apply the Ingress resource
Use the YAML from [16 CloudHub 1.0 vs 2.0 vs RTF](../concepts/16-cloudhub-rtf-deployment-targets.md#rtf-runtime-fabric), adjusted for your host:
```bash
kubectl apply -f check-in-api-ingress.yaml
kubectl get ingress check-in-api-ingress
```
![Lab12-2](../images/screenshots/lab12-step02-apply-ingress.png)

### 3. Verify routing
```bash
curl -i -X PUT https://checkin.anyairline.com/api/tickets/ABC123/checkin \
  --resolve checkin.anyairline.com:443:<ingress-external-ip>
```
![Lab12-3](../images/screenshots/lab12-step03-verify-routing.png)

### 4. Decide and document the TLS termination point
Fill in for your deployment:

| Termination point | Chosen? | Why |
|---|---|---|
| Cloud Load Balancer (e.g. AWS NLB + ACM) | | |
| Ingress Controller (Kubernetes Secret) | | |
| Mule app itself (`tls:context`) | | |

![Lab12-4](../images/screenshots/lab12-step04-termination-decision.png)

## ✅ Verify
- `kubectl get ingress` shows the host and an assigned address.
- `curl` against the Ingress succeeds over HTTPS.
- You can explain, for your chosen termination point, whether traffic is re-encrypted or plaintext between hops inside the VPC.

## 🧠 Self-check
1. What plays the same role as your local `.p12` keystore in this setup?
2. If you terminate TLS at the cloud LB instead of the Ingress Controller, is traffic inside your VPC still encrypted? Does that matter?

🎉 **Course complete.** Review the checklist in the [README](../README.md).
