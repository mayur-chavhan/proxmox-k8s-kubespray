variable "proxmox_api_url" {
  description = "Proxmox API endpoint, for example https://192.168.1.9:8006/api2/json"
  type        = string
}

variable "proxmox_tls_insecure" {
  description = "Disable TLS verification for self-signed certificates."
  type        = bool
  default     = true
}

variable "proxmox_api_token_id" {
  description = "Optional API token ID, for example terraform-prov@pve!tf"
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Optional API token secret."
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_username" {
  description = "Optional username when not using API token."
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_password" {
  description = "Optional password when not using API token."
  type        = string
  default     = null
  sensitive   = true
}

variable "cluster_name" {
  description = "Cluster name used for node naming and inventory paths."
  type        = string
  default     = "k8s-lab"
}

variable "cluster_profile" {
  description = "Sizing profile: dev, small, or ha."
  type        = string
  default     = "small"

  validation {
    condition     = contains(["dev", "small", "ha"], var.cluster_profile)
    error_message = "cluster_profile must be one of: dev, small, ha."
  }
}

variable "proxmox_target_node" {
  description = "Proxmox node to host the VMs."
  type        = string
}

variable "proxmox_pool" {
  description = "Optional Proxmox pool name to assign VMs."
  type        = string
  default     = ""
}

variable "proxmox_bridge" {
  description = "Proxmox bridge used by VM network interfaces."
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key injected into all VMs."
  type        = string
}

variable "node_network_cidr" {
  description = "IPv4 CIDR used for Kubernetes nodes."
  type        = string
  default     = "192.168.1.0/24"
}

variable "node_gateway" {
  description = "Optional gateway IP. If null, Terraform uses first host in node_network_cidr."
  type        = string
  default     = null
}

variable "nameserver" {
  description = "Optional DNS server for VMs."
  type        = string
  default     = null
}

variable "search_domain" {
  description = "Optional DNS search domain for VMs."
  type        = string
  default     = null
}

variable "start_vmid" {
  description = "Starting VMID for generated VMs."
  type        = number
  default     = 3000
}

variable "vm_template_name" {
  description = "Proxmox VM template name to clone, for example ubuntu."
  type        = string
  default     = "ubuntu"
}

variable "vm_template_vmid" {
  description = "Optional Proxmox VM template VMID. Use this if name-based cloning is unreliable."
  type        = number
  default     = null
}

variable "vm_cloud_init_user" {
  description = "Cloud-init SSH user for VM mode."
  type        = string
  default     = "ubuntu"
}

variable "vm_cloud_init_storage" {
  description = "Storage backend that holds the cloud-init drive on cloned VMs."
  type        = string
  default     = "local-lvm"
}

variable "vm_boot_disk_slot" {
  description = "Primary boot disk slot on the cloned template, for example virtio0 or scsi0."
  type        = string
  default     = "virtio0"
}

variable "vm_cloud_init_ssh_key_path" {
  description = "Path to the SSH public key injected into the cloud-init user."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "control_plane_ip_start" {
  description = "Starting host offset inside node_network_cidr for control plane nodes."
  type        = number
  default     = 50
}

variable "worker_ip_start" {
  description = "Starting host offset inside node_network_cidr for worker nodes."
  type        = number
  default     = 70
}

variable "enable_protection" {
  description = "Enable Proxmox deletion protection on created VMs."
  type        = bool
  default     = false
}
