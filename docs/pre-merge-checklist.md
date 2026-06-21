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

## Fast Repository Contract Check

Use the fast contract check while iterating on documentation, inventory
contracts, public exposure records, SOPS policy, and secret scanning:

```sh
make validate-local-contracts
```

This command is for checks that do not require Ansible, ansible-lint, SOPS,
age, Flux, Docker, or live host access. Passing it does not replace the complete
pre-merge gate.

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

Treat missing workstation tools as workstation setup defects. Treat validation
failures after the supported toolchain is installed as repository defects unless
the output clearly identifies an external dependency such as an unreachable
Docker daemon.

## Review Notes

Only capture tool versions in review notes after the complete gate succeeds.
Record the command that passed and the relevant versions, for example:

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
