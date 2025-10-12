# Retail Store Sample App - GitOps with GKE autopilot mode
<img width="1326" height="667" alt="Screenshot from 2025-09-27 11-54-01" src="https://github.com/user-attachments/assets/72e36f43-90ac-4ffd-b3c2-707b3aa45de6" />

# [▶ Watch demo video](https://drive.google.com/file/d/1NOIha-nAlw0KCfXyhQFetMRnGe-fgj05/view) 

## Overview

The Retail Store Sample App demonstrates a modern microservices architecture deployed on GCP GKE using GitOps principles. The application consists of multiple services that work together to provide a complete retail store experience:


- **UI Service**: Java-based frontend
- **Catalog Service**: Go-based product catalog API
- **Cart Service**: Java-based shopping cart API
- **Orders Service**: Java-based order management API
- **Checkout Service**: Node.js-based checkout orchestration API


## Infrastructure Architecture

The Infrastructure Architecture follows cloud-native best practices:

- **Microservices**: Each component is developed and deployed independently
- **Containerization**: All services run as containers on Kubernetes
- **GitOps**: Infrastructure and application deployment managed through Git
- **Infrastructure as Code**: All GCP resources defined using Terraform
- **CI/CD**: Automated build and deployment pipelines with GitHub Actions


# Retail Store – GKE Autopilot GitOps Demo

> **Zero-node-management GitOps pipeline on Google Kubernetes Engine (Autopilot)**  
> Fully automated infrastructure + CI/CD using Terraform, Helm, ArgoCD, GitHub Actions, and Artifact Registry

---

## 🧱 What You Get

| Stage | Resources |
|-------|-----------|
| **1. Infrastructure** | VPC + NAT + GKE Autopilot cluster (v1.30+) |
| **2. Add-ons** | NGINX Ingress (GCP Load Balancer), cert-manager, ArgoCD |
| **3. Applications** | 5 microservices (UI, Cart, Catalog, Orders, Checkout) deployed via GitOps |
| **4. CI/CD** | GitHub Actions → Artifact Registry → Helm → ArgoCD → GKE |

> 💡 **Key Insight**: GKE Autopilot right-sizes nodes based on the **largest resource request** in your workload.  
> Using **10m CPU / 32Mi memory** ensures pods fit on the smallest Autopilot node → **zero quota issues, zero extra cost**.

---

## 📁 Repository Structure

```text
retail-store-sample-app/
├── GCP_Terraform/               # Stage 1 & 2: Infrastructure + Add-ons
│   ├── versions.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── main.tf                  # VPC + NAT + GKE Autopilot
│   ├── outputs.tf
│   ├── security.tf.disabled     # AWS-only (ignored)
│   ├── providers.tf.disabled    # Re-enable in Stage 2
│   ├── addons.tf.disabled       # Re-enable in Stage 2
│   └── argocd.tf.disabled       # Re-enable in Stage 2
├── argocd/
│   ├── projects/
│   │   └── retail-store-project.yaml
│   └── applications/
│       ├── retail-store-ui.yaml
│       ├── retail-store-cart.yaml
│       ├── retail-store-catalog.yaml
│       ├── retail-store-checkout.yaml
│       └── retail-store-orders.yaml
├── src/                         # Microservice source code
│   ├── ui/
│   ├── cart/
│   ├── catalog/
│   ├── checkout/
│   └── orders/
├── .github/workflows/
│   └── deploy.yml               # GitHub Actions CI/CD
└── README.md                    # ← You are here
```

---


📦 What Gets Deployed
Stage	Resource	Description
Stage 1	Terraform	VPC, Cloud Router, NAT, and a base GKE Autopilot Cluster.
Stage 2	Helm CLI	NGINX-Ingress Controller (gets a GCP Load Balancer IP), Cert-Manager, and ArgoCD.
Stage 3	GitOps Sync	5 Micro-services (UI, Cart, Catalog, Orders, Checkout) deployed by ArgoCD from your GitHub repo.

---


## ⚙️ Prerequisites

### 1. **GCP Project**
- Billing enabled
- APIs activated:
  ```bash
  gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com
  ```

