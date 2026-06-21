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
- `scripts/validate-public-exposure-docs` now recognizes the documented
  `Public host or port` service field, builds canonical route records from
  inventory, `docs/services.md`, and `docs/public-exposure.md`, and compares
  route identifier, runtime, proxy owner, public host or port, protocol, target
  host or cluster, target, firewall intent, secret dependency, and review notes
  across those sources.
- `scripts/test-public-exposure-validator` adds committed-style fixture coverage
  for the empty production state, service-only routes, public-doc-only routes,
  incomplete route records, runtime drift, public host or port drift, protocol
  drift, target drift, host or cluster placement drift, proxy owner drift,
  firewall intent drift, secret dependency drift, review notes drift, duplicate
  route IDs, malformed Markdown table rows, planned placeholders, active
  placeholders, valid and invalid non-public service states, and stale
  "no routes" documentation.
- `make validate-local-contracts` now runs YAML validation, the public exposure
  fixture harness, inventory validator fixtures, SOPS policy fixtures, and
  secret scanner fixtures.
- `Containerfile` and `scripts/validate-runner` provide a containerized full
  validation runner with pinned Ansible, ansible-lint, yamllint, SOPS, age,
  kubectl, Flux, Docker CLI, and Docker Compose versions.
- `ansible/playbooks/baseline.yml` now references roles by role name through the
  pinned `roles_path`, and the temporary ansible-lint `role-name[path]` skip has
  been removed.
- `.yamllint` has been adjusted to satisfy ansible-lint's YAML rule
  requirements; the previous ansible-lint `.yamllint` compatibility warning is
  resolved.
- `.github/workflows/validate.yml` runs the committed validation runner in CI,
  first reporting pinned tool versions and then running the complete gate.
- `scripts/validate-ansible-lint` isolates the known third-party `pathspec`
  deprecation warning from the pinned ansible-lint stack while preserving
  ansible-lint failures and rule warnings.
- `docs/toolchain.md` documents a no-cache validation-runner pin-refresh
  procedure for `Containerfile` and tool-version changes.
- Planned and non-production public exposure records are explicitly documented
  as source-local drafts, and fixture coverage proves they do not have to align
  across inventory, service docs, and the public exposure register until
  promoted to active production exposure.
- Inactive service draft records are still required to keep the complete public
  exposure field structure, even when `Public host or port` is `none`; a
  negative fixture covers the prior bypass.
- Inventory validator fixtures now cover unknown repository modes, malformed
  group host mappings, missing required host fields, unknown runtime roles,
  runtime-role group drift, placeholder values, RFC 5737 addresses, and public
  exposure group drift.
- SOPS policy and secret scanner fixtures now cover allowlisted fake secrets,
  ignored example paths, binary files, lowercase and mixed-case secret keys,
  `.sops.yaml` naming, and JSON encrypted-file naming.
- Discovery-mode Ansible syntax checks use a temporary local synthetic
  inventory so the full validation gate remains warning-clean while production
  inventory intentionally has zero hosts.
- `scripts/test-ansible-syntax-validator` now exercises syntax validator mode
  handling for discovery mode, real-fleet mode, missing or malformed
  `repo-mode.yml`, invalid repository modes, and invalid expected host count
  types. `make validate-local-contracts` runs this harness.
- `scripts/validate-runner --proof`, `make validate-runner-proof`, and
  `make validate-container-proof` provide a one-command no-cache validation
  runner proof path that rebuilds with `--no-cache --pull`, reports versions,
  and runs the complete gate from the rebuilt image.
- `ansible/roles/inventory_assertions/` has been added and
  `ansible/playbooks/baseline.yml` now runs it before the placeholder baseline
  roles. The role checks required host fields, hostname identity, IPv4
  management address shape, allowed architecture and storage values, runtime
  role values, and public exposure record structure.
- `inventory_assertions` is now explicitly run with `become: false` in
  `baseline.yml`, so the assertion-first preflight does not inherit the
  play-level privilege escalation used by later baseline roles.
- `inventory_assertions` now checks rendered Ansible group placement for
  runtime roles, architecture, storage type, Raspberry Pi Zero hardware, and
  public exposure membership.
