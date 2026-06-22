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

The controller selection and scope boundary for these commands is documented in
`docs/live-ansible-controller.md`. The pinned validation runner is the
supported live Ansible controller for non-mutating reachability checks; the
local workstation path is a prerequisite-dependent fallback only.

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

- Command date: 2026-06-22T02:59:49+03:00
- Runner or workstation identity: `worxbend@ubuntu`
- Runner image or workstation OS: Ubuntu workstation,
  `Linux ubuntu 7.0.0-22-generic #22-Ubuntu SMP PREEMPT_DYNAMIC Mon May 25 15:54:34 UTC 2026 x86_64 GNU/Linux`; runner image
  `infrastruct-validate:ssh-client-20260622`
  (`bc4a8ebca17fc73e3c67f9c75845dc823149540a144fd1556ea74ffd9b0fbb8c`).
- ansible-core version: `ansible [core 2.18.6]` from the pinned validation
  runner image.
- SSH client availability: available in the rebuilt pinned validation runner;
  `ssh -V` reported
  `OpenSSH_9.2p1 Debian-2+deb12u10, OpenSSL 3.0.20 7 Apr 2026`.
- Command:
  `VALIDATION_RUNNER_IMAGE=infrastruct-validate:ssh-client-20260622 VALIDATION_RUNNER_SKIP_BUILD=1 LIVE_INVENTORY_SSH_DIR=<external-ssh-dir> make live-inventory-healthcheck-runner`
- External SSH auth directory: absolute path outside the repository, redacted
  in this record, mounted read-only at `/tmp/.ssh`.
- Inventory file: `ansible/inventories/homelab/hosts.yml`
- Inventory render result: passed; the runner printed
  `OK: ansible-inventory rendered successfully.`
- Ping target or limit: `all`
- Ping result: failed with live SSH reachability failures. The runner reached
  SSH execution, and every targeted host returned `UNREACHABLE!` with
  `ssh: connect to host <ansible_host> port 22: Connection timed out`. The
  wrapper reported `LIVE REACHABILITY FAILURE: one or more targeted hosts were
  unreachable or rejected the Ansible connection.`
- Unreachable hosts: all promoted hosts timed out on TCP port 22:
  `lab-cp-01` (`10.42.10.11`), `lab-cp-02` (`10.42.10.12`),
  `lab-cp-03` (`10.42.10.13`), `lab-app-01` (`10.42.10.14`),
  `lab-app-02` (`10.42.10.15`), `lab-app-03` (`10.42.10.16`),
  `lab-app-04` (`10.42.10.17`), `lab-app-05` (`10.42.10.18`),
  `lab-app-06` (`10.42.10.19`), `lab-swarm-01` (`10.42.10.20`),
  `lab-swarm-02` (`10.42.10.21`), `lab-swarm-03` (`10.42.10.22`),
  `lab-swarm-04` (`10.42.10.23`), `lab-swarm-05` (`10.42.10.24`),
  `lab-edge-01` (`10.42.10.25`), `lab-edge-02` (`10.42.10.26`),
  `lab-pi-01` (`10.42.10.27`), `lab-pi-02` (`10.42.10.28`),
  `lab-zero-01` (`10.42.10.29`), and `lab-zero-02` (`10.42.10.30`).
- Observed fact mismatches: not assessed; the healthcheck runs Ansible ping
  only and every promoted host was unreachable over SSH.
- Reviewer: Codex autonomous implementation agent
- Follow-up owner: homelab operator with management-network access
- Follow-up action: rerun the same runner-backed command from a workstation
  that can route to `10.42.10.11-10.42.10.30` on TCP port 22 with
  operator-managed SSH authentication mounted read-only from outside the
  repository. Keep privilege escalation disabled and record the successful ping
  result, any remaining unreachable hosts, and any non-secret fact mismatch
  before enabling any mutating baseline role.

## Next Supported-Network Evidence Record

Use this section for the next reviewed run from a workstation or runner host
with management-network access to `10.42.10.11-10.42.10.30` on TCP port 22.
Keep `Status: partial` until the command output proves that every promoted
host expected to be reachable completed a non-mutating Ansible ping, or until
this record explicitly lists and justifies host-level exceptions.

- Command date: not-yet-run
- Runner image or workstation identity: not-yet-run
- ansible-core version: not-yet-run
- SSH client availability: not-yet-run
- Command:
  `LIVE_INVENTORY_SSH_DIR=/absolute/external/ssh-dir make live-inventory-healthcheck-runner`
- Inventory file: `ansible/inventories/homelab/hosts.yml`
- Inventory render result: not-yet-run
- Ping target or limit: `all`
- Ping result: not-yet-run
- Unreachable hosts: not-yet-run
- Host-level exceptions, if any: not-yet-run
- Observed non-secret fact mismatches: not-yet-run
- Reviewer: not-yet-run
- Follow-up owner: homelab operator with management-network access
- Follow-up action: rerun the runner-backed healthcheck with
  `LIVE_INVENTORY_SSH_DIR` set to an absolute SSH-auth directory outside this
  repository, record every unreachable host and non-secret mismatch, and leave
  operational readiness locked if any expected host remains unreachable without
  a reviewed exception.

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
