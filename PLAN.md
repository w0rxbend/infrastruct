# Homelab IaC Implementation Plan

Date: 2026-06-21
Last reviewed: 2026-06-22

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
- `inventory_assertions` missing-required-field diagnostics are deterministic
  enough for the fixture harness, and the cached validation runner has proved
  the focused assertion target repeatable across back-to-back real Ansible
  role executions.
- `scripts/test-inventory-assertions` no longer maintains a broad Python
  mirror of the Ansible role logic. Local prerequisite-free coverage now checks
  the baseline privilege boundary and fixture manifest renderability, while the
  pinned validation runner is the authoritative path for real assertion-role
  pass/fail behavior.
- `scripts/test-inventory-assertions` now labels local semantic Ansible role
  fixture cases as `SKIP` when `ansible-playbook` is unavailable, so local
  static checks cannot be mistaken for behavior coverage.
- `make test-inventory-assertions-runner` runs the assertion harness through
  the pinned validation runner and fails if semantic Ansible fixture execution
  is skipped.
- `ansible/inventories/homelab/group_contract.yml` now exists as a shared
  inventory group placement contract for runtime role, architecture, storage,
  Raspberry Pi Zero, and public-exposure group mappings.
- `scripts/validate-inventory` and `inventory_assertions` now consume the
  shared contract for group mapping and placement checks, and
  `scripts/test-inventory-contract-maps` exercises current and variant
  contract behavior without the previous source-string probes.
- `.github/workflows/validate.yml` has a focused
  `make test-inventory-assertions-runner` job when assertion-role or shared
  group-contract paths change.
- `scripts/test-ansible-syntax-validator` now copies the production
  `ansible/inventories/homelab/group_contract.yml` into every disposable
  fixture repository, so syntax-validator mode fixtures exercise the same
  contract path required by `scripts/validate-inventory`.
- `scripts/validate-inventory` now rejects group contracts where any
  `placement_rules` group is omitted from `required_groups`; the fixture suite
  proves this still fails in discovery mode with an empty production
  inventory.
- `scripts/test-inventory-contract-maps` stays local-only for the cheap
  contract gate. Runner-backed semantic contract coverage is isolated behind
  `make test-inventory-contract-maps-runner`.
- `inventory_assertions` now treats the contract `host_var` names and public
  exposure `exposed_field` as real extension points, matching
  `scripts/validate-inventory`; variant fixture coverage proves renamed
  contract fields are honored.
- `scripts/validate-inventory` now rejects unknown top-level
  `group_contract.yml` keys, unknown `placement_rules` names, and unknown keys
  inside each supported placement rule. The
  `contract-unknown-rule-key` fixture proves misspelled rule names fail even in
  discovery mode with an empty inventory.
- `docs/fleet-discovery-intake.md` provides a 20-host human intake worksheet
  for real-fleet discovery, including allowed inventory values, public
  exposure metadata, and explicit secret-exclusion guidance.
- `docs/real-fleet-promotion.md` defines the ordered promotion path from
  discovery mode to the real 20-machine inventory, including SOPS readiness,
  exact host-count mode switching, public exposure decisions, validation gates,
  and pre-operational rollback constraints.
- `scripts/prove-sops-workflow` adds a local SOPS readiness proof that refuses
  the documented dummy recipient, requires an operator-controlled recipient to
  be present in `.sops.yaml`, creates a temporary non-production secret,
  encrypts it through the repository policy, decrypts it, verifies the round
  trip, and now fails hard when `sops updatekeys` fails.
- `scripts/test-sops-workflow-proof` now covers a successful fake-tool proof,
  dummy recipient rejection, missing private identity failure, policy-recipient
  mismatch, hard `sops updatekeys` failure, and comma/whitespace recipient
  parsing.
- `scripts/prove-sops-workflow` now parses `.sops.yaml` structurally when
  checking policy recipients. It looks at applicable `creation_rules` age
  recipients, including `key_groups`, so comments and unrelated prose cannot
  satisfy the readiness preflight.
- `scripts/test-sops-workflow-proof` includes a regression fixture proving a
  recipient mentioned only in a `.sops.yaml` comment is rejected before fake
  SOPS tools are invoked.
- `inventory_assertions` now rejects obvious placeholder host facts and RFC
  5737 documentation management addresses, matching the production inventory
  validator's management-address safety boundary.
