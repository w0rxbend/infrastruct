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

The project must be maintainable by a human later. Every important decision,
service, host role, public route, secret policy, and operational command should
be discoverable from the repository without relying on memory.

## Current Review Status

The repository is a safer contract scaffold, but it is still in discovery mode.
It must not yet be treated as live desired state for real hosts, real public
routes, or real secrets.

Completed and working:

- Top-level repository structure exists for Ansible, K3s/Flux, Docker Compose,
  Swarm, secrets, and operational documentation.
- Ownership boundaries and operating assumptions are documented.
- Host, service, public exposure, maintenance, and secrets documentation
  templates exist.
- Placeholder inventory data has been quarantined into
  `ansible/inventories/examples/`.
- Production inventory at `ansible/inventories/homelab/hosts.yml` preserves the
  required group shape while intentionally declaring no hosts.
- `docs/public-exposure.md` matches the production inventory's current state:
  no production public routes are declared.
- `.gitignore` covers local secrets, decrypted outputs, age identities, local
  Ansible artifacts, temporary files, caches, editor metadata, and future
  untracked agent-process artifacts.
- `.sops.yaml` now has a YAML document start and clearly warns that its age
  recipient is a dummy.
- The Swarm example no longer uses the obsolete top-level Compose `version`
  field.
- `docs/toolchain.md` documents a reproducible Debian/Ubuntu workstation
  toolchain for Ansible, ansible-lint, SOPS, age, yamllint, Docker Compose,
  kubectl, and Flux.
- `.ansible-lint` exists and `make validate` now includes an ansible-lint gate.
- `scripts/validate-public-exposure-docs` checks the empty production public
  exposure state against `docs/public-exposure.md`.
- `scripts/validate-sops-policy` blocks committed non-example encrypted SOPS
  files and plaintext-looking secret assignments while the dummy recipient
  remains.
- `repo-mode.yml` declares explicit `discovery` mode with
  `expected_host_count: 0`, and `scripts/validate-inventory` now rejects
  real-fleet mode when the production host count differs from the configured
  count.
- `ansible.cfg` pins the default inventory, role path, retry behavior, callback
  output, color policy, and Python interpreter discovery.
- Validation is split into `make validate-local-contracts` for cheap repository
  contracts and `make validate`/`make validate-full` for the complete
  supported-workstation gate.
- `docs/pre-merge-checklist.md` documents local contract checks, the full gate,
  supported workstation assumptions, and version-capture expectations.
- Agent-process artifacts have been moved under
  `docs/archive/agent-process/` and documented as non-operational archive
  context.

Validation results from this review:

- `scripts/validate-yaml`: passed with no yamllint output.
- `scripts/validate-inventory`: passed.
- `scripts/validate-inventory` correctly failed a disposable `real-fleet`
  check with `expected_host_count: 20` and zero production hosts.
- `scripts/validate-public-exposure-docs`: passed for the current no-route
  repository state.
- `scripts/validate-sops-policy`: passed.
- `make validate-local-contracts`: passed.
- `make validate`: failed on this workstation because `ansible-lint` is not
  installed. Later full-gate steps remain unverified here.

Current gaps and risks:

- The real 20-machine inventory is still not implemented.
- `make validate` is now stricter but cannot pass until the supported toolchain
  is installed or provided locally.
- The ansible-lint gate is unverified in this environment.
- `scripts/validate-public-exposure-docs` has a high-priority alias bug:
  `docs/services.md` now uses `Public host or port`, but the validator does not
  recognize that field for service records, so a service record with public
  exposure can be ignored and still pass.
- `scripts/validate-public-exposure-docs` compares route identifiers across
  sources but does not yet compare canonical field values such as runtime,
  proxy owner, target, firewall intent, secret dependency, or review notes.
- The public-exposure and inventory validators have no committed negative test
  fixtures, so schema drift between templates and parser aliases can regress
  silently.
- `scripts/validate-sops-policy` is a useful dummy-recipient guard, but it is
  not a replacement for a real recipient workflow or SOPS decrypt/edit/rotate
  verification.
- The root `AGENT_LOG.md` was truncated to iteration-4 task lines during
  artifact relocation; the historical log is preserved under
  `docs/archive/agent-process/AGENT_LOG.md`, but the root review log now needs
  an explicit summary block for this iteration.
- The root `MEMORY.md` was removed during artifact relocation even though the
  review workflow still expects it as the current durable memory file.
