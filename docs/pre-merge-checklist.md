# Local Pre-Merge Checklist

Run this checklist from the repository root before merging infrastructure
changes.

The repository is currently in `real-fleet` mode for the promoted 20-host
inventory. Treat that as source-of-truth inventory, not as permission to run
mutating automation. Mutating baseline roles, runtime deployments, public
exposure changes, and real encrypted non-example secrets remain blocked until
live inventory reachability is recorded in `docs/live-inventory-evidence.md`,
SOPS workflow proof status, promotion evidence integrity, and the full
validation runner are all verified.

## Supported Workstation

The complete local gate assumes the supported admin workstation described in
`docs/toolchain.md`:

- Debian, Ubuntu, or a close derivative with `apt`, `systemd`, Python 3, and a
  POSIX shell.
- `ansible-core`, `ansible-lint`, `sops`, `age`, `yamllint`, Docker with
  Compose v2, `kubectl`, and the Flux CLI installed.
- Docker is reachable by the current user when Compose or Swarm validation is
  part of the run.
- Docker or Podman is available if using the committed validation runner instead
  of installing the full toolchain directly on the workstation.

## Fast Repository Contract Check

Use the fast contract check while iterating on documentation, inventory
contracts, syntax mode-transition behavior, public exposure records, SOPS
policy, and secret scanning:

```sh
make validate-local-contracts
```

This command is for checks that do not require Ansible, ansible-lint, Flux,
Docker Compose, or live host access. It runs YAML linting, inventory validation,
inventory validator fixtures, the inventory contract map convergence harness,
Ansible syntax validator mode-transition fixtures with a fake
`ansible-playbook`, public exposure validation and fixtures, promotion evidence
consistency validation and fixtures, SOPS policy validation and fixtures,
focused CI path filter validation and fixtures, and obvious secret scans with
fixture coverage. Passing it does not replace the complete pre-merge gate.

The inventory contract map harness never starts the validation runner from this
local path. If `ansible-playbook` is unavailable, it still checks the
repository-local inventory validator behavior and reports the
`inventory_assertions` semantic Ansible probes as skipped.

The repository is in `real-fleet` mode, but local contract checks are still
repository evidence checks, not live fleet validation.
`scripts/test-inventory-assertions` always checks the local static
`inventory_assertions` privilege boundary and fixture manifest renderability.
When `ansible-playbook` is not installed, it reports the semantic Ansible role
fixture cases as skipped and still exits successfully for this local contract
path. Do not treat that skip-capable result as proof that assertion-role
behavior is correct. The harness still preflights fixture renderability,
including that the rendered target host has a host-variable mapping before role
execution, so malformed fixture inventories fail as repository fixture defects.

Public exposure changes must keep inventory, `docs/services.md`, and
`docs/public-exposure.md` in agreement. The local contract validation compares
canonical route fields across those sources: route identifier, runtime, proxy
owner, public host or port, protocol, target host or cluster, target, firewall
intent, secret dependency, and review notes. In `docs/services.md`, use
`Public host or port` as the supported service-record field name for public
exposure data. Route identifiers are stable promotion handles and must be
globally unique across active, planned, and non-production public exposure
records, including inactive source-local drafts.

Focused CI path filters in `.github/workflows/validate.yml` are checked by the
local gate. Concrete watched files such as `docs/foo.md`, `scripts/bar`, or
`secrets/README.md` must exist; globbed path patterns remain allowed for
directories and file sets. For focused review of workflow path-filter changes,
run:

```sh
scripts/validate-ci-path-filters
scripts/test-ci-path-filter-validator
```

Before staging any real encrypted non-example secret, the SOPS proof record in
`docs/sops-workflow-proof.md` must have `Status: reproduced`. The current
validator allows explicit `operator-provided` or `not-yet-reproduced` status
only while no real encrypted non-example secret files are present; in those
states it reports that the repository is not ready for real secret material.
Use the documented proof command shape with the private identity mounted
read-only from outside the repository:

```sh
docker run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -e SOPS_AGE_RECIPIENTS="$(awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/keys.txt")" \
  -v "$PWD:/workspace:ro" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  scripts/prove-sops-workflow
```

That proof is required to pass encrypt, decrypt, and `updatekeys`; any failure
blocks committing real encrypted non-example secret material. Do not record
private identity contents or decrypted values.

## Complete Pre-Merge Gate

Before merge, run one of the complete validation commands on a supported
workstation:

```sh
make validate
```

or, when the full gate is being called explicitly:

```sh
make validate-full
```

When the full workstation toolchain is not installed locally, use the committed
validation runner instead:

```sh
make validate-runner
```

