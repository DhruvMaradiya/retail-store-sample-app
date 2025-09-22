variable "argocd_namespace" { default = "argocd" }

resource "null_resource" "argocd_apps" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Deploying ArgoCD projects and applications..."
      kubectl apply -n ${var.argocd_namespace} -f ${path.module}/../argocd/projects/
      kubectl apply -n ${var.argocd_namespace} -f ${path.module}/../argocd/applications/
    EOT
  }
  triggers = { always = timestamp() }
}