- No CI workflow runs the validation suite in a known toolchain.
- Runtime examples remain patterns only; they are not deployable service
  management.
- Baseline Ansible roles are debug-only placeholders and do not implement host
  assertions, users, SSH, packages, time sync, firewall defaults, monitoring, or
  ARM-specific settings.

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
| Public exposure | Documentation + firewall/proxy config | `docs/public-exposure.md` |
| Maintenance | Ansible + documentation | `ansible/playbooks/maintenance.yml`, `docs/maintenance.md` |

## Non-Goals For Initial Implementation

- Do not introduce MAAS, Tinkerbell, or full network boot automation yet.
- Do not introduce Pulumi/OpenTofu until there are API-managed external
  resources.
- Do not introduce Vault unless secrets management itself becomes a dedicated
  project.
- Do not introduce a full backup platform before any service is marked worth
  preserving.
- Do not migrate everything into K3s. Docker, Docker Swarm, and K3s are all
  supported runtimes.

## Next Iteration Priority

1. Fix `scripts/validate-public-exposure-docs` so service records recognize the
   documented `Public host or port` field and add negative fixtures proving
   service-only public routes, incomplete records, and cross-document drift fail.
2. Extend public exposure validation from route-id presence to canonical field
   equality across inventory, `docs/services.md`, and
   `docs/public-exposure.md`.
3. Install or provide the documented workstation toolchain, then run
   `make validate` until it passes. Capture exact versions in the review log.
4. Verify `ansible.cfg` with `ansible-playbook` and `ansible-lint`, then remove
   the temporary `role-name[path]` skip by changing playbooks to use role names
   through the pinned `roles_path`.
5. Decide whether `make validate-local-contracts` should include
   `scripts/validate-yaml`; currently full validation catches global YAML
   errors, but the fast local target does not.
6. Replace dummy SOPS recipients with real operator-controlled recipients before
   committing any non-example encrypted secret. Verify encrypt, edit, decrypt,
   rotate, and recovery commands against a non-production test secret.
7. Add CI or a containerized local validation runner so the complete gate can be
   reproduced even when the current workstation lacks Ansible or ansible-lint.
8. Start non-mutating Ansible assertions only after validation is clean:
   hostname, architecture, storage type, required host fields, and public
   exposure placement.

## Phase 1: Repository Foundation

Status: mostly complete.

Completed:

- Repository directory ownership is documented.
- Human-facing docs exist for hosts, services, public exposure, maintenance,
  secrets, Ansible, K3s/Flux, Compose, and Swarm.
- Operator prerequisites are documented from the top-level README.
- Agent-process artifacts are documented as non-source-of-truth in
  `docs/research-status.md`.
- `.gitignore` ignores future untracked agent-process artifacts.
- Historical agent-process artifacts are archived under
  `docs/archive/agent-process/` with an explicit non-operational README.
- `docs/pre-merge-checklist.md` names the fast local contract check, full
  validation command, and supported workstation assumptions.

Remaining:

1. Decide whether root `AGENT_LOG.md` and `MEMORY.md` remain current workflow
   files despite archived historical copies, and keep that policy consistent
   with `.gitignore`.
2. Add CI or a committed toolchain runner for the full validation gate.

Acceptance criteria:

- A new maintainer can understand what each directory owns.
- Documentation does not contradict the actual file tree.
- Tool prerequisites are explicit.
- Agent-process artifacts cannot be mistaken for durable homelab documentation.

## Phase 2: Real Host Inventory

Status: production inventory is honest but empty. Real fleet facts are still
missing.

Completed:

1. Remove placeholder hosts from production inventory.
2. Move placeholder sample hosts to `ansible/inventories/examples/`.
3. Remove placeholder production public exposure.
4. Add production inventory validation for required fields, group drift,
   placeholder values, RFC 5737 addresses, and public exposure group
   consistency.
5. Add `repo-mode.yml` and enforce discovery mode versus exact host count in
   `scripts/validate-inventory`.

Next tasks:

1. Replace the empty production inventory with real host facts for the full
   fleet.
2. For every host, record hostname, management IP, architecture, hardware model,
   storage type, runtime roles, reliability notes, placement notes, and public
   exposure metadata.
3. Align runtime, architecture, storage, edge, and public exposure groups with
   host vars.
