# Proxmox VM Kubernetes Lab (Terraform + Kubespray)

This repository provisions cloud-init VMs on your local Proxmox host (`192.168.x.x`) and installs Kubernetes with Kubespray.

## Design Goals

- Production-style structure for IaC and automation.
- Minimal day-to-day edits: mostly `cluster_name`, `cluster_profile`, and `vm_template_name`.
- Reusable workflow to mirror later deployments on AWS or other clouds.

## Recommended OS and Container Choices

- Recommended VM template OS: **Ubuntu 24.04 LTS** for Proxmox v9.
- Why for AWS parity: Ubuntu is common for EKS self-managed nodes and Kubespray workflows.
- Alternative: Debian 12 if you prefer Debian-based host tooling.

The workflow uses a Proxmox cloud-init template named `ubuntu`, static IPs from Terraform, an explicit cloud-init disk, and Kubespray over SSH as the cloud-init user (`ubuntu` by default).
The default boot disk slot is `virtio0`, which matches typical Ubuntu cloud-init templates and avoids the `scsi0 does not exist` update failure.

## Repository Structure

- `terraform/` Terraform root module.
- `terraform/modules/proxmox_lxc_k8s_cluster/` Reusable VM cluster module.
- `scripts/` Day-2 automation scripts.
- `kubespray/inventory/` Generated inventory files.

## Quick Start

1. Copy and edit variables once:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. In `terraform/terraform.tfvars`, change mainly:

- `cluster_name`
- `cluster_profile` (`dev`, `small`, `ha`)
- `vm_template_name` if your template name differs from `ubuntu`
- `vm_template_vmid` if you want full-clone provisioning by template ID instead of name
- `vm_cloud_init_storage` if your Proxmox cloud-init drive lives on a different storage backend
- `vm_boot_disk_slot` if your template uses a different boot disk slot

3. Initialize and plan:

```bash
make tf-init
make tf-fmt
make tf-validate
make tf-plan
```

4. Create containers:

```bash
make tf-apply
```

5. Generate Kubespray inventory:

```bash
make inventory
```

6. Install Kubernetes with Kubespray:

```bash
make kubespray-install
```

## Cluster Profiles

Profiles are defined in `terraform/modules/proxmox_lxc_k8s_cluster/main.tf`.

- `dev`: 1 control plane, 1 worker.
- `small`: 1 control plane, 2 workers.
- `ha`: 3 control planes, 3 workers.

This is the main lever for scaling without editing multiple Terraform files.

## Variables You Will Edit Most

In `terraform/terraform.tfvars`:

- `cluster_name`
- `cluster_profile`
- `vm_template_name`
- `vm_template_vmid` when you know the template VMID
- `vm_cloud_init_storage`
- `vm_boot_disk_slot`

Less frequent edits:

- `proxmox_target_node`
- `proxmox_api_token_id` / `proxmox_api_token_secret`
- network offsets (`control_plane_ip_start`, `worker_ip_start`)

## Proxmox API Best Practices

Use API token auth instead of password where possible:

- `proxmox_api_token_id`
- `proxmox_api_token_secret`

Keep secrets out of git. `.gitignore` already excludes `terraform.tfvars`.

## Day-2 Operations

- Upgrade cluster:

```bash
make kubespray-upgrade
```

- Reset cluster:

```bash
make kubespray-reset
```

- Destroy VM infrastructure:

```bash
make tf-destroy
```

## Accessing the Cluster (kubectl)

After running `make kubespray-install` successfully, the Kubernetes cluster configuration (`admin.conf`) will be located on the control plane node at `/etc/kubernetes/admin.conf`. To access the cluster from your local host (MacBook):

1. **Fetch the configuration file**:
   ```bash
   mkdir -p ~/.kube
   ssh ubuntu@192.168.1.50 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config-k8s-lab
   ```

2. **Update the API server endpoint**:
   Update the server URL inside `~/.kube/config-k8s-lab` from loopback `127.0.0.1` to the control plane VM's IP address:
   ```bash
   # On macOS
   sed -i '' 's/127.0.0.1/192.168.1.50/g' ~/.kube/config-k8s-lab
   ```

3. **Export and Verify**:
   ```bash
   export KUBECONFIG=~/.kube/config-k8s-lab
   kubectl get nodes
   ```

---

## Known Issues and Troubleshooting

### 1. `invalid bootorder: device 'virtio0' does not exist`
- **Symptom**: Terraform apply fails with:
  ```
  Error: error updating VM: 500 invalid bootorder: device 'virtio0' does not exist
  ```
- **Cause**: If the cloned Proxmox VM template uses a SCSI disk slot (`scsi0`) instead of VirtIO (`virtio0`), and the `disks` config block in Terraform does not declare this disk slot, the `telmate/proxmox` provider will attempt to delete the unmanaged disk from the VM. Once the disk is deleted, the boot order update fails because the boot device no longer exists.
- **Fix**:
  1. Change `vm_boot_disk_slot = "scsi0"` inside `terraform.tfvars`.
  2. Declare the SCSI disk in the `disks` config block of `modules/proxmox_lxc_k8s_cluster/main.tf` to prevent deletion and enable automatic resizing.

---

## Notes for Future AWS Parity

To keep parity between local Proxmox and cloud:

- Keep Kubernetes version and CNI defaults aligned in Kubespray variables.
- Keep hostname conventions stable (`<cluster>-cp-XX`, `<cluster>-wk-XX`).
- Keep inventory generation in Terraform outputs so target environments differ only by Terraform module/provider.

## Kubespray Notes

- The install scripts automatically use the SSH user exported by Terraform.
- Kubespray uses the cloud-init user (`ubuntu` by default).
- Static IPs are assigned directly from Terraform and written into the Kubespray inventory.

## Optional Next Improvement

If you want even fewer edits, we can convert profiles into a single `environment` variable (`lab`, `staging`, `prod`) and externalize all profile values in one map.