`make validate-container` is an alias for the same command. The runner builds
the pinned toolchain image from `Containerfile`, mounts the repository read-only,
and runs `make validate` inside the container. It requires Docker or Podman on
the host, but the validation container itself does not require network access.

Promotion-boundary changes must run the relevant focused fixture harnesses
before merge, then the pinned validation runner. Use the focused harnesses that
match the edited boundary, such as `scripts/test-inventory-validator`,
`make test-inventory-assertions-runner`, `scripts/test-sops-workflow-proof`, or
`scripts/test-public-exposure-validator`. If the change touches focused CI
workflow filters, include `scripts/validate-ci-path-filters` and
`scripts/test-ci-path-filter-validator`. Finish with the pinned runner path:
`make validate-runner`.

For changes that affect the discovery-to-real-fleet transition, run the
promotion rehearsal before any real host facts, active public routes, or
encrypted non-example secrets are promoted:

```sh
scripts/test-real-fleet-promotion-rehearsal
```

The rehearsal uses fake production-shaped data to prove the promotion boundary:
empty discovery inventory passes, incomplete real-fleet inventory fails,
complete fake real-fleet inventory passes, active public exposure fails until
inventory, `docs/services.md`, and `docs/public-exposure.md` agree, and a SOPS
recipient mentioned only in comments cannot satisfy the workflow proof. Run it
when changing promotion docs, inventory validators, public exposure validators,
SOPS workflow proof behavior, or the rehearsal fixtures.

Real-fleet mode also runs a promotion evidence consistency check:

```sh
scripts/validate-promotion-evidence
scripts/test-promotion-evidence-validator
```

This check fails when `repo-mode.yml` declares `mode: real-fleet` and the
promoted inventory snapshot in `docs/fleet-discovery-intake.md` drifts from
`ansible/inventories/homelab/hosts.yml`. It compares documented hosts by
hostname, management IP, architecture, hardware model, storage type, runtime
roles, public exposure flag, and public exposure state, with `hosts.yml`
treated as authoritative. It also requires `docs/sops-workflow-proof.md` to
use one of the explicit statuses, show the command shape used for
`scripts/prove-sops-workflow`, and document that private age identity material
is mounted read-only from outside the repository.

After changing promotion-evidence SOPS encrypted-file detection, run the
focused repository checks and the full runner gate:

```sh
scripts/validate-promotion-evidence
scripts/test-promotion-evidence-validator
make validate-local-contracts
VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner
```

Use the cached runner command only when the pinned validation image already
exists and the change did not edit `Containerfile` or validation tool pins. For
runner pin or `Containerfile` changes, use the no-cache proof command instead:
`make validate-runner-proof`. These commands validate repository evidence,
fixture coverage, and the complete local gate; they do not rerun the live SOPS
proof command or contact real inventory hosts.

The focused fixture harnesses cover stale intake snapshots, SOPS proof status
semantics, blocked real encrypted non-example secrets when proof status is not
`reproduced`, and the live healthcheck wrapper behavior with fake Ansible
commands:

```sh
scripts/test-promotion-evidence-validator
scripts/test-live-inventory-healthcheck
```

Before trusting changes to `ansible/roles/inventory_assertions/`, require real
Ansible-backed semantic fixture execution through the supported runner:

```sh
scripts/test-inventory-assertions
make test-inventory-assertions-runner
```

The local script catches static boundary problems and malformed rendered
fixture inventories before role execution. The runner target calls the
committed validation runner and fails if the semantic fixture cases are skipped
instead of executed. The full runner gate also runs the assertion harness in
the pinned Ansible environment.

For focused changes to the shared group contract map behavior, the explicit
runner-backed convergence target is:

```sh
make test-inventory-contract-maps-runner
```

That target runs `scripts/test-inventory-contract-maps` inside the committed
validation runner with semantic Ansible fixture execution required. It is not
part of `make validate-local-contracts`.

The same requirement applies when reviewing changes to
`ansible/inventories/homelab/group_contract.yml`. That file is the shared
source of truth for inventory group placement semantics used by both
`scripts/validate-inventory` and the `inventory_assertions` role, including
runtime role groups, architecture groups, storage groups, Raspberry Pi Zero
hardware placement, and public exposure group membership. Local contract checks
may skip semantic Ansible execution when `ansible-playbook` is unavailable, so
contract or assertion-role changes require either
`make test-inventory-assertions-runner`,
`make test-inventory-contract-maps-runner`, or the full validation runner before
review can trust the behavior.

CI runs the same committed runner path on GitHub-hosted Linux runners. The
workflow executes `scripts/validate-runner --versions` first so successful logs
capture the pinned tool versions, then executes `scripts/validate-runner` for
the complete validation gate.