4. Add negative test fixtures for discovery mode, real-fleet exact counts,
   missing `repo-mode.yml`, invalid types, and accidental non-empty discovery
   inventory.
5. Add `host_vars/` only when host-specific data becomes too large for
   `hosts.yml`; keep sensitive values encrypted.
6. Run both `scripts/validate-inventory` and `ansible-inventory` after Ansible
   is installed.

Acceptance criteria:

- `ansible-inventory` renders the full real inventory.
- Every real host has a declared runtime role and storage type.
- Publicly exposed hosts are visible from inventory and documented in
  `docs/public-exposure.md`.
- Placeholder values are absent from production inventory.
- Empty production inventory is valid only during explicit discovery mode.

## Phase 3: Validation And Tooling Foundation

Status: partially implemented; validation entrypoints exist but the local
toolchain is incomplete.

Completed:

- `Makefile`
- `.yamllint`
- `.ansible-lint`
- `docs/toolchain.md`
- `scripts/validate-yaml`
- `scripts/validate-inventory`
- `scripts/validate-public-exposure-docs`
- `scripts/validate-ansible-syntax` target through `make validate`
- `scripts/validate-compose`
- `scripts/validate-swarm`
- `scripts/validate-sops-policy`
- `scripts/scan-secrets`
- `ansible.cfg`
- `scripts/validate-ansible-syntax`
- split `make validate-local-contracts` and `make validate-full` targets
- `docs/pre-merge-checklist.md`

Next tasks:

1. Install or provide `ansible-core`, `ansible-lint`, `sops`, `age`, and Flux
   in the current environment, then rerun `make validate`.
2. Verify ansible-lint without scaffold-only skips where possible, then replace
   relative role paths in playbooks with role names.
3. Decide whether `validate-local-contracts` should run YAML validation so
   broken documentation or config YAML is caught by the cheap local gate.
4. Add negative test fixtures or a small script test harness for inventory,
   public exposure, SOPS policy, and secret scanning validators.
5. Add CI or a containerized local runner for the validation suite.

Acceptance criteria:

- A maintainer can run one documented command to validate the repository in the
  supported workstation environment.
- Broken YAML, broken inventory, invalid playbook syntax, invalid Compose files,
  invalid Swarm examples, stale public exposure docs, and obvious plaintext
  secrets are caught before changes are applied.
- Validation output distinguishes missing prerequisites from repository defects.

## Phase 4: Baseline Host Configuration

Status: skeleton only.

Existing deliverables:

- `ansible/playbooks/bootstrap.yml`
- `ansible/playbooks/baseline.yml`
- `ansible/playbooks/healthcheck.yml`
- Debug-only roles under `ansible/roles/`

Next tasks:

1. Verify playbook syntax and linting with Ansible installed.
2. Add `ansible.cfg`.
3. Implement non-mutating assertions first: expected hostname, architecture,
   storage type, runtime role, and required host metadata.
4. Implement package cache and required base packages per OS family.
5. Implement time sync policy.
6. Implement user and sudo policy only after operator accounts and authorized
   keys are decided.
7. Implement SSH hardening with a rollback path that preserves access.
8. Implement firewall defaults only after management access and public exposure
   records are accurate.
9. Extend health checks for disk thresholds, temperature/throttling where
   available, and service reachability.

Acceptance criteria:

- Baseline playbook is idempotent.
- Health check playbook gives useful output for all reachable hosts.
- Mutating tasks have check-mode behavior or documented safety constraints.
- Host-specific exceptions are documented in inventory vars or role READMEs.

## Phase 5: Secrets

Status: policy scaffold only; real secret handling is not ready.

Completed:

- `secrets/README.md`
- `.sops.yaml` with dummy recipient and warning comments
- `.gitignore` safeguards for local/decrypted secret paths and age identities
- `scripts/scan-secrets`
- `scripts/validate-sops-policy`

Next tasks:

1. Install and verify `sops` and `age`.
2. Generate or choose real age recipients.
3. Replace every dummy recipient in `.sops.yaml`.
4. Add an encrypted non-production example secret after real recipients exist,
   or document why encrypted examples remain local-only.
5. Review `.sops.yaml` path and encrypted key regexes against actual Ansible
   vars, Kubernetes Secret manifests, Compose env files, and Swarm secret
   inputs.
6. Test and document key recovery and recipient rotation with exact commands.

Acceptance criteria:

- No plaintext real secrets are committed.
- A maintainer can encrypt, edit, decrypt, rotate, and recover a test secret
  using documented commands.
- The repository cannot be mistaken as ready for real secrets while the dummy
  recipient remains.
- SOPS policy encrypts the actual sensitive keys used by Ansible, Kubernetes,
  Compose, and Swarm.

## Phase 6: Public Exposure Management

Status: inventory and public exposure docs agree on "none declared"; real
discovery is pending.

Completed:

1. Remove placeholder production public exposure from inventory.
2. Clarify `docs/public-exposure.md` that no production public routes are
   declared and discovery is pending.
3. Add initial validation between inventory public exposure metadata and
   `docs/public-exposure.md`.
4. Extend the validator to parse public exposure records from
   `docs/services.md` and require complete public exposure records in parsed
   sources.

Next tasks:

1. Fix the service-doc parser alias drift: recognize `Public host or port` as
   the documented service record field.
2. Compare canonical public exposure field values across inventory,
   `docs/services.md`, and `docs/public-exposure.md`, not only route IDs.
3. Add negative tests for service-only public routes, public-doc-only routes,
   missing required fields, mismatched proxy owner, mismatched firewall intent,
   and stale "no routes" statements.
4. Add real public exposure records for every known route or explicitly
   document that discovery found none.
5. Map each public port to runtime, proxy owner, host or cluster, internal
   target, firewall intent, secret dependency, and review notes.
6. Add firewall role integration only after real exposure records exist.

Acceptance criteria:

- A maintainer can answer what is exposed publicly by reading the repo.
- Proxy ownership is not ambiguous.
- Public exposure changes require a Git diff.
- Inventory, service docs, and public exposure docs cannot drift silently.

## Phase 7: Docker Compose Management

Status: reference pattern only.

Next tasks:

1. Add `ansible/playbooks/docker.yml`.
2. Add `ansible/playbooks/deploy-compose.yml`.
3. Add `ansible/roles/docker_engine/`.
4. Add `ansible/roles/compose_service/`.
5. Move placeholder examples under an explicit examples namespace or replace
   them with one real low-risk service.
6. Ensure service target hosts exist in production inventory before adding
   deploy automation.
7. Extend Compose validation to catch service references to unknown inventory
   hosts once service metadata exists.

Acceptance criteria:

- Compose service files are stored in Git.
- Ansible deploys Compose services to the intended host.
- No service requires an undocumented manual `docker run` command.

## Phase 8: Docker Swarm Management

Status: reference pattern only.

Completed:

- Remove obsolete Compose `version` key from `swarm/stacks/example-stack.yml`.

Next tasks:

1. Add `ansible/playbooks/swarm.yml`.
2. Add `ansible/playbooks/deploy-swarm.yml`.
3. Add `ansible/roles/swarm_node/`.
4. Add `ansible/roles/swarm_stack/`.
5. Decide and document required Swarm node labels such as `storage=ssd`.
6. Move one existing stack into Git as the reference pattern after real Swarm
   nodes exist in inventory.

Acceptance criteria:

- Swarm stack files are stored in Git.
- Ansible deploys stacks from a Swarm manager.
- Swarm manager/worker roles are visible in real inventory.
- Swarm validation runs without obsolete schema warnings.

## Phase 9: K3s Host Lifecycle

Status: directory scaffold only.

Next tasks:

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

Next tasks:

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

## Phase 11: Monitoring And Health

Status: placeholder role and docs only.

Next tasks:

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

Next tasks:

1. Add `ansible/playbooks/maintenance.yml`.
2. Add `ansible/playbooks/update-os.yml`.
3. Add `ansible/playbooks/reboot.yml`.
4. Add Docker cleanup policy if needed.
5. Add `renovate.json` for container images, Helm charts, Ansible dependencies,
   and GitHub Actions if introduced.
6. Replace planned commands in `docs/maintenance.md` with tested commands as
   playbooks land.

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

## Merge Checklist

- Does the change belong to the correct runtime layer?
- Is every host or service documented?
- Are production examples isolated from real desired state?
- Are public ports documented consistently in inventory, service docs, and
  public exposure docs?
- Are secrets encrypted with real recipients?
- Is the playbook or manifest idempotent/reconcilable?
- Is there a verification command in the README?
- Do local validation commands pass without unresolved warnings?
- Could a maintainer understand the change six months later?