- `scripts/validate-ansible-syntax` now runs `scripts/validate-inventory`
  before choosing the discovery synthetic inventory or real-fleet production
  inventory, so standalone syntax validation enforces repository mode,
  host-count, and production inventory contracts first.
- `scripts/test-inventory-assertions` and
  `tests/fixtures/inventory-assertions/` add static privilege-boundary checks
  and inventory assertion fixture coverage. When `ansible-playbook` is
  available, the harness also executes the real role against positive and
  negative fixture inventories.
- `scripts/test-ansible-syntax-validator` now includes a fixture proving
  nonzero `ansible-playbook --syntax-check` exits and diagnostic output are
  propagated.
- The validation-runner no-cache rebuild procedure has been executed once and
  recorded with observed pinned tool versions in `docs/toolchain.md`.
- Root `AGENT_LOG.md` and `MEMORY.md` are documented as current agent workflow
  context only, not homelab source-of-truth documentation.

Validation results from this review:

- `scripts/validate-yaml`: passed with no yamllint output.
- `scripts/validate-inventory`: passed.
- `scripts/test-inventory-validator`: passed, including discovery, missing
  mode, invalid mode type, accidental non-empty discovery inventory, exact
  real-fleet count, real-fleet count mismatch, unknown mode, malformed group
  host mappings, missing required host fields, unknown runtime roles, runtime
  group drift, placeholder values, RFC 5737 addresses, and public exposure
  group drift fixtures.
- `scripts/test-inventory-assertions`: passed locally; local execution skipped
  the real Ansible role fixtures because this workstation does not have
  `ansible-playbook` installed.
- `scripts/test-ansible-syntax-validator`: passed, including discovery-mode
  synthetic inventory use, real-fleet production inventory use, propagated fake
  `ansible-playbook` syntax failure, missing mode file, malformed mode YAML,
  scalar mode YAML, unknown mode, and invalid host count type fixtures.
- `scripts/validate-public-exposure-docs`: passed for the current no-route
  repository state.
- `scripts/test-public-exposure-validator`: passed.
- `scripts/validate-sops-policy`: passed.
- `scripts/test-sops-policy-validator`: passed.
- `scripts/scan-secrets`: passed.
- `scripts/test-secret-scanner`: passed.
- `make validate-local-contracts`: passed.
- `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner --versions`: passed
  from the cached validation image and reported ansible-core 2.18.6,
  ansible-lint 25.6.1, yamllint 1.37.1, SOPS 3.11.0, age 1.2.1, Docker CLI
  28.2.2, Docker Compose 2.36.2, kubectl 1.34.0, and Flux 2.6.4.
- `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner make
  test-inventory-assertions`: passed from the cached validation image and
  executed the real `inventory_assertions` role fixture cases with
  `ansible-playbook`.
- `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner`: passed the
  complete cached validation gate on rerun. One prior full-gate run failed in
  `test-inventory-assertions` because a fixture expected the missing required
  fields in a fixed order while Ansible's `difference` output returned the same
  fields in a different order; this reveals a brittle diagnostic assertion that
  should be normalized.
- Local `scripts/validate-ansible-syntax` could not be run directly on this
  workstation because `ansible-playbook` is not installed; the containerized
  runner remains the verified full-gate path here.
- ansible-lint passes with 0 failures and 0 rule warnings through
  `scripts/validate-ansible-lint`; the earlier `.yamllint` compatibility
  warning and `pathspec` Python `DeprecationWarning` lines are no longer
  printed by the lint target.

Current gaps and risks:

- The real 20-machine inventory is still not implemented.
- Local workstation `make validate` still depends on local tool installation,
  but the containerized runner now provides a reproducible full-gate path.
- The discovery-mode synthetic Ansible syntax inventory intentionally avoids
  empty-inventory warnings, but it is not a substitute for syntax and host
  pattern validation against the eventual real fleet inventory.
- The discovery-mode synthetic Ansible syntax inventory is intentionally
  artificial and would not satisfy the new `inventory_assertions` role if the
  assertions were executed. That is acceptable for `--syntax-check`, but it
  must not be treated as execution coverage.
- The new inventory assertion fixture harness mirrors Ansible role behavior in
  Python and optionally executes the real role only when `ansible-playbook` is
  available. The containerized runner covers the real role path, but the mirror
  can drift from the YAML role if future assertions are changed in only one
  place.