The complete gate keeps the full repository validation path together: syntax
validator mode-transition fixtures from the local contracts, inventory contract
map convergence checks, live healthcheck fixture coverage with fake Ansible
commands, focused CI path filter validation, ansible-lint, Ansible syntax
validation, YAML validation, inventory validation, promotion evidence
validation, public exposure validation, SOPS policy validation, secret
scanning, Compose validation, and Swarm validation. These checks harden
repository trust boundaries for the promoted real-fleet scaffold; they do not
prove live host reachability, collected host facts, cryptographic SOPS
execution, or real public-route state.

## Live Inventory Healthcheck

After repository validation passes and before any mutating baseline role is
enabled against the promoted real-fleet inventory, run the non-mutating live
inventory check from a workstation with management-network access:

```sh
make live-inventory-healthcheck
```

This command first runs `ansible-inventory --list` against
`ansible/inventories/homelab/hosts.yml`, then runs
`ansible all -m ansible.builtin.ping` against the same inventory with
`ANSIBLE_BECOME=false` and `-e ansible_become=false`. It does not run playbooks,
roles, package changes, service changes, firewall changes, Docker, Swarm, K3s,
Flux, or privilege escalation. Use
`ANSIBLE_LIMIT=<host-or-group> make live-inventory-healthcheck` for focused
access investigation without changing the command path.

Treat `MISSING TOOL` and `PREREQUISITE FAILURE` output as workstation or
inventory-rendering setup defects. Treat `LIVE REACHABILITY FAILURE` output as
host access evidence: record the unreachable host, `ansible_host`, error text,
date, and next owner action in `docs/live-inventory-evidence.md` before
enabling baseline automation. If hosts are reachable but observed non-secret
facts disagree with `docs/hosts.md` or
`ansible/inventories/homelab/hosts.yml`, record and correct the fact mismatch
in the evidence note before running any mutating role.

`docs/live-inventory-evidence.md` must state the command date, runner or
workstation identity, ansible-core version, inventory render result, ping
result, unreachable hosts, and observed fact mismatches. Do not treat
`Status: not-yet-run` or unreviewed partial evidence as permission to enable a
mutating baseline role.

Keep the operational freeze intact. Do not start mutating baseline, Docker,
Swarm, K3s, or Flux automation, do not commit real encrypted non-example
secrets, and do not apply public exposure changes until the 20-host production
inventory, live reachability evidence, reproduced SOPS workflow proof,
promotion evidence integrity, public exposure truth, and full validation runner
have all passed.

`scripts/validate-ansible-syntax` is safe to run as a standalone check after
the supported Ansible toolchain is installed. It first runs
`scripts/validate-inventory`, so repository mode, expected host count,
production inventory shape, and group placement contracts are enforced before
the script chooses either the discovery synthetic inventory or the real-fleet
production inventory for `ansible-playbook --syntax-check`. Any nonzero
`ansible-playbook` syntax-check exit and diagnostic output are preserved.

When a change edits `Containerfile` or validation tool pins, also run the
validation runner proof command:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-$(date +%Y%m%d) \
  make validate-runner-proof
```

The proof command rebuilds the image with `--no-cache --pull`, prints pinned
tool versions from the rebuilt image, and runs the complete gate from that same
image. It fails on any build, version-report, or validation failure. Record the
observed versions in review notes.

Treat missing workstation tools as workstation setup defects. Treat validation
failures after the supported toolchain is installed as repository defects unless
the output clearly identifies an external dependency such as an unreachable
Docker daemon.

The full gate should be warning-clean. In particular, ansible-lint should not
emit `.yamllint` compatibility warnings; the repository `.yamllint` keeps the
YAML rule settings required by ansible-lint so real YAML findings remain visible
in the normal validation output.

Because `repo-mode.yml` now declares `mode: real-fleet`,
`scripts/validate-ansible-syntax` uses
`ansible/inventories/homelab/hosts.yml` directly, so inventory warnings and
syntax failures from the promoted inventory remain visible. The script still
has discovery-mode support for future pre-operational rollback branches: when
`repo-mode.yml` declares `mode: discovery` with `expected_host_count: 0`, it
uses a temporary local-only synthetic inventory to avoid Ansible's
empty-inventory warning.

## Review Notes

Only capture tool versions in review notes after the complete gate succeeds.
Record the command that passed and the relevant versions.

For a local workstation run:

```sh
make validate
ansible-playbook --version
ansible-lint --version
sops --version
age-keygen --version
yamllint --version
docker version
docker compose version
kubectl version --client
flux --version
```

For a containerized run, capture versions from the same image:

```sh
make validate-runner
VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner --versions
```

For `Containerfile` or validation pin changes, record the proof command and
observed versions instead of relying on a previously cached local runner image:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-YYYYMMDD make validate-runner-proof
```
