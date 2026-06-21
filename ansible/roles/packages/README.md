# packages Role

## Responsibility

Own package cache behavior and required base packages that every managed host needs before Docker, Swarm, K3s, or monitoring automation runs.

## Current State

This role is intentionally non-mutating. It does not update package caches, install packages, remove packages, or enable repositories.

## Exceptions

Declare host-specific package exclusions or additions in inventory host vars or future `host_vars/`. Group-wide package policy belongs in group vars for the relevant runtime or hardware class.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags packages --check
```

## Rollback

Future package changes should include a documented downgrade or removal path when the package affects SSH, networking, container runtimes, or cluster membership.

