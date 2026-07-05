output "cluster_name" {
  description = "Logical Kubernetes cluster name."
  value       = module.cluster.cluster_name
}

output "ansible_user" {
  description = "SSH user to use for Kubespray and day-2 operations."
  value       = module.cluster.ansible_user
}

output "node_summary" {
  description = "Map of provisioned nodes with role, vmid, and IP details."
  value       = module.cluster.node_summary
}

output "kubespray_inventory" {
  description = "Kubespray inventory object rendered from Terraform data."
  value       = module.cluster.kubespray_inventory
}

output "kubespray_inventory_yaml" {
  description = "Kubespray inventory as YAML for direct file output."
  value       = yamlencode(module.cluster.kubespray_inventory)
}