### 2. **Local Tools**
| Tool | Version |
|------|---------|
| `gcloud` CLI | ≥ 440 |
| `kubectl` | Latest |
| `helm` | v3+ |
| `terraform` | ≥ 1.0 |

### 3. **Install GKE Auth Plugin**
```bash
# Most users
gcloud components install gke-gcloud-auth-plugin

# Debian/Ubuntu (if disabled)
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

# macOS (Homebrew)
brew install google-cloud-sdk
```

Verify:
```bash
gke-gcloud-auth-plugin --version
```

---

## 🚀 Deployment Guide

### ✅ Stage 1: Build GKE Autopilot Cluster (No Kubernetes Provider)

> **Goal**: Create VPC + NAT + GKE Autopilot cluster **without** Helm/K8s providers to avoid Terraform cycles.

#### 1. Configure `terraform.tfvars`
```hcl
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"
cluster_name   = "retail-store"
environment    = "dev"
```

#### 2. Disable Kubernetes-dependent files
```bash
cd GCP_Terraform

mv providers.tf providers.tf.disabled
mv addons.tf    addons.tf.disabled
mv argocd.tf    argocd.tf.disabled
```

#### 3. Apply Infrastructure
```bash
terraform init
terraform apply -auto-approve
```

> ✅ **Success Output**:
> ```
> cluster_name      = "retail-store-abcd"
> configure_kubectl = "gcloud container clusters get-credentials retail-store-abcd --region us-central1 --project your-project-id"
> ```

#### 4. Connect `kubectl`
```bash
eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes  # → "No resources found" (normal for Autopilot)
```

---

### ✅ Stage 2: Install Add-ons (Helm Method – Recommended)

> **Why Helm?** Avoids Terraform provider cycles during cluster creation.

#### 1. Fetch kubeconfig
```bash
eval "$(terraform output -raw configure_kubectl)"
```

#### 2. Install Add-ons via Helm
```bash
# Add repos
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack      https://charts.jetstack.io
helm repo add argo          https://argoproj.github.io/argo-helm
helm repo update

# NGINX Ingress (GCP Load Balancer)
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."networking\.gke\.io/load-balancer-type"=External \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=128Mi

# cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set resources.requests.cpu=50m \
  --set resources.requests.memory=128Mi

# ArgoCD (tiny footprint)
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.extraArgs="{--insecure}" \
  --set controller.resources.requests.cpu=10m \
  --set controller.resources.requests.memory=32Mi \
  --set applicationset.resources.requests.cpu=10m \
  --set applicationset.resources.requests.memory=32Mi \
  --set notifications.resources.requests.cpu=10m \
  --set notifications.resources.requests.memory=32Mi \
  --set repoServer.resources.requests.cpu=10m \
  --set repoServer.resources.requests.memory=32Mi \
  --set dex.resources.requests.cpu=10m \
  --set dex.resources.requests.memory=32Mi \
  --set redis.resources.requests.cpu=10m \
  --set redis.resources.requests.memory=32Mi
```

#### 3. Deploy GitOps Applications
```bash
kubectl apply -n argocd -f ../argocd/projects/
kubectl apply -n argocd -f ../argocd/applications/
```

#### 4. Patch Microservices for Quota Safety
```bash
for dep in ui orders catalog cart checkout; do
  kubectl patch deployment retail-store-$dep -n retail-store --type='json' \
    -p='[
      {"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/cpu","value":"10m"},
      {"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/memory","value":"32Mi"}
    ]'
done
```

#### 5. Access Your Storefront
```bash
echo "http://$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
# Example: http://34.55.83.136
```

---

## 🔐 ArgoCD Access

### Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### Port-Forward UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Login
- URL: `https://localhost:8080`
- Username: `admin`
- Password: (from command above)
- **Accept self-signed certificate**

---

## 🔄 GitHub Actions CI/CD Pipeline

> **Flow**: Push to `gitops` → Build Docker image → Push to Artifact Registry → Update Helm chart → ArgoCD syncs

### 1. Create Service Account
```bash
# Service Account
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account for Retail Store" \
  --description="Allows GitHub Actions to push to Artifact Registry"

# Roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.serviceAgent"
```

