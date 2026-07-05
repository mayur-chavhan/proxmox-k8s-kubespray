variable "cluster_name" {
  type = string
}

variable "cluster_profile" {
  type = string
}

variable "proxmox_target_node" {
  type = string
}

variable "proxmox_pool" {
  type = string
}

variable "proxmox_bridge" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "node_network_cidr" {
  type = string
}

variable "node_gateway" {
  type    = string
  default = null
}

variable "nameserver" {
  type    = string
  default = null
}

variable "search_domain" {
  type    = string
  default = null
}

variable "start_vmid" {
  type = number
}

variable "vm_template_name" {
  type = string
}

variable "vm_template_vmid" {
  type    = number
  default = null
}

variable "vm_cloud_init_user" {
  type = string
}

variable "vm_cloud_init_storage" {
  type    = string
  default = "local-lvm"
}

variable "vm_boot_disk_slot" {
  type    = string
  default = "virtio0"
}

variable "vm_cloud_init_ssh_key_path" {
  type = string
}

variable "control_plane_ip_start" {
  type = number
}

variable "worker_ip_start" {
  type = number
}

variable "enable_protection" {
  type = bool
}
