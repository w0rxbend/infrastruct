# Host Contract

This file is the human-maintained contract for physical and virtual hosts in the homelab. The Ansible inventory should carry the machine-readable version of these facts, but this document should stay readable enough for planning, reviews, and maintenance.

Every real host added to the repository must have a record here or a clearly linked inventory record with the same required fields. Do not rely on memory for host roles, storage reliability, or public exposure decisions.

## Current Operating Assumptions

- A public static IP exists.
- No DNS provider has been selected yet.
- No preferred secrets manager has been selected yet.
- No critical backups exist yet.
- Storage is mixed between SSD-backed hosts and SD-card-backed hosts.
- Docker Compose, Docker Swarm, and K3s are all first-class runtimes.

## Host Record Template

Copy this template for each host and keep values explicit. Use `none`, `unknown`, or `planned` when a value is not available yet; do not leave required fields blank.

```markdown
### <hostname>

| Field | Value |
| --- | --- |
| Hostname | `<hostname>` |
| Hardware model | `<model>` |
| Architecture | `<amd64 | arm64 | armv7 | other>` |
| IP address | `<static or reserved IP>` |
| Storage type | `<SSD | SD card | ephemeral | other>` |
| Runtime role | `<K3s server | K3s agent | Docker host | Swarm manager | Swarm worker | edge node | other>` |
| Reliability notes | `<power, thermal, network, storage, or hardware concerns>` |
| Publicly exposed services | `<none or service names and ports>` |
```

## Host Records

Add host records below as real host facts are confirmed.

### Example

| Field | Value |
| --- | --- |
| Hostname | `example-node-01` |
| Hardware model | `Raspberry Pi 4 Model B` |
| Architecture | `arm64` |
| IP address | `192.0.2.10` |
| Storage type | `SSD` |
| Runtime role | `K3s agent` |
| Reliability notes | `Example only; replace with observed power, thermal, network, and storage notes.` |
| Publicly exposed services | `none` |

## Maintenance Rules

- Host roles must match the Ansible inventory groups before automation depends on them.
- Publicly exposed services must also be recorded in `docs/public-exposure.md`.
- Storage type must be accurate before placing stateful services.
- Reliability notes should capture known weaknesses such as SD-card wear, unstable power, thermal throttling, weak Wi-Fi, or host-specific maintenance constraints.

## Live Inventory Verification

`ansible/inventories/homelab/hosts.yml` is the authoritative current
production inventory. Before enabling any mutating baseline, Docker, Swarm,
K3s, or Flux role against the promoted real fleet, run the read-only live
inventory healthcheck from a supported workstation with network access to the
management addresses:

```sh
make live-inventory-healthcheck
```

The target is a wrapper around these non-mutating steps:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --list
ANSIBLE_BECOME=false ansible all -i ansible/inventories/homelab/hosts.yml -m ansible.builtin.ping -e ansible_become=false
```

The script renders the production inventory first and stops with a
`PREREQUISITE FAILURE` or `MISSING TOOL` message if `ansible-core`, the
inventory file, or inventory rendering is broken. It runs no playbooks, no
roles, and no privilege escalation. If the Ansible ping step reports unreachable
hosts, the script exits separately with `LIVE REACHABILITY FAILURE` so operator
access problems are not confused with repository contract failures.

To check a subset while investigating access, keep the same script and set an
Ansible limit:

```sh
ANSIBLE_LIMIT=k3s_servers make live-inventory-healthcheck
ANSIBLE_LIMIT=lab-cp-01 make live-inventory-healthcheck
```

Record every unreachable host before baseline work starts. For each host, note
the inventory hostname, `ansible_host`, failure class such as timeout,
authentication failure, refused connection, or DNS/routing issue, the command
used, the date, and whether the host should be temporarily excluded from
automation.

After reachability passes, compare observed non-secret host facts against this
document and the production inventory before enabling mutating roles. At
minimum, check hostname identity, architecture, hardware model, storage class,
runtime placement, public exposure state, and reliability notes. Record any
mismatch as a documentation or inventory correction first; do not work around a
fact mismatch inside a mutating role.
