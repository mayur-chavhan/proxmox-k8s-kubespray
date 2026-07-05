#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

if [[ ! -f "${TF_DIR}/terraform.tfvars" && ! -f "${TF_DIR}/terraform.tfvars.json" ]]; then
  echo "Expected terraform.tfvars in ${TF_DIR}. Copy terraform.tfvars.example first." >&2
  exit 1
fi

CLUSTER_NAME="${1:-$(terraform -chdir="${TF_DIR}" output -raw cluster_name)}"
INVENTORY_DIR="${ROOT_DIR}/kubespray/inventory/${CLUSTER_NAME}"

mkdir -p "${INVENTORY_DIR}"
terraform -chdir="${TF_DIR}" output -raw kubespray_inventory_yaml > "${INVENTORY_DIR}/hosts.yaml"

echo "Inventory written to ${INVENTORY_DIR}/hosts.yaml"
