# users Role

## Responsibility

Own local account, group, authorized key, and sudo policy for managed hosts.

## Current State

This role is intentionally non-mutating. It does not create users, change passwords, install keys, or alter sudoers files.

## Exceptions

Declare per-host user or sudo exceptions in inventory host vars or future `host_vars/`. Put reusable account policy in group vars. Password hashes, private keys, and recovery credentials must be SOPS-encrypted.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags users --check
```

## Rollback

Future mutating changes should be reversible through Git history and targeted Ansible runs. Keep emergency account recovery notes documented and encrypted when sensitive.

