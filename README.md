<div align="center">

```text
┌──────────────────────────────────────────────┐
│                  INFRASTRUCT                 │
│        Homelab Bare-Metal IaC Repository      │
└──────────────────────────────────────────────┘
```

# Infrastruct

Infrastructure-as-code for a mixed ARM homelab running K3s, Docker Compose, and Docker Swarm.

</div>

## Purpose

This repository is the source of truth for managing a self-hosted bare-metal homelab of Raspberry Pi, Rock64, and related ARM machines.

It is intended to manage:

- physical host inventory and required host metadata
- Ansible baseline automation for users, SSH, packages, firewall, runtime setup, health checks, and maintenance
- K3s node lifecycle and GitOps-managed Kubernetes applications
- Docker Compose services on standalone Docker hosts
- Docker Swarm stacks on Swarm managers and workers
- encrypted secrets policy and placement for Ansible, K3s, Compose, and Swarm
- public service exposure through a static ISP IP
- maintenance workflows, monitoring expectations, and operational documentation

The project is designed for long-term human maintenance. Configuration should be readable, documented, repeatable, and safe to change through Git.

## Planned Stack

| Area | Tooling |
| --- | --- |
| Host management | Ansible |
| Kubernetes runtime | K3s |
| Kubernetes GitOps | Flux CD |
| Kubernetes packaging | Helm, Kustomize |
| Single-host containers | Docker Compose |
| Multi-host Docker | Docker Swarm |
| Secrets | SOPS + age |
| Monitoring | Prometheus, Grafana, Uptime Kuma |
| Updates | Renovate, Ansible maintenance playbooks |

## Operator Prerequisites

Install the workstation tools needed to validate and operate this repository before applying infrastructure changes:

- Follow the [admin workstation toolchain guide](docs/toolchain.md) to install and verify the supported local toolchain.
- `ansible-core`
- `ansible-lint`
- `sops`
- `age`
- `yamllint`
- Docker with Compose v2
- `kubectl`
- Flux CLI

Run the repository validation commands before applying changes to hosts, clusters, Compose services, Swarm stacks, or secrets. Real secrets must not be added while `.sops.yaml` still uses the dummy age recipient; replace it with a real recipient first and keep private age keys outside Git.

Primary validation command:

```sh
make validate
```

`make validate` runs the full supported workstation gate through
`make validate-full`, including repository contracts, YAML linting, Ansible
syntax and lint checks, Compose and Swarm validation, SOPS policy checks, and
secret scanning. On machines without Ansible, ansible-lint, SOPS, age, Flux,
Docker, or live host access, run the cheap repository-contract subset instead:

```sh
make validate-local-contracts
```

The local-contract target is useful for fast YAML, inventory, Ansible syntax
mode-transition fixture, public exposure documentation, SOPS policy, and
secret-scan checks, but it does not replace the full gate before infrastructure
changes are applied. Missing full-gate prerequisites are reported as missing
tools rather than repository defects.

Before merging changes, use the [local pre-merge checklist](docs/pre-merge-checklist.md). It distinguishes the fast `make validate-local-contracts` repository-contract check from the complete `make validate` or `make validate-full` supported-workstation gate, and documents the no-cache validation-runner proof command required after `Containerfile` or validation tool pin changes.

## Ownership Map

This repository follows a contract-first model. Ownership boundaries and required metadata are documented before deep automation is added.

| Area | Owner Tool | Repo Location | Source of Truth |
| --- | --- | --- | --- |
| Host inventory | Ansible | `ansible/inventories/homelab/` | Inventory files and host vars |
| Host baseline | Ansible | `ansible/playbooks/`, `ansible/roles/` | Playbooks, roles, and inventory vars |
| K3s lifecycle | Ansible | `ansible/playbooks/`, `ansible/roles/` | Playbooks and inventory groups |
| K3s applications | Flux CD | `clusters/homelab/` | GitOps manifests reconciled by Flux |
| Docker Compose services | Ansible + Docker Compose | `docker/compose/` | Compose files and service READMEs |
| Docker Swarm stacks | Ansible + Docker Swarm | `swarm/stacks/` | Stack files and Swarm inventory |
| Secrets | SOPS + age | `secrets/`, encrypted vars, encrypted manifests | Encrypted files in Git; age keys outside Git |
| Public exposure | Documentation + runtime/proxy config | `docs/public-exposure.md`, inventory, runtime files | Reviewable Git diffs |
| Maintenance | Ansible + documentation | `docs/maintenance.md`, future playbooks | Runbooks and idempotent playbooks |

## Repository Map

```text
.
├── ansible/        # host inventory, baseline config, runtime lifecycle
├── clusters/       # K3s GitOps state managed by Flux
├── docker/         # Docker Compose services
├── swarm/          # Docker Swarm stacks
├── secrets/        # SOPS/age policy and secret handling docs
├── docs/           # research, service catalog, runbooks
├── PLAN.md         # implementation plan
└── README.md
```

Every implementation area has a local README describing what it owns, how changes are applied and verified, where secrets belong, what must not be edited manually, and how rollback or recovery should work.

## Current Status

This repository is in the planning/scaffolding stage.

The committed repository mode contract is `repo-mode.yml`. It currently uses
`mode: discovery` with `expected_host_count: 0`, so the production inventory is
valid only while it declares no hosts. Before adding the real 20-machine
inventory, change `repo-mode.yml` to a non-discovery mode such as
`mode: real-fleet` and set `expected_host_count: 20`; `scripts/validate-inventory`
will then reject empty or partial production inventories.

Start here:

- [Implementation plan](PLAN.md)
- [Research and tooling proposal](docs/research-status.md)
- [Ansible inventory contract](docs/ansible.md)
- [Local pre-merge checklist](docs/pre-merge-checklist.md)

## Change Contract

All infrastructure changes should be reviewable from Git before they are applied.

Required metadata for future host and service changes:

- Hosts must declare identity, IP address, architecture, hardware model, storage type, runtime role, reliability notes, placement notes, and public exposure metadata.
- Services must declare runtime, host or cluster placement, public exposure, internal target, data path, storage type, secret source, backup policy, and maintenance notes.
- Public exposure must declare service name, protocol, public port, proxy or direct-port owner, internal target, firewall intent, secret dependency, and review notes.

Manual edits on hosts, clusters, or Docker runtimes are allowed only for investigation or emergency recovery. Any lasting change must be brought back into this repository.

## Operating Principles

- Git is the source of truth.
- Ansible owns physical host state.
- Flux owns Kubernetes application state.
- Docker Compose, Docker Swarm, and K3s are all first-class supported runtimes.
- Public exposure must be documented and reviewable.
- Secrets must not be committed in plaintext.
- Documentation and useful comments are part of the implementation.