- `scripts/validate-inventory` and `inventory_assertions` now reject
  promotion-time intake placeholders such as `unknown`, `tbd`, `pending`, and
  `unset` from production inventory and direct Ansible preflight.
- Inactive planned and non-production public exposure drafts now require a
  stable non-placeholder route identifier and meaningful target host or cluster,
  even when `Public host or port` is `none`.
- `docs/real-fleet-promotion.md` now documents the promotion gate sequence for
  placeholder-free production inventory, hard SOPS proof requirements, focused
  fixture harnesses, active public exposure alignment, and exact real-fleet mode
  switching.
- `scripts/test-real-fleet-promotion-rehearsal` adds a fake
  discovery-to-real-fleet dry run covering empty discovery inventory,
  incomplete and complete fake real-fleet inventory, active public exposure
  alignment, and structural SOPS recipient checks. `make validate-local-contracts`
  now runs this rehearsal.
- `make test-real-fleet-promotion-rehearsal-runner` runs the promotion
  rehearsal through the pinned validation runner with `--require-runner-gates`.
  That path now proves the complete fake real-fleet fixture with standalone
  Ansible syntax validation, syntax failure propagation, semantic
  `inventory_assertions` fixture execution, and direct role execution against
  the promoted fake inventory.
- `.github/workflows/validate.yml` now runs the focused promotion-rehearsal job
  inside the pinned validation runner for promotion, inventory, public
  exposure, SOPS proof, and related documentation paths.
- `scripts/test-inventory-assertions` now derives fixture identity from the
  generated fixture manifest or rendered inventory under test instead of
  hardcoding `fixture-host`, so contract-map fixtures with hostnames such as
  `contract-fixture-host` reach semantic Ansible role execution.
- The inventory assertion fixture harness includes regression coverage for a
  non-`fixture-host` inventory hostname while preserving local `SKIP` reporting
  for semantic Ansible cases when `ansible-playbook` is unavailable.
- `.github/workflows/validate.yml` promotion-rehearsal path filters now watch
  the real `secrets/README.md` path, `scripts/test-inventory-assertions`, and
  `tests/fixtures/inventory-assertions/**`.

Validation results from this review:

- `scripts/validate-inventory`: passed.
- `scripts/test-inventory-validator`: passed, including discovery, missing
  mode, invalid mode type, accidental non-empty discovery inventory, exact
  real-fleet count, real-fleet count mismatch, unknown mode, malformed group
  host mappings, missing required host fields, unknown runtime roles, runtime
  group drift, shared-contract runtime-role remapping, malformed contract
  placement groups omitted from `required_groups`, unknown shared-contract rule
  keys, placeholder and intake-placeholder values, RFC 5737 addresses, and
  public exposure group drift fixtures.
- `scripts/test-inventory-assertions`: passed locally; local execution skipped
  the real Ansible role fixtures because this workstation does not have
  `ansible-playbook` installed. In this mode the harness explicitly reports
  each semantic role fixture as skipped and validates only static contracts and
  fixture renderability.
- `scripts/test-inventory-contract-maps`: passed locally for the current
  contract, a renamed group and host-var contract variant, and a
  malformed-contract fixture. When `ansible-playbook` is unavailable, semantic
  Ansible probes are reported as skipped and the local harness does not invoke
  the validation runner.
- `make test-inventory-contract-maps-runner`: passed through Podman using the
  cached pinned validation image, so the renamed group, renamed host-var,
  renamed public exposure exposed-field contract variant, and non-default
  generated fixture hostname were exercised by the real Ansible role.
- `make validate-local-contracts`: passed on 2026-06-22. Local semantic
  `inventory_assertions` role fixtures were skipped because this workstation
  does not have `ansible-playbook` installed, as expected for the cheap local
  gate.
- `scripts/test-sops-workflow-proof`: passed locally, proving successful
  fake-tool execution, dummy recipient rejection, missing private identity
  failure, policy-recipient mismatch, comment-only recipient rejection, hard
  updatekeys failure, and multi-recipient parsing.
- `scripts/test-real-fleet-promotion-rehearsal`: passed locally, proving the
  implemented fake promotion cases for inventory mode, active public exposure
  alignment, and structural SOPS recipient policy.
- `make test-real-fleet-promotion-rehearsal-runner`: passed through Podman
  using the cached pinned validation image, including Ansible syntax validation,
  syntax failure propagation, semantic assertion fixture execution, and direct
  `inventory_assertions` role execution against the complete fake real-fleet
  inventory.
