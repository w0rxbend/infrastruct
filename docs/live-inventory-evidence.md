# Live Inventory Evidence

Status: not-yet-run

This note is the non-secret evidence record for the promoted 20-host
production inventory. It must be updated from reviewed command output before
any mutating baseline role is enabled against the real fleet.

Do not change `Status` to `reproduced` unless a reviewer has inspected the
actual `ansible-inventory` render result and Ansible ping output from a
supported workstation or pinned runner with management-network access. Use
`Status: partial` only when one part of the command path ran but another part
failed or was intentionally limited.

Allowed statuses:

- `not-yet-run`: no reviewed live command output has been recorded.
- `partial`: inventory render, ping, host limit, or fact comparison evidence is
  incomplete.
- `reproduced`: the promoted inventory rendered successfully, the intended host
  set was pinged, unreachable hosts and fact mismatches were reviewed, and the
  evidence below is filled in from command output.

## Command Shape

Run from a supported admin workstation with `ansible-core` installed and
management-network access to the promoted hosts:

```sh
make live-inventory-healthcheck
```

For a focused rerun while preserving the same wrapper path:

```sh
ANSIBLE_LIMIT=<host-or-group> make live-inventory-healthcheck
```

Equivalent direct wrapper form:

```sh
scripts/live-inventory-healthcheck
scripts/live-inventory-healthcheck <host-or-group-limit>
```

If using the pinned validation runner as the Ansible toolchain, run it from a
host with management-network access and mount only the non-secret repository
plus whatever external SSH or Ansible authentication material the operator
requires. Keep private key paths redacted in this note:

```sh
docker run --rm --network host \
  -e HOME=/tmp \
  -v "$PWD:/workspace:ro" \
  -v "<redacted-external-ssh-or-ansible-auth-dir>:/operator-auth:ro" \
  -w /workspace \
  infrastruct-validate:local \
  scripts/live-inventory-healthcheck
```

The wrapper renders `ansible/inventories/homelab/hosts.yml` with
`ansible-inventory --list`, then runs:

```sh
ANSIBLE_BECOME=false ANSIBLE_TIMEOUT="${ANSIBLE_TIMEOUT:-10}" \
  ansible "${ANSIBLE_LIMIT:-all}" \
  -i ansible/inventories/homelab/hosts.yml \
  -m ansible.builtin.ping \
  -e ansible_become=false
```

It must not run playbooks, roles, package changes, service changes, firewall
changes, Docker, Swarm, K3s, Flux, or privilege escalation.

## Current Evidence Record

- Command date: not recorded
- Runner or workstation identity: not recorded
- Runner image or workstation OS: not recorded
- ansible-core version: not recorded
- Command: not run
- Inventory file: `ansible/inventories/homelab/hosts.yml`
- Inventory render result: not reviewed
- Ping target or limit: not recorded
- Ping result: not reviewed
- Unreachable hosts: not reviewed
- Observed fact mismatches: not reviewed
- Reviewer: not recorded
- Follow-up owner: not recorded
- Follow-up action: run the live inventory healthcheck from a supported
  workstation or pinned runner with management-network access before enabling
  any mutating baseline role.

## Recording Rules

Record only non-secret evidence:

- command date and reviewer
- runner image tag or workstation identity
- `ansible-core` version
- exact command and host limit
- inventory render success or failure
- ping success, unreachable hosts, or execution failure classification
- affected hostnames and non-secret `ansible_host` values
- observed non-secret fact mismatches against
  `ansible/inventories/homelab/hosts.yml` or `docs/hosts.md`
- next owner action

Never record private SSH keys, passwords, API tokens, decrypted secret values,
or private age identities.