- The inventory assertion fixture for missing required fields has an
  order-sensitive expected output check even though Ansible's list difference
  output is not a stable contract. This caused one full-gate failure before a
  rerun passed.
- The `inventory_assertions` role has fixtures for key negative cases, but it
  does not yet cover malformed `group_names`, missing or malformed assertion
  contract variables, multiple runtime roles on one host, public exposure
  service item type errors separate from missing fields, or hostnames/IPs that
  should be rejected by the repository-local inventory validator but are not
  currently checked by the role.
- Local Podman users may still see Docker-compatibility wrapper messages before
  validation-runner output; this is host noise, not repository validation
  output.
- `scripts/validate-sops-policy` is a useful dummy-recipient guard, but it is
  not a replacement for a real recipient workflow or SOPS decrypt/edit/rotate
  verification.
- The validator fixture harnesses duplicate disposable-repo setup logic; that
  remains acceptable while they are small, but it will become maintenance drag
  if more validators adopt the same pattern.
- Runtime examples remain patterns only; they are not deployable service
  management.
- Baseline Ansible roles beyond `inventory_assertions` are debug-only
  placeholders and do not implement users, SSH, packages, time sync, firewall
  defaults, monitoring, or ARM-specific settings.

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

1. Fix the brittle `test-inventory-assertions` diagnostic matching by making
   missing-field output deterministic in the role or by checking unordered
   fragments in the harness. Prove the full cached validation runner passes
   repeatedly after the change.
2. Reduce inventory assertion test drift by preferring real Ansible execution
   in the supported runner and keeping the Python mirror limited to local
   prerequisite-free checks, or by generating both checks from one shared
   contract table.
3. Add deeper `inventory_assertions` fixtures for malformed contract variables,
   malformed service item types, multiple runtime-role memberships, reverse
   group drift for every mapped group, and RFC 5737 or placeholder management
   data if those are intended to be enforced at Ansible runtime.
4. Replace dummy SOPS recipients with real operator-controlled recipients before
   committing any non-example encrypted secret. Verify encrypt, edit, decrypt,
   rotate, and recovery commands against a non-production test secret.
5. Begin real fleet discovery: record the 20-machine inventory and explicit
   active or planned public exposure metadata.
6. Add real public exposure records for every known route, or record that
   discovery found none after inventory capture.

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
- `Containerfile` and `scripts/validate-runner` provide a pinned containerized
  full validation runner for workstations with Docker or Podman.
- `.github/workflows/validate.yml` runs the pinned validation runner on pushes,
  pull requests, and manual dispatch.
- `docs/toolchain.md` documents how to refresh validation-runner pins and prove
  a no-cache rebuild.
- `make validate-runner-proof` and `make validate-container-proof` run the
  no-cache validation-runner proof through one reviewed command.
- `docs/toolchain.md` records the 2026-06-21 no-cache rebuild of the pinned
  validation image and the versions observed from that rebuilt image.
- Root `AGENT_LOG.md` and `MEMORY.md` are documented as current workflow
  context only, while archived copies remain under
  `docs/archive/agent-process/`.

Remaining:

1. Keep root workflow files clearly separated from operational documentation;
   do not let agent logs become inventory, service, public exposure, or secrets
   source of truth.

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
6. Add inventory validator fixtures for discovery mode, real-fleet exact
   counts, missing `repo-mode.yml`, invalid mode types, and accidental
   non-empty discovery inventory.
7. Add broader negative inventory fixtures for unknown repository modes,
   malformed group host mappings, missing required host fields, unknown runtime
   roles, runtime-role group drift, placeholder values, RFC 5737 addresses, and
   public exposure group inconsistencies.

Next tasks:

1. Replace the empty production inventory with real host facts for the full
   fleet.
2. For every host, record hostname, management IP, architecture, hardware model,
   storage type, runtime roles, reliability notes, placement notes, and public
   exposure metadata.
3. Align runtime, architecture, storage, edge, and public exposure groups with
   host vars.
4. Add deeper inventory transition fixtures when real fleet data arrives:
   hostname mismatch, architecture/storage reverse drift, non-mapping host vars,
   invalid public exposure service item types, and exposed hosts with incomplete
   service records.
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

