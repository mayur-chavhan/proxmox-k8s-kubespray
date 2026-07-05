locals {
  ansible_user = var.vm_cloud_init_user
  vm_clone     = var.vm_template_vmid != null ? null : var.vm_template_name

  cluster_profiles = {
    dev = {
      control_plane_count = 1
      worker_count        = 1
      control_plane_cores = 2
      control_plane_mem   = 4096
      worker_cores        = 2
      worker_mem          = 4096
      control_plane_disk  = "25G"
      worker_disk         = "40G"
    }
    small = {
      control_plane_count = 1
      worker_count        = 2
      control_plane_cores = 2
      control_plane_mem   = 2048
      worker_cores        = 4
      worker_mem          = 4096
      control_plane_disk  = "30G"
      worker_disk         = "60G"
    }
    ha = {
      control_plane_count = 3
      worker_count        = 3
      control_plane_cores = 4
      control_plane_mem   = 8192
      worker_cores        = 4
      worker_mem          = 12288
      control_plane_disk  = "40G"
      worker_disk         = "80G"
    }
  }

  profile = local.cluster_profiles[var.cluster_profile]

  cidr_prefix = split("/", var.node_network_cidr)[1]
  gateway     = coalesce(var.node_gateway, cidrhost(var.node_network_cidr, 1))

  control_plane_nodes = {
    for idx in range(local.profile.control_plane_count) :
    format("%s-cp-%02d", var.cluster_name, idx + 1) => {
      role     = "control-plane"
      hostname = format("%s-cp-%02d", var.cluster_name, idx + 1)
      vmid     = var.start_vmid + idx
      ip       = cidrhost(var.node_network_cidr, var.control_plane_ip_start + idx)
      cores    = local.profile.control_plane_cores
      memory   = local.profile.control_plane_mem
      disk     = local.profile.control_plane_disk
    }
  }

  worker_nodes = {
    for idx in range(local.profile.worker_count) :
    format("%s-wk-%02d", var.cluster_name, idx + 1) => {
      role     = "worker"
      hostname = format("%s-wk-%02d", var.cluster_name, idx + 1)
      vmid     = var.start_vmid + local.profile.control_plane_count + idx
      ip       = cidrhost(var.node_network_cidr, var.worker_ip_start + idx)
      cores    = local.profile.worker_cores
      memory   = local.profile.worker_mem
      disk     = local.profile.worker_disk
    }
  }

  all_nodes = merge(local.control_plane_nodes, local.worker_nodes)

  kubespray_inventory = {
    all = {
      hosts = {
        for name, node in local.all_nodes :
        name => {
          ansible_host = node.ip
          ip           = node.ip
          access_ip    = node.ip
        }
      }
      children = {
        kube_control_plane = {
          hosts = {
            for name, _ in local.control_plane_nodes :
            name => {}
          }
        }
        kube_node = {
          hosts = {
            for name, _ in local.worker_nodes :
            name => {}
          }
        }
        etcd = {
          hosts = {
            for name, _ in local.control_plane_nodes :
            name => {}
          }
        }
        k8s_cluster = {
          children = {
            kube_control_plane = {}
            kube_node          = {}
          }
        }
        calico_rr = {
          hosts = {}
        }
      }
    }
  }
}

resource "proxmox_vm_qemu" "node" {
  for_each = local.all_nodes

  name        = each.value.hostname
  target_node = var.proxmox_target_node
  vmid        = each.value.vmid
  clone       = local.vm_clone
  clone_id    = var.vm_template_vmid
  full_clone  = true
  vm_state    = "running"
  protection  = var.enable_protection
  pool        = var.proxmox_pool != "" ? var.proxmox_pool : null
  tags        = "terraform,kubernetes,${var.cluster_name},${each.value.role}"
  boot        = "order=${var.vm_boot_disk_slot};ide2;net0"
  scsihw      = "virtio-scsi-pci"

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory       = each.value.memory
  os_type      = "cloud-init"
  ciuser       = var.vm_cloud_init_user
  sshkeys      = trimspace(file(var.ssh_public_key_path))
  nameserver   = var.nameserver
  searchdomain = var.search_domain
  ipconfig0    = "ip=${each.value.ip}/${local.cidr_prefix},gw=${local.gateway}"
  agent        = 0

  disks {
    scsi {
      scsi0 {
        disk {
          size    = each.value.disk
          storage = var.vm_cloud_init_storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.vm_cloud_init_storage
        }
      }
    }
  }

  network {
    id       = 0
    bridge   = var.proxmox_bridge
    model    = "virtio"
    firewall = false
  }
}
