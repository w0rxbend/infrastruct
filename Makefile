.PHONY: validate validate-local-contracts validate-full validate-runner validate-container validate-runner-proof validate-container-proof validate-yaml validate-inventory live-inventory-healthcheck live-inventory-healthcheck-runner test-live-inventory-healthcheck test-inventory-validator test-inventory-contract-maps test-inventory-contract-maps-runner test-inventory-assertions test-inventory-assertions-runner validate-public-exposure-docs test-public-exposure-validator test-real-fleet-promotion-rehearsal test-real-fleet-promotion-rehearsal-runner validate-promotion-evidence test-promotion-evidence-validator validate-operational-readiness test-operational-readiness-validator validate-ci-path-filters test-ci-path-filter-validator validate-ansible-lint validate-ansible-syntax test-ansible-syntax-validator validate-compose validate-swarm validate-sops-policy test-sops-policy-validator test-sops-workflow-proof scan-secrets test-secret-scanner

validate: validate-full

validate-local-contracts: validate-yaml validate-inventory test-inventory-validator test-inventory-contract-maps test-inventory-assertions test-ansible-syntax-validator validate-public-exposure-docs test-public-exposure-validator test-real-fleet-promotion-rehearsal validate-promotion-evidence test-promotion-evidence-validator validate-operational-readiness test-operational-readiness-validator test-live-inventory-healthcheck validate-ci-path-filters test-ci-path-filter-validator validate-sops-policy test-sops-policy-validator test-sops-workflow-proof scan-secrets test-secret-scanner

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

live-inventory-healthcheck:
	@scripts/live-inventory-healthcheck

live-inventory-healthcheck-runner:
	@scripts/live-inventory-healthcheck --runner

test-live-inventory-healthcheck:
	@echo "==> Testing live inventory healthcheck fixtures"
	@scripts/test-live-inventory-healthcheck

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

test-real-fleet-promotion-rehearsal:
	@echo "==> Testing real-fleet promotion rehearsal"
	@scripts/test-real-fleet-promotion-rehearsal

test-real-fleet-promotion-rehearsal-runner:
	@echo "==> Testing runner-backed real-fleet promotion rehearsal"
	@scripts/validate-runner scripts/test-real-fleet-promotion-rehearsal --require-runner-gates

validate-promotion-evidence:
	@echo "==> Validating promotion evidence consistency"
	@scripts/validate-promotion-evidence

test-promotion-evidence-validator:
	@echo "==> Testing promotion evidence validator fixtures"
	@scripts/test-promotion-evidence-validator

validate-operational-readiness:
	@echo "==> Validating operational readiness lock"
	@scripts/validate-operational-readiness

test-operational-readiness-validator:
	@echo "==> Testing operational readiness validator fixtures"
	@scripts/test-operational-readiness-validator

validate-ci-path-filters:
	@echo "==> Validating focused CI path filters"
	@scripts/validate-ci-path-filters

test-ci-path-filter-validator:
	@echo "==> Testing focused CI path filter validator fixtures"
	@scripts/test-ci-path-filter-validator

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

test-sops-workflow-proof:
	@echo "==> Testing SOPS workflow proof"
	@scripts/test-sops-workflow-proof

scan-secrets:
	@scripts/scan-secrets

test-secret-scanner:
	@echo "==> Testing secret scanner fixtures"
	@scripts/test-secret-scanner
