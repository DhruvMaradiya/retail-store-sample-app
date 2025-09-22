# leave providers.tf.disabled  (no kubernetes provider)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack      https://charts.jetstack.io
helm repo add argo          https://argoproj.github.io/argo-helm
helm repo update

# NGINX Ingress
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."networking\.gke\.io/load-balancer-type"=External

# cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

# ArgoCD
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.extraArgs="{--insecure}"