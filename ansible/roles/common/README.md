# common Role

## Responsibility

Own shared host baseline policy that should apply before runtime-specific setup, including hostname expectations, time sync, base OS settings, kernel or boot prerequisites, and ARM-specific compatibility settings.

## Current State

This role is intentionally non-mutating. Its task file reports the intended policy area until real host baseline requirements are known.

## Exceptions

Declare host-specific exceptions in `ansible/inventories/homelab/hosts.yml` or future `host_vars/` files. Shared defaults belong in group vars. Sensitive exceptions must be stored in SOPS-encrypted vars, not in this role.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags common --check
```

## Rollback

Once this role becomes mutating, rollback should be a Git revert plus a targeted baseline run. Manual emergency fixes must be captured back into inventory or role policy.

