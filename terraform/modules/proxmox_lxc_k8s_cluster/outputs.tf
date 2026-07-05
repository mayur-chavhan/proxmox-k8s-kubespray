output "cluster_name" {
  value = var.cluster_name
}

output "ansible_user" {
  value = local.ansible_user
}

output "node_summary" {
  value = {
    for name, node in local.all_nodes :
    name => {
      role     = node.role
      hostname = node.hostname
      vmid     = node.vmid
      ip       = node.ip
      cores    = node.cores
      memory   = node.memory
      disk     = node.disk
    }
  }
}

output "kubespray_inventory" {
  value = local.kubespray_inventory
}
