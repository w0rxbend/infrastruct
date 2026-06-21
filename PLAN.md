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

The project must be maintainable by a human later. Every important decision, service, host role, and operational command should be discoverable from the repository without relying on memory.

## Current Review Status

The first iteration created a strong repository and documentation scaffold, but most executable infrastructure remains contract-only.

Completed:

- Top-level repository structure exists for Ansible, K3s/Flux, Docker Compose, Swarm, secrets, and docs.
- Ownership boundaries and operating assumptions are documented.
- Host, service, public exposure, maintenance, and secrets documentation templates exist.
- Placeholder Ansible inventory, baseline playbooks, role skeletons, Compose example, Swarm example, and `.sops.yaml` exist.
- YAML files parse successfully with local YAML parsing.
- Docker Compose example and Swarm stack example parse through `docker compose config`.

High-priority gaps:

- The inventory contains three placeholder RFC 5737 example hosts, not the required real 20-machine fleet.
- `docs/public-exposure.md` says no public exposure is declared, while placeholder inventory marks an example host as exposed on TCP 443.
- Ansible and SOPS/age are not installed in the current workstation environment, so documented commands cannot be verified locally.
- `.sops.yaml` uses a dummy age recipient and cannot protect real secrets.
- Baseline roles are debug-only placeholders; they do not implement users, SSH, packages, time sync, firewall defaults, monitoring, or ARM-specific settings.
- Runtime examples reference placeholder hosts and paths; they are patterns only, not deployable service management.
- `ansible/README.md` still says playbooks do not exist, which is stale after the skeleton was added.
- No schema, lint, or CI gate exists to catch placeholder values, mismatched inventory groups, plaintext secrets, or broken examples.

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

## Quality Gates To Add Before More Automation

These gates should be implemented before adding mutating playbooks or real public services:

1. Add a local toolchain bootstrap document or script for `ansible`, `ansible-lint`, `sops`, `age`, `yamllint`, Docker Compose, `kubectl`, and Flux CLI.
2. Add `.gitignore` rules for age private keys, decrypted secret files, local Ansible retry files, local inventories, temporary artifacts, and editor metadata.
3. Add a validation script or Makefile targets:
   - `validate-yaml`
   - `validate-inventory`
   - `validate-ansible-syntax`
   - `validate-compose`
   - `validate-swarm`
   - `scan-secrets`
4. Add inventory contract validation that checks:
   - every host has required fields
   - every `runtime_roles` value has matching group membership
   - architecture and storage groups match host vars
   - `public_exposure.exposed` matches the `public_exposed` group
   - placeholder hostnames, RFC 5737 addresses, and `replace-before-use` values cannot pass production validation
5. Add documentation consistency checks so public exposure records match inventory and service docs.
6. Replace the dummy SOPS recipient before adding any real secret.

## Phase 1: Repository Foundation

Status: mostly complete, with documentation drift to fix.

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

Remaining tasks:

1. Fix stale documentation in `ansible/README.md` so it reflects the existing placeholder playbooks and roles.
2. Add `.gitignore` for secret, Ansible, tool, and editor artifacts.
3. Add a short contributor/operator prerequisites section covering required local tools.
4. Decide whether `ALTERNATIVES.jsonl` is durable project documentation or an agent artifact; keep it only if it is intentionally part of the repo record.

Acceptance criteria:

- A new maintainer can understand what each directory owns.
- Documentation does not contradict the actual file tree.
- Tool prerequisites are explicit.

## Phase 2: Real Host Inventory

Status: incomplete. A placeholder contract exists, but the requested 20-machine inventory is not implemented.

Existing files:

- `ansible/inventories/homelab/hosts.yml`
- `ansible/inventories/homelab/group_vars/all.yml`
- Runtime group var placeholders
- `ansible/inventories/homelab/README.md`

Next tasks:

1. Replace all placeholder hosts with real host facts for the full fleet.
2. For every host, record hostname, management IP, architecture, hardware model, storage type, runtime roles, reliability notes, placement notes, and public exposure metadata.
3. Add missing `host_vars/` only when host-specific data becomes too large for `hosts.yml`; keep sensitive values encrypted.
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
5. Remove example public exposure from inventory unless it is replaced with a real documented route.
6. Add and run inventory validation once Ansible is available.

Acceptance criteria:

- `ansible-inventory` renders the full real inventory.
- Every real host has a declared runtime role and storage type.
- Publicly exposed hosts are visible from inventory and documented in `docs/public-exposure.md`.
- Placeholder values are absent from production inventory.

## Phase 3: Validation And Tooling Foundation

Status: new high-priority phase added by review.

Tasks:

1. Add tool installation guidance for the admin workstation.
2. Add validation commands through a Makefile, script, or documented equivalent.
3. Add `yamllint` configuration.
4. Add `ansible-lint` configuration once Ansible is installed.
5. Add a secret scan command that excludes encrypted SOPS files but catches plaintext credentials.
6. Add CI or a local pre-merge checklist that runs validation.

