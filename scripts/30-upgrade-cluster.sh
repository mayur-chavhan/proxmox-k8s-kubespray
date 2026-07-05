#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
CLUSTER_NAME="${1:-$(terraform -chdir="${TF_DIR}" output -raw cluster_name)}"
ANSIBLE_USER="${ANSIBLE_USER:-$(terraform -chdir="${TF_DIR}" output -raw ansible_user 2>/dev/null || echo root)}"
VENV_DIR="${ROOT_DIR}/.venv-kubespray"
KUBESPRAY_DIR="${ROOT_DIR}/kubespray/upstream"

if [[ ! -d "${KUBESPRAY_DIR}" || ! -f "${VENV_DIR}/bin/activate" ]]; then
  echo "Kubespray environment not found. Run scripts/20-install-kubespray.sh first." >&2
  exit 1
fi

source "${VENV_DIR}/bin/activate"

pushd "${KUBESPRAY_DIR}" >/dev/null
ansible-playbook -i "inventory/${CLUSTER_NAME}/hosts.yaml" --become --become-user=root -u "${ANSIBLE_USER}" upgrade-cluster.yml
popd >/dev/null
