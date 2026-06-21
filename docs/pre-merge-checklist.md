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
contracts, public exposure records, SOPS policy, and secret scanning:

```sh
make validate-local-contracts
```

This command is for checks that do not require Ansible, ansible-lint, Flux,
Docker Compose, or live host access. It does run YAML linting, SOPS policy
guardrails, and obvious secret scans because those are repository-local
contracts. Passing it does not replace the complete pre-merge gate.

Public exposure changes must keep inventory, `docs/services.md`, and
`docs/public-exposure.md` in agreement. The local contract validation compares
canonical route fields across those sources: route identifier, runtime, proxy
owner, public host or port, target, firewall intent, secret dependency, and
review notes. In `docs/services.md`, use `Public host or port` as the supported
service-record field name for public exposure data.

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

CI runs the same committed runner path on GitHub-hosted Linux runners. The
workflow executes `scripts/validate-runner --versions` first so successful logs
capture the pinned tool versions, then executes `scripts/validate-runner` for
the complete validation gate.

When a change edits `Containerfile` or validation tool pins, also run the
validation runner pin-refresh procedure in `docs/toolchain.md`. That procedure
rebuilds the image with `--no-cache --pull`, prints pinned tool versions from
the rebuilt image, runs the complete gate from that same image, and records the
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

For `Containerfile` or validation pin changes, record the no-cache rebuild
command and observed versions from the pin-refresh procedure in
`docs/toolchain.md` instead of relying on a previously cached local runner
image.