Acceptance criteria:

- A maintainer can run one documented command to validate the repository.
- Broken YAML, broken inventory, invalid playbook syntax, invalid Compose files, and obvious plaintext secrets are caught before changes are applied.

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
2. Replace role path usage with the repo-standard Ansible role layout if syntax or linting flags it.
3. Implement non-risky baseline facts and assertions first:
   - expected hostname check
   - architecture check
   - storage type check
   - required host field check
4. Implement package cache and required base packages per OS family.
5. Implement time sync policy.
6. Implement user and sudo policy only after operator accounts and authorized keys are decided.
7. Implement SSH hardening with a rollback path that preserves access.
8. Implement firewall defaults only after management access and public exposure records are accurate.
9. Extend health checks for disk thresholds, temperature/throttling where available, and service reachability.

Acceptance criteria:

- Baseline playbook is idempotent.
- Health check playbook gives useful output for all reachable hosts.
- Mutating tasks have check-mode behavior or documented safety constraints.
- Host-specific exceptions are documented in inventory vars or role READMEs.

## Phase 5: Secrets

Status: policy scaffold only.

Existing deliverables:

- `secrets/README.md`
- `.sops.yaml` with dummy recipient

Next tasks:

1. Install and verify `sops` and `age`.
2. Generate or choose real age recipients.
3. Replace the dummy recipient in `.sops.yaml`.
4. Add an encrypted non-production example secret and verify decrypt/edit commands.
5. Add `.gitignore` safeguards for age private keys and decrypted outputs.
6. Review `.sops.yaml` path and encrypted key regexes for Ansible vars, Kubernetes secrets, Compose env files, and Swarm secret inputs.
7. Document key recovery and recipient rotation with exact commands tested locally.

Acceptance criteria:

- No plaintext real secrets are committed.
- A maintainer can encrypt, edit, decrypt, rotate, and recover a test secret using documented commands.
- The repository cannot be mistaken as ready for real secrets while the dummy recipient remains.

## Phase 6: Public Exposure Management

Status: documentation contract exists, but it is not reconciled with inventory.

Next tasks:

1. Remove or replace placeholder public exposure in inventory.
2. Add real public exposure records for every known route or explicitly document that discovery is pending.
3. Map each public port to runtime, proxy owner, host or cluster, internal target, firewall intent, secret dependency, and review notes.
4. Add validation that public exposure in inventory, service docs, and `docs/public-exposure.md` agree.
5. Add firewall role integration only after real exposure records exist.

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

Next tasks:

1. Add `ansible/playbooks/docker.yml`.
2. Add `ansible/playbooks/deploy-compose.yml`.
3. Add `ansible/roles/docker_engine/`.
4. Add `ansible/roles/compose_service/`.
5. Replace the placeholder example with one real low-risk service or keep it clearly under an examples namespace.
6. Ensure service target host exists in inventory.
7. Add validation for Compose files.

Acceptance criteria:

- Compose service files are stored in Git.
- Ansible deploys Compose services to the intended host.
- No service requires an undocumented manual `docker run` command.

## Phase 8: Docker Swarm Management

Status: reference pattern only.

Existing deliverables:

- `swarm/stacks/example-stack.yml`
- `swarm/stacks/README.md`

Next tasks:

1. Add `ansible/playbooks/swarm.yml`.
2. Add `ansible/playbooks/deploy-swarm.yml`.
3. Add `ansible/roles/swarm_node/`.
4. Add `ansible/roles/swarm_stack/`.
5. Remove obsolete Compose `version` key from stack examples if validation continues warning about it.
6. Decide and document required Swarm node labels such as `storage=ssd`.
7. Move one existing stack into Git as the reference pattern.

Acceptance criteria:

- Swarm stack files are stored in Git.
- Ansible deploys stacks from a Swarm manager.
- Swarm manager/worker roles are visible in real inventory.

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

1. Add `.gitignore` and local toolchain prerequisites.
2. Fix stale docs and public exposure contradictions.
3. Install or document Ansible/SOPS/age requirements and run syntax checks.
4. Replace placeholder inventory with real host facts or add a clearly separated `examples/` inventory so production inventory is empty until real data exists.
5. Add validation targets for YAML, inventory contracts, Compose/Swarm examples, and secret scanning.
6. Replace dummy SOPS recipient and add one encrypted test secret.

## Merge Checklist

- Does the change belong to the correct runtime layer?
- Is every host or service documented?
- Are public ports documented consistently in inventory, service docs, and public exposure docs?
- Are secrets encrypted with real recipients?
- Is the playbook or manifest idempotent/reconcilable?
- Is there a verification command in the README?
- Are comments used where intent is not obvious?
- Do local validation commands pass?
- Could a maintainer understand the change six months later?
