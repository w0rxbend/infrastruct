.PHONY: validate validate-local-contracts validate-full validate-runner validate-container validate-runner-proof validate-container-proof validate-yaml validate-inventory test-inventory-validator test-inventory-contract-maps test-inventory-contract-maps-runner test-inventory-assertions test-inventory-assertions-runner validate-public-exposure-docs test-public-exposure-validator validate-ansible-lint validate-ansible-syntax test-ansible-syntax-validator validate-compose validate-swarm validate-sops-policy test-sops-policy-validator scan-secrets test-secret-scanner

validate: validate-full

validate-local-contracts: validate-yaml validate-inventory test-inventory-validator test-inventory-contract-maps test-inventory-assertions test-ansible-syntax-validator validate-public-exposure-docs test-public-exposure-validator validate-sops-policy test-sops-policy-validator scan-secrets test-secret-scanner

validate-full: validate-local-contracts validate-ansible-lint validate-ansible-syntax validate-compose validate-swarm

validate-runner:
	@scripts/validate-runner

validate-container: validate-runner

validate-runner-proof:
	@scripts/validate-runner --proof

validate-container-proof: validate-runner-proof

validate-yaml:
	@scripts/validate-yaml

validate-inventory:
	@scripts/validate-inventory

test-inventory-validator:
	@echo "==> Testing inventory validator fixtures"
	@scripts/test-inventory-validator

test-inventory-contract-maps:
	@echo "==> Testing inventory contract map convergence"
	@scripts/test-inventory-contract-maps

test-inventory-contract-maps-runner:
	@echo "==> Testing inventory contract map semantic convergence in validation runner"
	@scripts/validate-runner scripts/test-inventory-contract-maps --require-semantic-ansible

test-inventory-assertions:
	@echo "==> Testing inventory assertion contracts"
	@scripts/test-inventory-assertions

test-inventory-assertions-runner:
	@echo "==> Testing inventory assertion semantic fixtures in validation runner"
	@tmp_output="$$(mktemp)"; \
	status=0; \
	scripts/validate-runner make test-inventory-assertions >"$${tmp_output}" 2>&1 || status="$$?"; \
	cat "$${tmp_output}"; \
	if grep -q "SKIP semantic Ansible fixture" "$${tmp_output}"; then \
		echo "ERROR: validation runner skipped inventory_assertions semantic fixtures." >&2; \
		status=1; \
	fi; \
	rm -f "$${tmp_output}"; \
	exit "$${status}"

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

test-ansible-syntax-validator:
	@echo "==> Testing Ansible syntax validator fixtures"
	@scripts/test-ansible-syntax-validator

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
