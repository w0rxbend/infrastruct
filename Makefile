.PHONY: validate validate-local-contracts validate-full validate-runner validate-container validate-yaml validate-inventory test-inventory-validator validate-public-exposure-docs test-public-exposure-validator validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm validate-sops-policy test-sops-policy-validator scan-secrets test-secret-scanner

validate: validate-full

validate-local-contracts: validate-yaml validate-inventory test-inventory-validator validate-public-exposure-docs test-public-exposure-validator validate-sops-policy test-sops-policy-validator scan-secrets test-secret-scanner

validate-full: validate-local-contracts validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm

validate-runner:
	@scripts/validate-runner

validate-container: validate-runner

validate-yaml:
	@scripts/validate-yaml

validate-inventory:
	@scripts/validate-inventory

test-inventory-validator:
	@echo "==> Testing inventory validator fixtures"
	@scripts/test-inventory-validator

validate-public-exposure-docs:
	@echo "==> Validating production public exposure documentation"
	@scripts/validate-public-exposure-docs

test-public-exposure-validator:
	@echo "==> Testing public exposure validator fixtures"
	@scripts/test-public-exposure-validator

validate-ansible-lint:
	@scripts/validate-ansible-lint

validate-ansible-syntax:
	@scripts/validate-ansible-syntax

validate-compose:
	@scripts/validate-compose

validate-swarm:
	@scripts/validate-swarm

validate-sops-policy:
	@scripts/validate-sops-policy

test-sops-policy-validator:
	@echo "==> Testing SOPS policy validator fixtures"
	@scripts/test-sops-policy-validator

scan-secrets:
	@scripts/scan-secrets

test-secret-scanner:
	@echo "==> Testing secret scanner fixtures"
	@scripts/test-secret-scanner
