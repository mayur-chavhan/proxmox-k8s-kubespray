module "cluster" {
  source = "./modules/proxmox_lxc_k8s_cluster"

  cluster_name               = var.cluster_name
  cluster_profile            = var.cluster_profile
  proxmox_target_node        = var.proxmox_target_node
  proxmox_pool               = var.proxmox_pool
  proxmox_bridge             = var.proxmox_bridge
  ssh_public_key_path        = var.ssh_public_key_path
  node_network_cidr          = var.node_network_cidr
  node_gateway               = var.node_gateway
  nameserver                 = var.nameserver
  search_domain              = var.search_domain
  start_vmid                 = var.start_vmid
  vm_template_name           = var.vm_template_name
  vm_template_vmid           = var.vm_template_vmid
  vm_cloud_init_user         = var.vm_cloud_init_user
  vm_cloud_init_storage      = var.vm_cloud_init_storage
  vm_boot_disk_slot          = var.vm_boot_disk_slot
  vm_cloud_init_ssh_key_path = var.vm_cloud_init_ssh_key_path
  control_plane_ip_start     = var.control_plane_ip_start
  worker_ip_start            = var.worker_ip_start
  enable_protection          = var.enable_protection
}