- `scripts/test-public-exposure-validator`: passed locally, including valid
  inactive drafts, missing inactive draft route IDs, placeholder inactive draft
  route IDs, placeholder inactive draft placement targets, and active route
  alignment fixtures.
- `make test-inventory-assertions-runner`: passed through Podman using the
  cached pinned validation image, so the new placeholder and RFC 5737 assertion
  fixtures were exercised by the real Ansible role.
- `make test-inventory-contract-maps-runner`: passed on 2026-06-22 after the
  fixture identity repair, confirming semantic Ansible assertion execution was
  not skipped for the generated contract-map variants.
- `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner`: passed on
  2026-06-22 using the cached pinned validation image, including the complete
  validation gate and runner-backed semantic inventory assertion paths.
- Fresh review on 2026-06-22 reran `scripts/test-inventory-assertions`,
  `scripts/test-inventory-contract-maps`, `make validate-local-contracts`,
  `make test-inventory-contract-maps-runner`,
  `make test-real-fleet-promotion-rehearsal-runner`,
  `make test-inventory-assertions-runner`, and
  `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner`; all passed with the
  expected local semantic Ansible skips outside the runner.

Current gaps and risks:

- The real 20-machine inventory is still not implemented.
- `docs/fleet-discovery-intake.md` is only a worksheet. It contains deliberate
  `unknown` placeholders and must not be treated as desired state; facts become
  authoritative only after promotion into
  `ansible/inventories/homelab/hosts.yml`.
- Local workstation `make validate` still depends on local tool installation,
  but the containerized runner now provides a reproducible full-gate path.
- The discovery-mode synthetic Ansible syntax inventory intentionally avoids
  empty-inventory warnings, but it is not a substitute for syntax and host
  pattern validation against the eventual real fleet inventory.
- The discovery-mode synthetic Ansible syntax inventory is intentionally
  artificial and would not satisfy the new `inventory_assertions` role if the
  assertions were executed. That is acceptable for `--syntax-check`, but it
  must not be treated as execution coverage.
- The inventory assertion fixture harness now keeps local prerequisite-free
  checks focused on static contracts and fixture manifest shape. Real role
  behavior remains authoritative in the containerized runner, where
  `ansible-playbook` is available.
- Because local `scripts/test-inventory-assertions` can pass without executing
  the semantic role cases, maintainers must treat `make validate-local-contracts`
  as a fast scaffold check only. `make test-inventory-assertions-runner` or the
  full runner remains required before trusting assertion behavior changes.
- The generated assertion-fixture Ansible preflight now derives the expected
  inventory hostname, but it only checks that the host is present in `groups`.
  Mapping-shape errors are still caught by semantic role execution in the
  runner, not by the preflight itself.
- The `inventory_assertions` role has fixtures for key negative cases, but it
  does not yet cover malformed `group_names` separately from Ansible inventory
  rendering behavior.
- Local Podman users may still see Docker-compatibility wrapper messages before
  validation-runner output; this is host noise, not repository validation
  output.
- `scripts/validate-sops-policy` is a useful dummy-recipient guard, and
  `scripts/prove-sops-workflow` now proves encrypt/decrypt/updatekeys after
  real recipients are configured. Its fake-tool fixture coverage now exercises
  success and important prerequisite failures, but it is still script-contract
  coverage rather than real cryptographic proof.
- The SOPS readiness proof has not been executed in this review because
  `.sops.yaml` still intentionally contains the dummy recipient. It must be run
  after operator-controlled recipients replace the dummy value.
- Source-local inactive public exposure drafts are now structurally stricter,
  but duplicate route identifiers across inactive drafts are not globally
  checked because inactive records are intentionally excluded from active-route
  alignment.
- Strict `group_contract.yml` schema enforcement currently lives in
  `scripts/validate-inventory`. That is acceptable because the validation gate
  runs it before Ansible, but direct `inventory_assertions` role execution is
  not the schema authority.
- GitHub Actions path filters for focused jobs are maintained as inline regular
  expressions. The nonexistent `docs/secrets.md` path was fixed, but future
  path moves can still silently reduce focused-job coverage unless the filters
  are kept in review with documentation and script moves.
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

1. Replace dummy SOPS recipients with real operator-controlled recipients
   before committing any non-example encrypted secret. Run
   `scripts/prove-sops-workflow`, then manually or mechanically verify edit,
   rotation, and recovery commands against a non-production test secret.