Status: implemented locally and in CI with a pinned runner. The containerized
full gate is warning-clean from repository tools in discovery mode; Podman
workstations may still print a host Docker-compatibility wrapper line before
container output.

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
- `scripts/test-public-exposure-validator`
- public exposure fixture cases under `tests/fixtures/public-exposure/`
- `Containerfile`
- `scripts/validate-runner`
- `make validate-runner` / `make validate-container`
- `make validate-local-contracts` includes YAML validation
- baseline role references lint through `roles_path` without the temporary
  `role-name[path]` skip
- inventory validator fixture harness and fixtures
- SOPS policy validator fixture harness and fixtures
- secret scanner fixture harness and fixtures
- GitHub Actions workflow for the pinned validation runner
- `.yamllint` aligned with ansible-lint's YAML rule requirements
- `scripts/validate-ansible-lint` filters only the known third-party
  `pathspec` deprecation warning emitted by the pinned ansible-lint dependency
  stack.
- documented validation-runner pin-refresh procedure in `docs/toolchain.md`
- broader inventory, SOPS policy, and secret-scanner fixtures for high-risk
  transition cases
- discovery-mode Ansible syntax validation through a temporary synthetic
  inventory to avoid empty-inventory warnings while production inventory is
  intentionally empty
- first no-cache validation-runner rebuild executed and recorded with observed
  versions
- `scripts/test-ansible-syntax-validator` fixture harness covers syntax
  validator mode handling and is part of `make validate-local-contracts`.
- `make validate-runner-proof` / `make validate-container-proof` rebuild the
  validation runner without cache, report versions, and run the complete gate
  from the rebuilt image.
- `scripts/validate-ansible-syntax` now calls `scripts/validate-inventory`
  before running `ansible-playbook --syntax-check`, so standalone syntax
  validation enforces repository mode, expected host count, and production
  inventory shape before selecting an inventory.
- `scripts/test-ansible-syntax-validator` includes a fixture proving nonzero
  `ansible-playbook` syntax-check failures and diagnostics are propagated.
- `make validate-local-contracts` runs `scripts/test-inventory-assertions` so
  the assertion-role privilege boundary and fixture cases are part of the fast
  contract gate.

Next tasks:

1. Fix order-sensitive assertion fixture expectations so the full gate cannot
   fail because Ansible reports the same set of missing fields in a different
   order.
2. Keep the ansible-lint warning filter narrow; if future ansible-lint or
   `pathspec` output changes, prefer upgrading or repinning over broad stderr
   suppression.
3. Factor the repeated disposable-fixture harness setup only if it starts to
   obscure new validator coverage.
4. Add a small repeatability check for newly added validation harnesses when
   they depend on unordered tool output.

Acceptance criteria:

- A maintainer can run one documented command to validate the repository in the
  supported workstation environment.
- Broken YAML, broken inventory, invalid playbook syntax, invalid Compose files,
  invalid Swarm examples, stale public exposure docs, and obvious plaintext
  secrets are caught before changes are applied.
- Validation output distinguishes missing prerequisites from repository defects.

## Phase 4: Baseline Host Configuration

Status: assertion scaffold exists; mutating baseline automation is still
skeleton-only. Syntax and lint contracts are verified through the pinned
validation runner.

Existing deliverables:

- `ansible/playbooks/bootstrap.yml`
- `ansible/playbooks/baseline.yml`
- `ansible/playbooks/healthcheck.yml`
- Debug-only roles under `ansible/roles/`
- `ansible.cfg` pins `roles_path`, and `baseline.yml` uses role names rather
  than relative role paths.
- `ansible/roles/inventory_assertions/` performs non-mutating checks for
  required host fields, hostname identity, IPv4 management address shape,
  allowed architecture/storage/runtime values, runtime/architecture/storage/Pi
  Zero/public-exposure group placement, and public exposure record structure.
- `baseline.yml` sets `become: false` on `inventory_assertions`, keeping the
  assertion-first role unprivileged even though later placeholder baseline
  roles still inherit play-level `become: true`.
- `scripts/test-inventory-assertions` provides static coverage for the
  privilege boundary and fixture coverage for valid and invalid assertion-role
  metadata. In the pinned validation runner it also executes the real Ansible
  role against those fixtures.

Next tasks:

1. Make assertion diagnostics and fixture expectations deterministic. The
   missing-required-fields fixture should not depend on Ansible's ordering for
   `difference` output.
