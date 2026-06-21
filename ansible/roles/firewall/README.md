# firewall Role

## Responsibility

Own host firewall defaults, allowed management access, runtime-specific ports, and public exposure rules that map back to inventory and `docs/public-exposure.md`.

## Current State

This role is intentionally non-mutating. It does not install firewall packages, change default policies, open ports, close ports, or reload firewall services.

## Exceptions

Declare host-specific firewall exceptions in inventory host vars or future `host_vars/`. Public routes must remain reviewable as Git diffs in inventory and `docs/public-exposure.md`. Secrets used by proxies or route owners must be SOPS-encrypted.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags firewall --check
```

## Rollback

Future firewall changes must include a recovery path that avoids locking out management access. Roll back through Git plus targeted Ansible runs, or document any emergency console repair.

