# Homelab IaC Implementation Plan

Date: 2026-06-21
Last reviewed: 2026-06-21

## Goal

Build this repository into the source of truth for managing the homelab:

- Physical host inventory and baseline configuration
- K3s cluster lifecycle and GitOps applications
- Docker Compose services
- Docker Swarm stacks
- Public exposure documentation
- Secrets handling
- Maintenance workflows
- Human-readable operational documentation

The project must be maintainable by a human later. Every important decision, service, host role, public route, secret policy, and operational command should be discoverable from the repository without relying on memory.

## Current Review Status

The repository is now a safer contract scaffold. The earlier placeholder production inventory has been quarantined into an examples inventory, local artifact safeguards exist, and validation entrypoints have started to land. The repository is still not ready to manage real hosts because the production inventory is intentionally empty, Ansible is unavailable in the current workstation, SOPS still uses a dummy recipient, and the baseline/runtime automation remains skeletal.

Completed:

- Top-level repository structure exists for Ansible, K3s/Flux, Docker Compose, Swarm, secrets, and docs.
- Ownership boundaries and operating assumptions are documented.
- Host, service, public exposure, maintenance, and secrets documentation templates exist.
- Placeholder inventory data was moved out of production into `ansible/inventories/examples/`.
- Production inventory at `ansible/inventories/homelab/hosts.yml` preserves required groups but declares no hosts or public exposure.
- `docs/public-exposure.md` now matches production inventory: no production public routes are declared.
- `ansible/README.md` reflects the current placeholder playbooks and role skeletons.
- Operator prerequisites are documented in `README.md` and `ansible/README.md`.
- `.gitignore` covers local secrets, decrypted outputs, age identities, Ansible retry/local inventory files, temporary artifacts, caches, and editor metadata.
- `.yamllint`, `Makefile`, and validation scripts exist for YAML, inventory contract checks, Ansible syntax checks, Compose validation, Swarm validation, and obvious plaintext secret scanning.
- `scripts/validate-inventory`, `scripts/scan-secrets`, `scripts/validate-yaml`, `scripts/validate-compose`, and `scripts/validate-swarm` ran locally.
- `scripts/validate-inventory` rejects placeholder values, RFC 5737 production addresses, missing required host fields, runtime-role/group drift, architecture/storage group drift, and public exposure group drift.
- `.sops.yaml` and `secrets/README.md` now clearly warn that the dummy age recipient is not usable for real secrets.

Current gaps and findings:

- The requested real 20-machine inventory is still not implemented.
- `make validate` fails on this workstation because `ansible-playbook` is not installed.
- `ansible-inventory`, `ansible-playbook`, `sops`, and `age-keygen` are still absent from the current workstation environment.
- `scripts/validate-yaml` emits a yamllint warning because `.sops.yaml` has no `---` document start.
- `scripts/validate-swarm` still emits Docker Compose's obsolete `version` key warning for `swarm/stacks/example-stack.yml`.
- No `ansible-lint` configuration or Make target exists yet, despite the documented expectation to use `ansible-lint`.
- No CI or committed pre-merge checklist runs the validation commands.
- No documentation consistency validator checks inventory public exposure against `docs/public-exposure.md` and service docs.
- `.sops.yaml` still uses a dummy age recipient and has not been verified with a real encrypted test secret.
- The SOPS `encrypted_regex` rules are broad scaffolding and need review against actual Ansible vars, Kubernetes Secret manifests, Compose env files, and Swarm secret inputs before real secrets are added.
- Runtime examples remain patterns only; they are not deployable service management.
- Baseline Ansible roles are debug-only placeholders and do not implement users, SSH, packages, time sync, firewall defaults, monitoring, or ARM-specific settings.
- `ALTERNATIVES.jsonl`, `SCORES.jsonl`, `MEMORY.md`, and `AGENT_LOG.md` appear to be agent-process artifacts; decide whether they are intentionally durable project documentation.

## Operating Model

Use clear ownership boundaries:

| Area | Owner Tool | Repo Location |
| --- | --- | --- |
| Host inventory | Ansible | `ansible/inventories/homelab/` |
| Host baseline | Ansible | `ansible/playbooks/`, `ansible/roles/` |
| K3s installation and upgrades | Ansible | `ansible/playbooks/k3s.yml` |
| K3s applications | Flux CD | `clusters/homelab/` |
| Kubernetes packaging | Helm + Kustomize | `clusters/homelab/` |
| Docker Compose services | Ansible + Compose files | `docker/compose/` |
| Docker Swarm stacks | Ansible + stack files | `swarm/stacks/` |
| Secrets | SOPS + age | `secrets/`, encrypted vars/manifests |
| Public exposure | Documentation + Ansible firewall/proxy config | `docs/public-exposure.md` |
| Maintenance | Ansible + documentation | `ansible/playbooks/maintenance.yml`, `docs/maintenance.md` |

## Non-Goals For Initial Implementation

- Do not introduce MAAS, Tinkerbell, or full network boot automation yet.
- Do not introduce Pulumi/OpenTofu until there are API-managed external resources.
- Do not introduce Vault unless secrets management itself becomes a dedicated project.
- Do not introduce a full backup platform before any service is marked worth preserving.
- Do not migrate everything into K3s. Docker, Docker Swarm, and K3s are all supported runtimes.

## Quality Gates Before More Automation

Status: partially implemented.

Completed:

1. Add `.gitignore` rules for age private keys, decrypted secret files, local Ansible retry files, local inventories, temporary artifacts, and editor metadata.
2. Add validation entrypoints:
   - `validate-yaml`
   - `validate-inventory`
   - `validate-ansible-syntax`
   - `validate-compose`
   - `validate-swarm`
   - `scan-secrets`
3. Add `.yamllint`.
4. Add inventory contract validation for required fields, runtime role groups, architecture/storage groups, public exposure group consistency, placeholder values, and RFC 5737 addresses.
5. Add a basic plaintext secret scan.

Remaining:

1. Add a reproducible workstation bootstrap path for `ansible-core`, `ansible-lint`, `sops`, `age`, `yamllint`, Docker Compose, `kubectl`, and Flux CLI.
2. Install or otherwise provide missing local tools, then run `make validate` successfully.
3. Add `ansible-lint` configuration and include `ansible-lint` in validation.
4. Add public exposure documentation consistency checks across inventory, service docs, and `docs/public-exposure.md`.
5. Remove yamllint warning from `.sops.yaml`.
6. Remove obsolete `version` from Swarm stack examples.
7. Add CI or a documented pre-merge checklist that runs validation.
8. Replace the dummy SOPS recipient before adding any real secret.

## Phase 1: Repository Foundation

Status: complete except for agent-artifact policy.

Completed deliverables:

- `README.md`
- `PLAN.md`
- `docs/research-status.md`
- `docs/hosts.md`
- `docs/services.md`
- `docs/public-exposure.md`
- `docs/maintenance.md`
- `ansible/README.md`
- `clusters/README.md`
- `clusters/homelab/README.md`
- `docker/README.md`
- `docker/compose/README.md`
- `swarm/README.md`
- `swarm/stacks/README.md`
- `secrets/README.md`
- `.gitignore`
- operator prerequisites

Remaining tasks:

1. Decide whether `ALTERNATIVES.jsonl`, `SCORES.jsonl`, `MEMORY.md`, and `AGENT_LOG.md` are durable project documentation or agent artifacts.
2. If they are durable, document their purpose and retention policy.
3. If they are not durable, move them out of the project source tree or ignore them before the repository becomes the homelab source of truth.

Acceptance criteria:

- A new maintainer can understand what each directory owns.
- Documentation does not contradict the actual file tree.
- Tool prerequisites are explicit.
- Agent-process artifacts are either intentional documentation or excluded.

## Phase 2: Real Host Inventory

Status: production inventory is honest but empty. Real fleet facts are still missing.

Existing files:

- `ansible/inventories/homelab/hosts.yml`
- `ansible/inventories/homelab/group_vars/all.yml`
- Runtime group var placeholders
- `ansible/inventories/homelab/README.md`
- `ansible/inventories/examples/hosts.yml`
- `ansible/inventories/examples/README.md`

Completed:

1. Remove placeholder hosts from production inventory.
2. Move placeholder sample hosts to `ansible/inventories/examples/`.
3. Remove placeholder production public exposure.
4. Add production inventory validation script.

Next tasks:

1. Replace the empty production inventory with real host facts for the full fleet.
2. For every host, record hostname, management IP, architecture, hardware model, storage type, runtime roles, reliability notes, placement notes, and public exposure metadata.
3. Add `host_vars/` only when host-specific data becomes too large for `hosts.yml`; keep sensitive values encrypted.
4. Align groups with host vars for:
   - `k3s_servers`
   - `k3s_agents`
   - `docker_hosts`
   - `swarm_managers`
   - `swarm_workers`
   - `edge_nodes`
   - `arm64`
   - `armv7`
   - `pi_zero`
   - `ssd_storage`
   - `sdcard_storage`
   - `public_exposed`
5. Add a strict mode or explicit expected-host-count check once the real 20-machine fleet is known, so an accidentally empty production inventory cannot pass unnoticed.
6. Run both `scripts/validate-inventory` and `ansible-inventory` after Ansible is available.

Acceptance criteria:

- `ansible-inventory` renders the full real inventory.
- Every real host has a declared runtime role and storage type.
- Publicly exposed hosts are visible from inventory and documented in `docs/public-exposure.md`.
- Placeholder values are absent from production inventory.
- Empty production inventory is only valid during the explicit discovery phase.

## Phase 3: Validation And Tooling Foundation

Status: partially implemented.

Completed:

- `Makefile`
- `.yamllint`
- `scripts/validate-yaml`
- `scripts/validate-inventory`
- `scripts/validate-compose`
- `scripts/validate-swarm`
- `scripts/scan-secrets`

Validation results from this review:

- `scripts/validate-inventory`: passed.
- `scripts/scan-secrets`: passed.
- `scripts/validate-yaml`: passed with warning for `.sops.yaml` missing document start.
- `scripts/validate-compose`: passed locally through the available Docker/Podman Compose provider.
- `scripts/validate-swarm`: passed locally but warned that `swarm/stacks/example-stack.yml` uses obsolete `version`.
- `make validate`: failed because `ansible-playbook` is missing.

Next tasks:

1. Add `docs/toolchain.md` or `scripts/bootstrap-toolchain` with tested install commands for the admin workstation OS.
2. Install or provide `ansible-core`, `ansible-lint`, `sops`, and `age` in the current environment, then rerun `make validate`.
3. Add `.ansible-lint` and a `validate-ansible-lint` Make target.
4. Add `validate-public-exposure-docs` to compare inventory public exposure against `docs/public-exposure.md` and service docs.
5. Add a `validate-sops-policy` check that fails while the dummy age recipient remains if any non-example encrypted secret is present.
6. Decide whether missing optional tools should make `make validate` fail or whether there should be a separate `make validate-local-contracts` that runs without host-operation tooling.
7. Add CI or a local pre-merge checklist for the validation suite.

Acceptance criteria:

- A maintainer can run one documented command to validate the repository in the supported workstation environment.
- Broken YAML, broken inventory, invalid playbook syntax, invalid Compose files, invalid Swarm examples, stale public exposure docs, and obvious plaintext secrets are caught before changes are applied.
- Validation output distinguishes missing prerequisites from repository defects.

## Phase 4: Baseline Host Configuration

Status: skeleton only.

Existing deliverables:

- `ansible/playbooks/bootstrap.yml`
- `ansible/playbooks/baseline.yml`
- `ansible/playbooks/healthcheck.yml`
- `ansible/roles/common/`
- `ansible/roles/users/`
- `ansible/roles/ssh/`
- `ansible/roles/packages/`
- `ansible/roles/firewall/`
- `ansible/roles/monitoring_agent/`

Next tasks:

1. Verify playbook syntax with Ansible installed.
2. Add `ansible.cfg` if needed so role paths, inventory defaults, retry behavior, and callback output are predictable.
3. Replace role path usage with the repo-standard Ansible role layout if syntax or linting flags it.
4. Implement non-risky baseline facts and assertions first:
   - expected hostname check
   - architecture check
   - storage type check
   - required host field check
5. Implement package cache and required base packages per OS family.
6. Implement time sync policy.
7. Implement user and sudo policy only after operator accounts and authorized keys are decided.
8. Implement SSH hardening with a rollback path that preserves access.
9. Implement firewall defaults only after management access and public exposure records are accurate.
10. Extend health checks for disk thresholds, temperature/throttling where available, and service reachability.