2. Add assertion-role fixtures for malformed contract variables, service list
   entries that are not mappings, multiple runtime roles with multiple expected
   groups, reverse group drift for every mapped group, and explicit
   `public_exposure.exposed: false` plus stale `public_exposed` membership.
3. Decide whether runtime Ansible assertions should also reject production
   placeholders and RFC 5737 management addresses, matching
   `scripts/validate-inventory`, or whether those remain repository-local
   checks only.
4. Decide whether the management address contract should remain IPv4-only or
   allow IPv6/hostnames, then align docs, inventory validator, and role
   assertions.
5. Implement package cache and required base packages per OS family.
6. Implement time sync policy.
7. Implement user and sudo policy only after operator accounts and authorized
   keys are decided.
8. Implement SSH hardening with a rollback path that preserves access.
9. Implement firewall defaults only after management access and public exposure
   records are accurate.
10. Extend health checks for disk thresholds, temperature/throttling where
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
- fixture harnesses for SOPS policy and secret scanning validators
- fixtures for allowlisted fake secrets, ignored example paths, binary files,
  lowercase and mixed-case secret keys, `.sops.yaml` files, and JSON encrypted
  files

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
7. Add higher-fidelity SOPS workflow validation after real recipients exist:
   encrypt, edit, decrypt, rotate, recovery, and one non-production encrypted
   sample that exercises the actual `.sops.yaml` rules.

Acceptance criteria:

- No plaintext real secrets are committed.
- A maintainer can encrypt, edit, decrypt, rotate, and recover a test secret
  using documented commands.
- The repository cannot be mistaken as ready for real secrets while the dummy
  recipient remains.
- SOPS policy encrypts the actual sensitive keys used by Ansible, Kubernetes,
  Compose, and Swarm.

## Phase 6: Public Exposure Management

Status: active public exposure contract validation is materially stronger; real
route discovery is still pending.

Completed:

1. Remove placeholder production public exposure from inventory.
2. Clarify `docs/public-exposure.md` that no production public routes are
   declared and discovery is pending.
3. Add initial validation between inventory public exposure metadata and
   `docs/public-exposure.md`.
4. Extend the validator to parse public exposure records from
   `docs/services.md` and require complete public exposure records in parsed
   sources.
5. Fix the service-doc parser alias drift: recognize `Public host or port` as
   the documented service record field.
6. Compare canonical public exposure field values across inventory,
   `docs/services.md`, and `docs/public-exposure.md`, not only route IDs.
7. Add negative tests for service-only public routes, public-doc-only routes,
   missing required fields, mismatched proxy owner, mismatched firewall intent,
   and stale "no routes" statements.
8. Document the validation contract in service and public exposure docs, and run
   the public exposure fixture harness from `make validate-local-contracts`.
9. Compare `target_host_or_cluster` and `protocol` across inventory,
   `docs/services.md`, and `docs/public-exposure.md`.
10. Add negative fixtures for runtime drift, public host or port drift, target
   drift, host or cluster placement drift, protocol drift, secret dependency
   drift, review notes drift, duplicate route identifiers, malformed route
   tables, and placeholder misuse.
11. Add a positive fixture for one complete public route represented
   consistently in all three sources.
12. Model planned and non-production exposure states so active routes reject
    placeholders while inactive records are not counted as production exposure.
13. Validate `Exposure state` before relevance filtering so invalid states fail
    even on service records with `Public host or port: none`.
14. Document planned and non-production records as source-local drafts that are
    not required to align across inventory, `docs/services.md`, and
    `docs/public-exposure.md`.
15. Add fixtures proving source-local planned and non-production drafts can
    exist in only one source while active inventory-only routes still fail.
16. Enforce service-doc draft completeness so planned or non-production service
    records cannot skip required structural fields merely because
    `Public host or port` is `none`.

Next tasks:

1. Decide whether inactive draft records should require a stable route
   identifier and meaningful placement target, or whether `none` is acceptable
   as long as the structural field is present.
2. Add real public exposure records for every known route or explicitly
   document that discovery found none.
3. Map each public port to runtime, proxy owner, host or cluster, protocol,
   internal target, firewall intent, secret dependency, and review notes.
4. Add firewall role integration only after real exposure records exist.

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
