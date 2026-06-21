# Ansible

## Ownership

This area owns physical host inventory, host baseline automation, runtime installation, health checks, maintenance playbooks, and host-level exceptions.

Owner tool: Ansible.

Primary locations:

- `inventories/homelab/` for host and group metadata
- future `playbooks/` for runnable operations
- future `roles/` for reusable host policy

## Applying Changes

Ansible changes are applied from an admin workstation or automation runner with an explicit inventory path. Planned examples:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --graph
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/healthcheck.yml
```

Playbooks do not exist yet. Until they do, this directory defines ownership and metadata expectations only.

## Verification

Verify inventory changes with `ansible-inventory` once `hosts.yml` exists. Verify automation changes with dry runs or non-mutating health checks before running baseline or maintenance playbooks against all hosts.

## Manual Edit Boundary

Do not make lasting user, SSH, package, firewall, Docker, Swarm, or K3s host changes manually without recording the desired state here. Emergency manual fixes must be followed by a Git change that documents or automates the fix.

## Secrets

Host secrets belong in encrypted inventory vars or encrypted files referenced from `secrets/`. Plaintext credentials, tokens, private keys, and password hashes must not be committed.

## Rollback And Recovery

Rollback should use Git history plus a targeted Ansible run. If a host is unrecoverable, rebuild or reimage it, restore SSH access, and reapply the relevant inventory and playbooks.
