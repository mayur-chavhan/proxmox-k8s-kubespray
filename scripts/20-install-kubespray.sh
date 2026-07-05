#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
KUBESPRAY_VERSION="${KUBESPRAY_VERSION:-v2.27.0}"
CLUSTER_NAME="${1:-$(terraform -chdir="${TF_DIR}" output -raw cluster_name)}"
ANSIBLE_USER="${ANSIBLE_USER:-$(terraform -chdir="${TF_DIR}" output -raw ansible_user 2>/dev/null || echo root)}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

KUBESPRAY_DIR="${ROOT_DIR}/kubespray/upstream"
INVENTORY_SRC="${ROOT_DIR}/kubespray/inventory/${CLUSTER_NAME}"
INVENTORY_DST="${KUBESPRAY_DIR}/inventory/${CLUSTER_NAME}"
VENV_DIR="${ROOT_DIR}/.venv-kubespray"

if [[ ! -d "${KUBESPRAY_DIR}" ]]; then
  git clone --depth 1 --branch "${KUBESPRAY_VERSION}" https://github.com/kubernetes-sigs/kubespray.git "${KUBESPRAY_DIR}"
fi

"${PYTHON_BIN}" -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
pip install --upgrade pip
pip install -r "${KUBESPRAY_DIR}/requirements.txt"

"${ROOT_DIR}/scripts/10-generate-inventory.sh" "${CLUSTER_NAME}"
rm -rf "${INVENTORY_DST}"
cp -R "${INVENTORY_SRC}" "${INVENTORY_DST}"

pushd "${KUBESPRAY_DIR}" >/dev/null
ansible-playbook -i "inventory/${CLUSTER_NAME}/hosts.yaml" --become --become-user=root -u "${ANSIBLE_USER}" cluster.yml
popd >/dev/null
