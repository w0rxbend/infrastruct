# Live Ansible Controller Decision

Status: accepted

The pinned validation runner is the supported live Ansible controller for
non-mutating reachability checks. Use `make live-inventory-healthcheck-runner`
from a host with management-network access when collecting live inventory
render and Ansible ping evidence for the promoted fleet.

The local workstation path remains available only as a prerequisite-dependent
fallback. It is acceptable when the workstation has the required local
`ansible-core`, SSH client support, external authentication material, and
management-network access, but it is not the preferred evidence path while the
pinned runner can provide the same command surface.

Scope boundaries:

- Runner-backed live checks are read-only. They may render inventory and run
  Ansible ping, but must not run mutating playbooks, roles, package changes,
  service changes, firewall changes, Docker, Swarm, K3s, Flux, or privilege
  escalation.
- Live checks require management-network access to the promoted hosts. A
  successful repository validation run is not live reachability evidence by
  itself.
- SSH keys, private SSH configuration, passwords, API tokens, decrypted secret
  values, private age identities, and other private authentication material
  must stay outside Git. Do not commit them to support runner execution.
- Successful runner inventory rendering or local prerequisite checks do not
  unlock mutating baseline roles. Mutating baseline work remains blocked until
  `docs/live-inventory-evidence.md` records successful reviewed evidence for
  the intended live reachability check.

Runner SSH auth mount contract:

- Runner-backed live checks may use `LIVE_INVENTORY_SSH_DIR` to provide SSH
  authentication material to the validation runner. The value must be an
  absolute path, must live outside this Git repository, and must contain only
  operator-managed SSH material required for the live reachability check.
- The runner mounts that directory read-only at `/tmp/.ssh` inside the
  container and sets `HOME=/tmp`. Do not rely on the container writing SSH
  state back to the mounted directory.
- Expected contents are a `config` file when host aliases, SSH users,
  non-default identity filenames, or other OpenSSH client options are needed;
  private keys with OpenSSH-compatible permissions on the host; and a
  pre-populated `known_hosts` file. Host keys should be collected before the
  run because the container mount is read-only and the check should not depend
  on implicit host-key writes.

Example:

```sh
LIVE_INVENTORY_SSH_DIR=/absolute/external/path make live-inventory-healthcheck-runner
```
