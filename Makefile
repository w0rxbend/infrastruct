.PHONY: validate validate-yaml validate-inventory validate-public-exposure-docs validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm validate-sops-policy scan-secrets

ANSIBLE_INVENTORY := ansible/inventories/homelab/hosts.yml
ANSIBLE_PLAYBOOKS := $(wildcard ansible/playbooks/*.yml)

validate: validate-yaml validate-inventory validate-public-exposure-docs validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm validate-sops-policy scan-secrets

validate-yaml:
	@scripts/validate-yaml

validate-inventory:
	@scripts/validate-inventory

validate-public-exposure-docs:
	@scripts/validate-public-exposure-docs

validate-ansible-lint:
	@command -v ansible-lint >/dev/null 2>&1 || { echo "ERROR: ansible-lint is required for Ansible lint validation. Install ansible-lint."; exit 1; }
	@ansible-lint -c .ansible-lint ansible

validate-ansible-syntax:
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "ERROR: ansible-playbook is required for Ansible syntax validation. Install ansible-core."; exit 1; }
	@if [ -z "$(ANSIBLE_PLAYBOOKS)" ]; then echo "No Ansible playbooks found."; else \
		for playbook in $(ANSIBLE_PLAYBOOKS); do \
			echo "Validating Ansible syntax: $$playbook"; \
			ansible-playbook -i "$(ANSIBLE_INVENTORY)" --syntax-check "$$playbook"; \
		done; \
	fi

validate-compose:
	@scripts/validate-compose

validate-swarm:
	@scripts/validate-swarm

validate-sops-policy:
	@scripts/validate-sops-policy

scan-secrets:
	@scripts/scan-secrets