Acceptance criteria:

- Baseline playbook is idempotent.
- Health check playbook gives useful output for all reachable hosts.
- Mutating tasks have check-mode behavior or documented safety constraints.
- Host-specific exceptions are documented in inventory vars or role READMEs.

## Phase 5: Secrets

Status: policy scaffold only; safer warnings and local-only workflow have been added.

Existing deliverables:

- `secrets/README.md`
- `.sops.yaml` with dummy recipient
- `.gitignore` safeguards for local/decrypted secret paths and age identities
- `scripts/scan-secrets`

Completed:

1. Add explicit warnings that the dummy age recipient cannot protect real secrets.
2. Document local-only SOPS/age test workflow.
3. Add ignored paths for local test secrets and decrypted outputs.

Next tasks:

1. Install and verify `sops` and `age`.
2. Generate or choose real age recipients.
3. Replace every dummy recipient in `.sops.yaml`.
4. Add an encrypted non-production example secret in a committed example path after real recipients exist, or document why encrypted examples remain local-only.
5. Review `.sops.yaml` path and encrypted key regexes for Ansible vars, Kubernetes Secrets, Compose env files, and Swarm secret inputs.
6. Add validation that blocks real secret paths while `.sops.yaml` still contains the dummy recipient.
7. Test and document key recovery and recipient rotation with exact commands.

Acceptance criteria:

- No plaintext real secrets are committed.
- A maintainer can encrypt, edit, decrypt, rotate, and recover a test secret using documented commands.
- The repository cannot be mistaken as ready for real secrets while the dummy recipient remains.
- SOPS policy encrypts the actual sensitive keys used by Ansible, Kubernetes, Compose, and Swarm.

## Phase 6: Public Exposure Management

Status: documentation and production inventory are reconciled to "none declared"; real discovery is still pending.

Completed:

1. Remove placeholder production public exposure from inventory.
2. Clarify `docs/public-exposure.md` that no production public routes are declared and discovery is pending.

Next tasks:

1. Add real public exposure records for every known route or explicitly document that discovery found none.
2. Map each public port to runtime, proxy owner, host or cluster, internal target, firewall intent, secret dependency, and review notes.
3. Add validation that public exposure in inventory, service docs, and `docs/public-exposure.md` agree.
4. Add firewall role integration only after real exposure records exist.

Acceptance criteria:

- A maintainer can answer what is exposed publicly by reading the repo.
- Proxy ownership is not ambiguous.
- Public exposure changes require a Git diff.

## Phase 7: Docker Compose Management

Status: reference pattern only.

Existing deliverables:

- `docker/compose/README.md`
- `docker/compose/example-service/compose.yml`
- `docker/compose/example-service/README.md`
- `scripts/validate-compose`

Next tasks:

1. Add `ansible/playbooks/docker.yml`.
2. Add `ansible/playbooks/deploy-compose.yml`.
3. Add `ansible/roles/docker_engine/`.
4. Add `ansible/roles/compose_service/`.
5. Move placeholder examples under an explicit examples namespace or replace them with one real low-risk service.
6. Ensure service target host exists in production inventory before adding deploy automation.
7. Extend Compose validation to catch service references to unknown inventory hosts once service metadata exists.

Acceptance criteria:

- Compose service files are stored in Git.
- Ansible deploys Compose services to the intended host.
- No service requires an undocumented manual `docker run` command.

## Phase 8: Docker Swarm Management

Status: reference pattern only.

Existing deliverables:

- `swarm/stacks/example-stack.yml`
- `swarm/stacks/README.md`
- `scripts/validate-swarm`

Next tasks:

1. Remove obsolete Compose `version` key from `swarm/stacks/example-stack.yml`.
2. Add `ansible/playbooks/swarm.yml`.
3. Add `ansible/playbooks/deploy-swarm.yml`.
4. Add `ansible/roles/swarm_node/`.
5. Add `ansible/roles/swarm_stack/`.
6. Decide and document required Swarm node labels such as `storage=ssd`.
7. Move one existing stack into Git as the reference pattern after real Swarm nodes exist in inventory.

Acceptance criteria:

