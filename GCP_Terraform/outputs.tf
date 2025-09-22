# output "cluster_name" {
#   value = data.google_container_cluster.autopilot.name
#   depends_on = [data.google_container_cluster.autopilot]
# }

# output "cluster_name_base" {
#   value = var.cluster_name
# }

# output "cluster_name_suffix" {
#   value = random_string.suffix.result
# }

# output "cluster_endpoint" {
#   value = "https://${data.google_container_cluster.autopilot.endpoint}"
# }

# output "cluster_version" {
#   value = data.google_container_cluster.autopilot.master_version
# }

# output "configure_kubectl" {
#   value = "gcloud container clusters get-credentials ${module.gke_autopilot.cluster_name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
# }

# output "argocd_namespace" {
#   value = var.argocd_namespace
# }

# output "argocd_server_port_forward" {
#   value = "kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443"
# }

# output "argocd_admin_password" {
#   value     = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
#   sensitive = true
# }

# output "ingress_nginx_loadbalancer" {
#   value = "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
# }

# output "retail_store_url" {
#   value = "echo 'http://'$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
# }

# output "useful_commands" {
#   value = {
#     get_nodes        = "kubectl get nodes"
#     get_pods_all     = "kubectl get pods -A"
#     get_retail_store = "kubectl get pods -n retail-store"
#     argocd_apps      = "kubectl get applications -n ${var.argocd_namespace}"
#     ingress_status   = "kubectl get ingress -A"
#     describe_cluster = "kubectl cluster-info"
#   }
# }





output "cluster_name" {
  value = module.gke_autopilot.name
}

output "cluster_endpoint" {
  value     = "https://${module.gke_autopilot.endpoint}"
  sensitive = true
}

output "cluster_version" {
  value = module.gke_autopilot.master_version
}

output "configure_kubectl" {
  value = "gcloud container clusters get-credentials ${module.gke_autopilot.name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
}