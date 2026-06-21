# Ansible

## Ownership

This area owns physical host inventory, host baseline automation, runtime installation, health checks, maintenance playbooks, and host-level exceptions.

Owner tool: Ansible.

Primary locations:

- `inventories/homelab/` for host and group metadata
- `playbooks/` for runnable operation entrypoints
- `roles/` for reusable host policy

## Current State

This directory contains placeholder playbooks and role skeletons. They define
the intended contract for inventory, health checks, and baseline host policy,
but they are not production-ready automation.

The current playbooks are:

- `playbooks/bootstrap.yml` for first-run access and bootstrap policy planning
- `playbooks/healthcheck.yml` for non-mutating host inspection
- `playbooks/baseline.yml` for the future shared host baseline

The baseline roles under `roles/` are intentionally skeletal. They must not be
expanded into mutating user, SSH, package, firewall, monitoring, Docker, Swarm,
or K3s automation until the production inventory contains real host facts and
the repository validation checks are in place.

## Local Tooling

Ansible work is expected to run from an admin workstation or automation runner
with, at minimum:

- `ansible-core` for `ansible-inventory` and `ansible-playbook`
- `ansible-lint` for playbook and role linting

Additional repository validation tooling is documented at the top level as it
is added. Commands below are the intended workflow even when the current
workstation does not have every tool installed yet.

## Applying Changes

Always use an explicit inventory path. Start with non-mutating inspection before
running baseline automation:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --graph
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/healthcheck.yml
```

Do not run mutating baseline automation against production hosts until real
inventory has replaced placeholder data and validation passes.

## Verification

Expected validation commands:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --graph
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/bootstrap.yml --syntax-check
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/healthcheck.yml --syntax-check
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --syntax-check
ansible-lint ansible/playbooks ansible/roles
make validate-ansible-syntax
make validate
```

Verify inventory changes with `ansible-inventory`. Verify automation changes
with syntax checks, `ansible-lint`, dry runs, or non-mutating health checks
before running baseline or maintenance playbooks against all hosts. Treat any
missing validation target as a tooling gap to close before mutating host state.

## Manual Edit Boundary

Do not make lasting user, SSH, package, firewall, Docker, Swarm, or K3s host changes manually without recording the desired state here. Emergency manual fixes must be followed by a Git change that documents or automates the fix.

## Secrets

Host secrets belong in encrypted inventory vars or encrypted files referenced from `secrets/`. Plaintext credentials, tokens, private keys, and password hashes must not be committed.

## Rollback And Recovery

Rollback should use Git history plus a targeted Ansible run. If a host is unrecoverable, rebuild or reimage it, restore SSH access, and reapply the relevant inventory and playbooks.