- Swarm stack files are stored in Git.
- Ansible deploys stacks from a Swarm manager.
- Swarm manager/worker roles are visible in real inventory.
- Swarm validation runs without obsolete schema warnings.

## Phase 9: K3s Host Lifecycle

Status: directory scaffold only.

Tasks:

1. Document current K3s server and agent nodes from real inventory.
2. Add `ansible/playbooks/k3s.yml`.
3. Add `ansible/playbooks/reboot-k3s.yml`.
4. Add `ansible/roles/k3s_server/`.
5. Add `ansible/roles/k3s_agent/`.
6. Add `ansible/roles/k3s_node_labels/`.
7. Add node labels for storage type, hardware class, and workload suitability.
8. Add safe reboot ordering for K3s nodes.
9. Document K3s upgrade procedure.

Acceptance criteria:

- K3s node roles are represented in real inventory.
- Node labels match hardware and storage reality.
- Reboot playbook avoids restarting all servers at once.

## Phase 10: Flux GitOps For K3s Apps

Status: directory scaffold only.

Tasks:

1. Bootstrap Flux into the current K3s cluster.
2. Commit Flux bootstrap resources under `clusters/homelab/flux-system/`.
3. Add base `infrastructure/` and `apps/` Kustomizations.
4. Add one low-risk app using HelmRelease or Kustomize.
5. Document reconcile, suspend, resume, and debug procedures.
6. Document what must never be changed manually with `kubectl`.

Acceptance criteria:

- Flux reconciles from this repository.
- At least one app is managed from Git.
- A maintainer can find the app source and know how it is applied.

## Phase 11: Monitoring and Health

Status: placeholder role and docs only.

Tasks:

1. Decide minimum monitoring target: Uptime Kuma, Prometheus/Grafana, or both.
2. Implement host metrics agent role only after the monitoring endpoint exists.
3. Add public service checks for documented public routes.
4. Add checks for disk, memory, temperature, node readiness, and Flux failures.
5. Add `docs/monitoring.md`.

Acceptance criteria:

- Host health is visible.
- K3s health is visible.
- Public service availability is checked.

## Phase 12: Maintenance Automation

Status: documentation contract only.

Tasks:

1. Add `ansible/playbooks/maintenance.yml`.
2. Add `ansible/playbooks/update-os.yml`.
3. Add `ansible/playbooks/reboot.yml`.
4. Add Docker cleanup policy if needed.
5. Add `renovate.json` for container images, Helm charts, Ansible dependencies, and GitHub Actions if introduced.
6. Replace planned commands in `docs/maintenance.md` with tested commands as playbooks land.

Acceptance criteria:

- Maintenance can be run from documented commands.
- Reboots can be targeted by group.
- Dependency updates arrive as reviewable pull requests.

## Phase 13: Optional Backup Support

Status: deferred until a service requires it.

Tasks, only when needed:

1. Mark a service backup policy as `required`.
2. Choose the backup tool for that service type.
3. Add backup automation.
4. Add restore documentation.
5. Test restore and record the date.

Acceptance criteria:

- No backup system exists without a service that needs it.
- Every required backup has a documented restore path.

## Next Iteration Priority

1. Make validation clean and reproducible: fix `.sops.yaml` yamllint warning, remove Swarm `version`, add `ansible-lint`, and provide/install missing Ansible/SOPS/age tools.
2. Add a toolchain bootstrap document or script and rerun `make validate` until it passes in the supported workstation environment.
3. Add public exposure documentation consistency validation.
4. Decide and document the policy for agent artifacts in the repository.
5. Replace the empty production inventory with real 20-machine host facts, or keep discovery explicitly pending with an expected-host-count guard.
6. Replace dummy SOPS recipients with real recipients and verify a non-production encrypted secret workflow.
7. Start non-mutating Ansible assertions only after inventory and validation are trustworthy.

## Merge Checklist

- Does the change belong to the correct runtime layer?
- Is every host or service documented?
- Are production examples isolated from real desired state?
- Are public ports documented consistently in inventory, service docs, and public exposure docs?
- Are secrets encrypted with real recipients?
- Is the playbook or manifest idempotent/reconcilable?
- Is there a verification command in the README?
- Do local validation commands pass without unresolved warnings?
- Could a maintainer understand the change six months later?
