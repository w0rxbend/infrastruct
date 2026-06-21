# ssh Role

## Responsibility

Own SSH daemon configuration, access hardening, and any service restart or reload needed after SSH policy changes.

## Current State

This role is intentionally non-mutating. It does not edit `sshd_config`, alter ports, disable password login, or restart SSH.

## Exceptions

Declare host-specific SSH exceptions in inventory host vars or future `host_vars/`. Public exposure or nonstandard access paths must also be reflected in `docs/public-exposure.md` when internet-facing.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags ssh --check
```

## Rollback

Future SSH policy changes must preserve an active recovery path. Rollback should use Git history and a targeted run, with manual console recovery documented after any emergency fix.