2. Begin real fleet discovery using `docs/fleet-discovery-intake.md`: record
   the 20-machine inventory facts and explicit active, planned, or absent
   public exposure metadata without recording secrets.
3. Promote the completed intake into `ansible/inventories/homelab/hosts.yml`
   only when all 20 hosts are known, then switch `repo-mode.yml` to
   `real-fleet` with `expected_host_count: 20`.
4. Add real public exposure records for every known active route, or record
   that discovery found none after inventory capture.
5. Decide whether inactive draft route identifiers should be globally unique
   across source-local drafts to avoid promotion ambiguity, then encode that
   policy in the public exposure validator and fixtures if needed.
6. Decide whether shared-contract schema strictness should remain owned only by
   `scripts/validate-inventory` or whether direct `inventory_assertions` role
   runs should also reject malformed contract keys.
7. Tighten or document the generated assertion-fixture preflight boundary: either
   assert that the rendered target host has mapping host vars before role
   execution, or explicitly leave that validation to semantic Ansible role
   cases in the runner.
8. Add a lightweight guard for focused CI path filters so nonexistent watched
   paths and missed renamed documentation paths are caught during review.
9. Run `make validate-runner-proof` after future validation-runner pin or
   Containerfile changes to prove a no-cache rebuild, version report, and full
   gate from the rebuilt image.

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
missing. The shared group placement contract has started to centralize
inventory group semantics, and the current local validator and Ansible
assertion role now agree on group placement and contract host-variable names.

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
8. Add `ansible/inventories/homelab/group_contract.yml` as the shared
   runtime/architecture/storage/Pi Zero/public-exposure group placement
   contract used by the inventory validator and assertion role.
9. Enforce that every group referenced by `group_contract.yml` placement rules
   is also listed in `required_groups`, with fixture coverage proving a
   malformed contract fails even in discovery mode with an empty inventory.
10. Commit the
    `tests/fixtures/inventory/contract-placement-group-not-required/` malformed
    contract fixture so the discovery-mode regression coverage is retained.
11. Remove the duplicate top-level `host_var_fields` map from
    `group_contract.yml`; the per-rule `placement_rules.*.host_var` values are
    now the only authoritative host variable naming surface.
12. Enforce strict `group_contract.yml` schema keys for the current contract:
    top-level keys, supported placement rule names, and per-rule key sets.
13. Add the
    `tests/fixtures/inventory/contract-unknown-rule-key/` regression fixture so
    misspelled placement-rule names fail even while discovery mode has no real
    hosts.
14. Add `docs/fleet-discovery-intake.md` as a human worksheet for collecting
    the 20-machine real-fleet facts before promotion.
15. Add `docs/real-fleet-promotion.md` as the ordered checklist for moving from
    discovery mode to `real-fleet` mode.
16. Reject `unknown`, `tbd`, `pending`, `unset`, and similar intake
    placeholders from production inventory while keeping those values available
    in the human-only discovery worksheet.
17. Add `scripts/test-real-fleet-promotion-rehearsal` as a disposable fake
    promotion harness for the current implemented transition checks: discovery
    empty inventory, incomplete real-fleet host count, complete fake real-fleet
    inventory, active public exposure alignment, and structural SOPS recipient
    policy.
18. Add a runner-backed promotion rehearsal target that exercises standalone
    Ansible syntax validation and semantic `inventory_assertions` execution
    through the pinned validation runner for the complete fake real-fleet
    transition.

Next tasks:

1. Complete `docs/fleet-discovery-intake.md` with real facts for the full
   fleet.
2. Replace the empty production inventory with the completed real host facts
   only after all 20 machines are known.
3. For every host, record hostname, management IP, architecture, hardware model,
   storage type, runtime roles, reliability notes, placement notes, and public
   exposure metadata.
4. Align runtime, architecture, storage, edge, and public exposure groups with
   host vars.
5. Add deeper inventory transition fixtures when real fleet data arrives,
   especially cases that exercise real `ansible-inventory` rendering rather
   than harness-only malformed inventory structures.
6. Add `host_vars/` only when host-specific data becomes too large for
   `hosts.yml`; keep sensitive values encrypted.
7. Run both `scripts/validate-inventory` and `ansible-inventory` after Ansible
   is installed.

Acceptance criteria:

- `ansible-inventory` renders the full real inventory.
- Every real host has a declared runtime role and storage type.
- Publicly exposed hosts are visible from inventory and documented in
  `docs/public-exposure.md`.
- Placeholder values are absent from production inventory.
- Empty production inventory is valid only during explicit discovery mode.

## Phase 3: Validation And Tooling Foundation

Status: implemented for the current scaffold. The cheap local contract gate,
focused runner-backed assertion and promotion targets, focused contract-map
runner proof, and complete cached pinned validation runner are green for the
current discovery-mode scaffold.

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
- `scripts/test-inventory-assertions` distinguishes static local checks from
  skipped semantic Ansible role fixture execution when `ansible-playbook` is
  unavailable.
- `make test-inventory-assertions-runner` runs the assertion fixture harness
  inside the pinned validation runner and fails if semantic Ansible execution
  is skipped.
- `scripts/test-inventory-contract-maps` and
  `tests/fixtures/inventory-contract-maps/` check current agreement and two
  targeted drift cases between `scripts/validate-inventory` and
  `inventory_assertions`.
- `scripts/test-inventory-contract-maps` now exercises behavior against the
  shared group contract, including a renamed-group contract variant, instead of
  relying on the old Pi Zero and public-exposure source-string probes.
- `.github/workflows/validate.yml` runs a focused semantic assertion fixture
  job when assertion-role or group-contract paths change.
- `scripts/test-ansible-syntax-validator` fixture setup copies the production
  group contract into disposable fixture repositories, preserving discovery
  mode, real-fleet mode, malformed repo-mode handling, invalid expected host
  count handling, and syntax-check failure propagation coverage.
- `scripts/test-inventory-contract-maps` is local-only under
  `make validate-local-contracts`; runner-backed semantic coverage is available
  separately through `make test-inventory-contract-maps-runner`.
- `group_contract.yml` now has a single authoritative host variable naming
  surface: each `placement_rules.*.host_var` value. The duplicate top-level
  `host_var_fields` summary map was removed from production and fixture
  contracts.
- `scripts/validate-inventory` now enforces strict schema keys for the shared
  group contract, and `scripts/test-inventory-validator` covers an unknown
  placement-rule key.
- `scripts/test-real-fleet-promotion-rehearsal` is part of
  `make validate-local-contracts`, covering the currently implemented fake
  discovery-to-real-fleet promotion checks.
- `.github/workflows/validate.yml` includes a focused promotion-rehearsal job
  when promotion, inventory, public exposure, SOPS workflow proof, or related
  documentation paths change.
- `make test-real-fleet-promotion-rehearsal-runner` exercises the promotion
  rehearsal inside the pinned validation runner with Ansible syntax validation,
  syntax failure propagation, semantic assertion fixture execution, and direct
  `inventory_assertions` execution against the complete fake real-fleet
  inventory.
- `scripts/test-inventory-assertions` derives expected fixture host identity
  from fixture data instead of assuming `fixture-host`, and its non-default
  hostname regression coverage keeps contract-map generated manifests on the
  semantic Ansible execution path.
- `make test-inventory-contract-maps-runner` passed on 2026-06-22 after the
  host-identity fix, proving generated contract-map variants still execute the
  real `inventory_assertions` role in the pinned runner.
- `VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner` passed on
  2026-06-22 using the cached pinned validation image.
- `.github/workflows/validate.yml` promotion-rehearsal filters now watch
  `secrets/README.md`, `scripts/test-inventory-assertions`, and
  `tests/fixtures/inventory-assertions/**`.

Next tasks:

1. Keep the ansible-lint warning filter narrow; if future ansible-lint or
   `pathspec` output changes, prefer upgrading or repinning over broad stderr
   suppression.
2. Factor the repeated disposable-fixture harness setup only if it starts to
   obscure new validator coverage.
3. Add a small repeatability check for newly added validation harnesses when
   they depend on unordered tool output.
4. Consider extracting common disposable-repository fixture setup if another
   validator harness repeats the same copy logic.
5. Keep strict shared-contract key allowlists synchronized with any deliberate
   contract API expansion; add the fixture first when adding a new rule or
   optional field.
6. Add a focused check for `.github/workflows/validate.yml` path filters so
   watched paths exist when they are intended to be concrete files, and so
   documentation moves such as secrets docs cannot leave focused jobs stale.

Acceptance criteria:

- A maintainer can run one documented command to validate the repository in the
  supported workstation environment.
