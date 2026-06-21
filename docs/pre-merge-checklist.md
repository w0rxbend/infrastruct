# Local Pre-Merge Checklist

Run this checklist from the repository root before merging infrastructure
changes.

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
`ansible-playbook`, public exposure validation and fixtures, SOPS policy
validation and fixtures, and obvious secret scans with fixture coverage.
Passing it does not replace the complete pre-merge gate.

The inventory contract map harness never starts the validation runner from this
local path. If `ansible-playbook` is unavailable, it still checks the
repository-local inventory validator behavior and reports the
`inventory_assertions` semantic Ansible probes as skipped.

The repository is still in discovery mode, so local contract checks are
trust-boundary hardening for the scaffold and not real fleet validation.
`scripts/test-inventory-assertions` always checks the local static
`inventory_assertions` privilege boundary and fixture manifest renderability.
When `ansible-playbook` is not installed, it reports the semantic Ansible role
fixture cases as skipped and still exits successfully for this local contract
path. Do not treat that skip-capable result as proof that assertion-role
behavior is correct.

Public exposure changes must keep inventory, `docs/services.md`, and
`docs/public-exposure.md` in agreement. The local contract validation compares
canonical route fields across those sources: route identifier, runtime, proxy
owner, public host or port, protocol, target host or cluster, target, firewall
intent, secret dependency, and review notes. In `docs/services.md`, use
`Public host or port` as the supported service-record field name for public
exposure data.

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

Before trusting changes to `ansible/roles/inventory_assertions/`, require real
Ansible-backed semantic fixture execution through the supported runner:

```sh
make test-inventory-assertions-runner
```

That target calls the committed validation runner and fails if the semantic
fixture cases are skipped instead of executed. The full runner gate also runs
the assertion harness in the pinned Ansible environment.

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
map convergence checks, ansible-lint, Ansible syntax validation, YAML
validation, inventory validation, public exposure validation, SOPS policy
validation, secret scanning, Compose validation, and Swarm validation. These
checks harden repository trust boundaries while discovery continues; they do
not prove live host reachability, final host membership, or real public-route
state.

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

While `repo-mode.yml` declares `mode: discovery` with
`expected_host_count: 0`, `scripts/validate-ansible-syntax` uses a temporary
local-only synthetic inventory for `ansible-playbook --syntax-check`. This keeps
the committed playbooks syntax-checked as far as practical without printing
Ansible's empty-inventory warning for the intentionally empty production
inventory. When the repository moves to real-fleet mode, the syntax check uses
`ansible/inventories/homelab/hosts.yml` directly, so inventory warnings and
syntax failures from the real fleet remain visible.

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
