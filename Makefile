.PHONY: validate validate-local-contracts validate-full validate-runner validate-container validate-yaml validate-inventory validate-public-exposure-docs test-public-exposure-validator validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm validate-sops-policy scan-secrets

validate: validate-full

validate-local-contracts: validate-yaml validate-inventory validate-public-exposure-docs test-public-exposure-validator validate-sops-policy scan-secrets

validate-full: validate-local-contracts validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm

validate-runner:
	@scripts/validate-runner

validate-container: validate-runner

validate-yaml:
	@scripts/validate-yaml

validate-inventory:
	@scripts/validate-inventory

validate-public-exposure-docs:
	@echo "==> Validating production public exposure documentation"
	@scripts/validate-public-exposure-docs

test-public-exposure-validator:
	@echo "==> Testing public exposure validator fixtures"
	@scripts/test-public-exposure-validator

validate-ansible-lint:
	@command -v ansible-lint >/dev/null 2>&1 || { echo "MISSING TOOL: ansible-lint is required for Ansible lint validation. Install ansible-lint."; exit 1; }
	@ansible-lint -c .ansible-lint ansible

validate-ansible-syntax:
	@scripts/validate-ansible-syntax

validate-compose:
	@scripts/validate-compose

validate-swarm:
	@scripts/validate-swarm

validate-sops-policy:
	@scripts/validate-sops-policy

scan-secrets:
	@scripts/scan-secrets