- Broken YAML, broken inventory, invalid playbook syntax, invalid Compose files,
  invalid Swarm examples, stale public exposure docs, and obvious plaintext
  secrets are caught before changes are applied.
- Validation output distinguishes missing prerequisites from repository defects.

## Phase 4: Baseline Host Configuration

Status: assertion scaffold exists; mutating baseline automation is still
skeleton-only. The shared group contract is now consumed by the role for group
mappings, host variable names, and the public exposure exposed-field name.

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
- `make test-inventory-assertions-runner` is the supported focused command for
  proving semantic assertion-role fixtures execute under Ansible instead of
  being skipped locally.
- `scripts/test-inventory-contract-maps` checks that the local inventory
  validator and Ansible assertion role still agree on the current group mapping
  contract.
- `inventory_assertions` loads
  `ansible/inventories/homelab/group_contract.yml` for runtime, architecture,
  storage, Raspberry Pi Zero, and public-exposure group placement rules.
- `inventory_assertions` reads `host_var` and `exposed_field` names from the
  shared contract instead of hardcoding them; variant fixture coverage proves
  the role and `scripts/validate-inventory` honor the same renamed contract
  fields.
- `inventory_assertions` rejects obvious placeholder host facts and RFC 5737
  documentation management addresses, matching the repository-local production
  inventory validator for the current placeholder word list and IPv4 address
  policy.
- `inventory_assertions` rejects intake placeholders such as `unknown`, `tbd`,
  `pending`, and `unset`, matching `scripts/validate-inventory` before real
  fleet facts are promoted.
- `scripts/test-inventory-assertions` validates the inventory hostname declared
  by each fixture instead of hardcoding `fixture-host`; runner-backed
  contract-map variants now prove non-default generated hostnames still execute
  the role assertions.

Next tasks:

1. Add focused assertion-role fixture coverage for renamed contract fields
   against production-style group vars, or document that contract-map generated
   manifests are the supported variant proof.
2. Decide whether `scripts/test-inventory-assertions` should preflight rendered
   host var mapping shape before invoking the role, or continue relying on the
   runner-backed semantic role cases for malformed host var fixtures.
3. Decide whether the management address contract should remain IPv4-only or
   allow IPv6/hostnames, then align docs, inventory validator, and role
   assertions.
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
- fixture harnesses for SOPS policy and secret scanning validators
- fixtures for allowlisted fake secrets, ignored example paths, binary files,
  lowercase and mixed-case secret keys, `.sops.yaml` files, and JSON encrypted
  files
- `secrets/README.md` documents operator age identity setup, recipient export,
  dummy-recipient replacement, local encrypt/edit/decrypt/updatekeys/recovery
  commands, and the fact that lost private identities make encrypted content
  unrecoverable.
- `scripts/prove-sops-workflow` provides a temporary non-production
  encrypt/decrypt/updatekeys proof that refuses the dummy recipient, verifies
  the configured public recipient is present in an applicable `.sops.yaml`
  creation rule, and treats every proof substep failure as a hard readiness
  failure.
- `scripts/test-sops-workflow-proof` covers the prior weak contract where
  `sops updatekeys` failure could still report SOPS readiness.
- `scripts/test-sops-workflow-proof` also covers the fake-tool success path,
  dummy-recipient rejection, missing private identity failure, policy-recipient
  mismatch, comment-only recipient rejection, and comma/whitespace recipient
  parsing.

Next tasks:

1. Install and verify `sops` and `age`.
2. Generate or choose real age recipients.
3. Replace every dummy recipient in `.sops.yaml`.
4. Run the SOPS proof after real recipients are configured and record the
   observed command/result in the review log.
5. Add an encrypted non-production example secret after real recipients exist,
   or document why encrypted examples remain local-only.
6. Review `.sops.yaml` path and encrypted key regexes against actual Ansible
   vars, Kubernetes Secret manifests, Compose env files, and Swarm secret
   inputs.
7. Test and document key recovery and recipient rotation with exact commands.
8. Add higher-fidelity SOPS workflow validation after real recipients exist:
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
17. Require inactive planned and non-production draft records to use a stable
    non-placeholder route identifier and meaningful target host or cluster,
    even when the public endpoint is undecided.

Next tasks:

1. Decide whether inactive draft route identifiers should be globally unique
   across source-local drafts, or whether uniqueness only matters when drafts
   are promoted to active production records.
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
