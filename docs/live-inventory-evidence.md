# Live Inventory Evidence

Status: partial

This note is the non-secret evidence record for the promoted 20-host
production inventory. It must be updated from reviewed command output before
any mutating baseline role is enabled against the real fleet.

Do not change `Status` to `reproduced` unless a reviewer has inspected the
actual `ansible-inventory` render result and Ansible ping output from a
supported workstation or pinned runner with management-network access. Use
`Status: partial` only when one part of the command path ran but another part
failed or was intentionally limited.

When `Status: reproduced` is used, the evidence record must contain concrete
reviewed field values. Required evidence fields cannot use generic or
repository-native placeholders such as `unknown`, `tbd`, `pending`,
`not recorded`, `not-yet-run`, `not-yet-reproduced`, or
`not-yet-assigned`. Keep placeholder values only while the record is
`not-yet-run` or `partial`.

Allowed statuses:

- `not-yet-run`: no reviewed live command output has been recorded.
- `partial`: inventory render, ping, host limit, or fact comparison evidence is
  incomplete.
- `reproduced`: the promoted inventory rendered successfully, the intended host
  set was pinged, unreachable hosts and fact mismatches were reviewed, and the
  evidence below is filled in from command output.

## Command Shape

Supported execution paths:

1. Local `ansible-core` from a supported admin workstation with
   management-network access to the promoted hosts.
2. The pinned validation runner image from a host with management-network
   access to the promoted hosts.

Local workstation path:

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

Pinned validation runner path:

```sh
make live-inventory-healthcheck-runner
```

For a focused runner-backed rerun:

```sh
ANSIBLE_LIMIT=<host-or-group> make live-inventory-healthcheck-runner
```

The runner target builds or reuses the same pinned validation image used by
`scripts/validate-runner`, mounts this repository read-only, enables host
networking on Linux, and runs the same non-mutating wrapper inside the image.
Run it only from a host with management-network access and with whatever
external SSH or Ansible authentication material the operator requires available
outside the repository. Keep private key paths redacted in this note.

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

- Command date: 2026-06-22T02:36:37+03:00
- Runner or workstation identity: `worxbend@ubuntu`
- Runner image or workstation OS: Ubuntu workstation,
  `Linux ubuntu 7.0.0-22-generic #22-Ubuntu SMP PREEMPT_DYNAMIC Mon May 25 15:54:34 UTC 2026 x86_64 GNU/Linux`; runner image
  `infrastruct-validate:local`
  (`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`).
- ansible-core version: `ansible [core 2.18.6]` from the pinned validation
  runner image.
- Command: `make live-inventory-healthcheck-runner`
- Inventory file: `ansible/inventories/homelab/hosts.yml`
- Inventory render result: passed; the runner printed
  `OK: ansible-inventory rendered successfully.`
- Ping target or limit: `all`
- Ping result: failed before live network reachability could be assessed. Every
  targeted host returned the controller-side Ansible error
  `Unable to execute ssh command line on a controller due to: [Errno 2] No such
  file or directory: b'ssh'`, after which the wrapper reported
  `ANSIBLE EXECUTION FAILURE: ansible ping failed, but no unreachable-host
  marker was detected.`
- Unreachable hosts: not assessed as network-unreachable because the runner
  image lacked the `ssh` executable needed by Ansible before any SSH connection
  could be attempted. The affected target set was `lab-cp-01`, `lab-cp-02`,
  `lab-cp-03`, `lab-app-01`, `lab-app-02`, `lab-app-03`, `lab-app-04`,
  `lab-app-05`, `lab-app-06`, `lab-swarm-01`, `lab-swarm-02`,
  `lab-swarm-03`, `lab-swarm-04`, `lab-swarm-05`, `lab-edge-01`,
  `lab-edge-02`, `lab-pi-01`, `lab-pi-02`, `lab-zero-01`, and
  `lab-zero-02`.
- Observed fact mismatches: not assessed; the healthcheck runs Ansible ping
  only and the ping step failed before collecting any live facts.
- Reviewer: Codex autonomous implementation agent
- Follow-up owner: homelab operator with management-network access
- Follow-up action: add an SSH client to the supported runner image or run
  `make live-inventory-healthcheck` from a supported workstation with local
  `ansible-core`, SSH client support, authentication material outside the
  repository, and management-network access. Rerun without privilege escalation
  and record the ping result, every unreachable host, and any non-secret fact
  mismatch before enabling any mutating baseline role.

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