### 2. Add GitHub Secrets
| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | `your-project-id` |
| `GCP_REGION` | `us-central1` |
| `ARTIFACT_REGISTRY_LOCATION` | `us-central1` |
| `GCP_SA_KEY` | [JSON key content](#download-json-key) |

#### Download JSON Key
```bash
gcloud iam service-accounts keys create ~/key.json \
  --iam-account=github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 3. Grant GKE Node Access to Artifact Registry
```bash
GKE_SA=$(gcloud container clusters describe retail-store-XXXX \
  --zone=us-central1 --format="value(nodeConfig.serviceAccount)")

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${GKE_SA}" \
  --role="roles/artifactregistry.reader"
```

### 4. Remove `imagePullSecrets` from Helm Charts
Edit `src/*/chart/values.yaml`:
```yaml
# REMOVE THESE LINES:
# imagePullSecrets:
#   - name: regcred
```

Or patch live:
```bash
kubectl patch deployment retail-store-checkout -n retail-store -p '{"spec":{"template":{"spec":{"imagePullSecrets":[]}}}}'
```

---

## 🧪 Troubleshooting

### Common Issues & Fixes

| Symptom | Root Cause | Fix |
|--------|------------|-----|
| `Insufficient cpu/memory` | Default Helm requests too large | Patch to `10m CPU / 32Mi memory` |
| `ImagePullBackOff` | Private images without pull secrets | Use public images OR grant GKE SA Artifact Registry access |
| `CreateContainerConfigError` | Missing secrets (e.g., `argocd-redis`) | Delete secret → Helm recreates it |
| ArgoCD `ComparisonError` | `repo-server` pod not running | Patch `repo-server` to tiny resources |
| GitHub Actions auth failure | Workload Identity misconfigured | Use JSON key auth instead |

### Debug Commands
```bash
# Check pod status
kubectl get pods -A

# Inspect failing pod
kubectl describe pod -n retail-store retail-store-ui-xxxxx

# Check logs
kubectl logs -n retail-store -l app.kubernetes.io/name=ui --tail=50

# Verify resource requests
kubectl describe nodes | grep -A5 "Allocated resources"
```

---

## 🧹 Cleanup

### Destroy Everything
```bash
cd GCP_Terraform

# Allow deletion
terraform apply -auto-approve -var='deletion_protection=false'

# Destroy
terraform destroy -auto-approve
```

### Optional: Delete Leftovers
```bash
# Service Account
gcloud iam service-accounts delete github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com --quiet

# Artifact Registry
gcloud artifacts repositories delete demo-private --location=us-central1 --quiet
```

> 💡 **Cost Tip**:  
> - Autopilot control plane: **free when empty**  
> - Load Balancer: **~$18/month** → Delete `ingress-nginx-controller` service when idle

---

> ✨ **You now have a production-grade GitOps pipeline on GKE Autopilot!**  
> Push to `gitops` → coffee → live storefront. All on Google Cloud credits.# Retail Store – GKE Autopilot GitOps Demo

> **Zero-node-management GitOps pipeline on Google Kubernetes Engine (Autopilot)**  
> Fully automated infrastructure + CI/CD using Terraform, Helm, ArgoCD, GitHub Actions, and Artifact Registry

---

## 🧱 What You Get

| Stage | Resources |
|-------|-----------|
| **1. Infrastructure** | VPC + NAT + GKE Autopilot cluster (v1.30+) |
| **2. Add-ons** | NGINX Ingress (GCP Load Balancer), cert-manager, ArgoCD |
| **3. Applications** | 5 microservices (UI, Cart, Catalog, Orders, Checkout) deployed via GitOps |
| **4. CI/CD** | GitHub Actions → Artifact Registry → Helm → ArgoCD → GKE |

> 💡 **Key Insight**: GKE Autopilot right-sizes nodes based on the **largest resource request** in your workload.  
> Using **10m CPU / 32Mi memory** ensures pods fit on the smallest Autopilot node → **zero quota issues, zero extra cost**.

---

## 📁 Repository Structure

```text
retail-store-sample-app/
├── GCP_Terraform/               # Stage 1 & 2: Infrastructure + Add-ons
│   ├── versions.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── main.tf                  # VPC + NAT + GKE Autopilot
│   ├── outputs.tf
│   ├── security.tf.disabled     # AWS-only (ignored)
│   ├── providers.tf.disabled    # Re-enable in Stage 2
│   ├── addons.tf.disabled       # Re-enable in Stage 2
│   └── argocd.tf.disabled       # Re-enable in Stage 2
├── argocd/
│   ├── projects/
│   │   └── retail-store-project.yaml
│   └── applications/
│       ├── retail-store-ui.yaml
│       ├── retail-store-cart.yaml
│       ├── retail-store-catalog.yaml
│       ├── retail-store-checkout.yaml
│       └── retail-store-orders.yaml
├── src/                         # Microservice source code
│   ├── ui/
│   ├── cart/
│   ├── catalog/
│   ├── checkout/
│   └── orders/
├── .github/workflows/
│   └── deploy.yml               # GitHub Actions CI/CD
└── README.md                    # ← You are here
```

---

## ⚙️ Prerequisites

### 1. **GCP Project**
- Billing enabled
- APIs activated:
  ```bash
  gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com
  ```

### 2. **Local Tools**
| Tool | Version |
|------|---------|
| `gcloud` CLI | ≥ 440 |
| `kubectl` | Latest |
| `helm` | v3+ |
| `terraform` | ≥ 1.0 |

### 3. **Install GKE Auth Plugin**
```bash
# Most users
gcloud components install gke-gcloud-auth-plugin

# Debian/Ubuntu (if disabled)
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

# macOS (Homebrew)
brew install google-cloud-sdk
```

Verify:
```bash
gke-gcloud-auth-plugin --version
```

---

## 🚀 Deployment Guide

### ✅ Stage 1: Build GKE Autopilot Cluster (No Kubernetes Provider)

> **Goal**: Create VPC + NAT + GKE Autopilot cluster **without** Helm/K8s providers to avoid Terraform cycles.

#### 1. Configure `terraform.tfvars`
```hcl
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"
cluster_name   = "retail-store"
environment    = "dev"
```

#### 2. Disable Kubernetes-dependent files
```bash
cd GCP_Terraform

mv providers.tf providers.tf.disabled
mv addons.tf    addons.tf.disabled
mv argocd.tf    argocd.tf.disabled
```

#### 3. Apply Infrastructure
```bash
terraform init
terraform apply -auto-approve
```

> ✅ **Success Output**:
> ```
> cluster_name      = "retail-store-abcd"
> configure_kubectl = "gcloud container clusters get-credentials retail-store-abcd --region us-central1 --project your-project-id"
> ```

#### 4. Connect `kubectl`
```bash
eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes  # → "No resources found" (normal for Autopilot)
```

---

### ✅ Stage 2: Install Add-ons (Helm Method – Recommended)

> **Why Helm?** Avoids Terraform provider cycles during cluster creation.

#### 1. Fetch kubeconfig
```bash
eval "$(terraform output -raw configure_kubectl)"
```

#### 2. Install Add-ons via Helm
```bash
# Add repos
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack      https://charts.jetstack.io
helm repo add argo          https://argoproj.github.io/argo-helm
helm repo update

# NGINX Ingress (GCP Load Balancer)
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."networking\.gke\.io/load-balancer-type"=External \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=128Mi

# cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set resources.requests.cpu=50m \
  --set resources.requests.memory=128Mi

# ArgoCD (tiny footprint)
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.extraArgs="{--insecure}" \
  --set controller.resources.requests.cpu=10m \
  --set controller.resources.requests.memory=32Mi \
  --set applicationset.resources.requests.cpu=10m \
  --set applicationset.resources.requests.memory=32Mi \
  --set notifications.resources.requests.cpu=10m \
  --set notifications.resources.requests.memory=32Mi \
  --set repoServer.resources.requests.cpu=10m \
  --set repoServer.resources.requests.memory=32Mi \
  --set dex.resources.requests.cpu=10m \
  --set dex.resources.requests.memory=32Mi \
  --set redis.resources.requests.cpu=10m \
  --set redis.resources.requests.memory=32Mi
```

#### 3. Deploy GitOps Applications
```bash
kubectl apply -n argocd -f ../argocd/projects/
kubectl apply -n argocd -f ../argocd/applications/
```

#### 4. Patch Microservices for Quota Safety
```bash
for dep in ui orders catalog cart checkout; do
  kubectl patch deployment retail-store-$dep -n retail-store --type='json' \
    -p='[
      {"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/cpu","value":"10m"},
      {"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/memory","value":"32Mi"}
    ]'
done
```

#### 5. Access Your Storefront
```bash
echo "http://$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
# Example: http://34.55.83.136
```

---

## 🔐 ArgoCD Access

### Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### Port-Forward UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Login
- URL: `https://localhost:8080`
- Username: `admin`
- Password: (from command above)
- **Accept self-signed certificate**

---

## 🔄 GitHub Actions CI/CD Pipeline

> **Flow**: Push to `gitops` → Build Docker image → Push to Artifact Registry → Update Helm chart → ArgoCD syncs

### 1. Create Service Account
```bash
# Service Account
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account for Retail Store" \
  --description="Allows GitHub Actions to push to Artifact Registry"

# Roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.serviceAgent"
```

### 2. Add GitHub Secrets
| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | `your-project-id` |
| `GCP_REGION` | `us-central1` |
| `ARTIFACT_REGISTRY_LOCATION` | `us-central1` |
| `GCP_SA_KEY` | [JSON key content](#download-json-key) |

#### Download JSON Key
```bash
gcloud iam service-accounts keys create ~/key.json \
  --iam-account=github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 3. Grant GKE Node Access to Artifact Registry
```bash
GKE_SA=$(gcloud container clusters describe retail-store-XXXX \
  --zone=us-central1 --format="value(nodeConfig.serviceAccount)")

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${GKE_SA}" \
  --role="roles/artifactregistry.reader"
```

### 4. Remove `imagePullSecrets` from Helm Charts
Edit `src/*/chart/values.yaml`:
```yaml
# REMOVE THESE LINES:
# imagePullSecrets:
#   - name: regcred
```

Or patch live:
```bash
kubectl patch deployment retail-store-checkout -n retail-store -p '{"spec":{"template":{"spec":{"imagePullSecrets":[]}}}}'
```

---

## 🧪 Troubleshooting

### Common Issues & Fixes

| Symptom | Root Cause | Fix |
|--------|------------|-----|
| `Insufficient cpu/memory` | Default Helm requests too large | Patch to `10m CPU / 32Mi memory` |
| `ImagePullBackOff` | Private images without pull secrets | Use public images OR grant GKE SA Artifact Registry access |
| `CreateContainerConfigError` | Missing secrets (e.g., `argocd-redis`) | Delete secret → Helm recreates it |
| ArgoCD `ComparisonError` | `repo-server` pod not running | Patch `repo-server` to tiny resources |
| GitHub Actions auth failure | Workload Identity misconfigured | Use JSON key auth instead |

### Debug Commands
```bash
# Check pod status
kubectl get pods -A

# Inspect failing pod
kubectl describe pod -n retail-store retail-store-ui-xxxxx

# Check logs
kubectl logs -n retail-store -l app.kubernetes.io/name=ui --tail=50

# Verify resource requests
kubectl describe nodes | grep -A5 "Allocated resources"
```

---

## 🧹 Cleanup

### Destroy Everything
```bash
cd GCP_Terraform

# Allow deletion
terraform apply -auto-approve -var='deletion_protection=false'

# Destroy
terraform destroy -auto-approve
```

### Optional: Delete Leftovers
```bash
# Service Account
gcloud iam service-accounts delete github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com --quiet

# Artifact Registry
gcloud artifacts repositories delete demo-private --location=us-central1 --quiet
```

> 💡 **Cost Tip**:  
> - Autopilot control plane: **free when empty**  
> - Load Balancer: **~$18/month** → Delete `ingress-nginx-controller` service when idle

---

> ✨ **You now have a production-grade GitOps pipeline on GKE Autopilot!**  
> Push to `gitops` → coffee → live storefront. All on Google Cloud credits.
