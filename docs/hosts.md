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
