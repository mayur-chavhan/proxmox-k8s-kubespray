SHELL := /bin/bash
ROOT_DIR := $(shell pwd)
TF_DIR := $(ROOT_DIR)/terraform

.PHONY: tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy inventory kubespray-install kubespray-upgrade kubespray-reset

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-validate:
	terraform -chdir=$(TF_DIR) validate

tf-plan:
	terraform -chdir=$(TF_DIR) plan -out=tfplan

tf-apply:
	terraform -chdir=$(TF_DIR) apply tfplan

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy

inventory:
	./scripts/10-generate-inventory.sh

kubespray-install:
	./scripts/20-install-kubespray.sh

kubespray-upgrade:
	./scripts/30-upgrade-cluster.sh

kubespray-reset:
	./scripts/40-reset-cluster.sh
