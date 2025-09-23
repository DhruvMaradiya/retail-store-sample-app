helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack      https://charts.jetstack.io
helm repo add argo          https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."networking\.gke\.io/load-balancer-type"=External \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=128Mi

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set resources.requests.cpu=50m \
  --set resources.requests.memory=128Mi

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.extraArgs="{--insecure}" \
  --set controller.resources.requests.cpu=50m \
  --set controller.resources.requests.memory=256Mi \
  --set applicationset.resources.requests.cpu=50m \
  --set applicationset.resources.requests.memory=128Mi \
  --set notifications.resources.requests.cpu=50m \
  --set notifications.resources.requests.memory=128Mi