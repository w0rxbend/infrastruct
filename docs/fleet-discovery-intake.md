# Real Fleet Discovery Intake

Use this document to collect real host facts before promoting the production
inventory from discovery mode to real-fleet mode. It is a human-fillable intake
worksheet, not the machine-readable source of truth.

Real inventory promotion happens in
`ansible/inventories/homelab/hosts.yml`. After the facts below are confirmed,
copy the validated host metadata into that inventory and keep group membership
aligned with `ansible/inventories/homelab/group_contract.yml`.

Do not record secrets here. Do not include passwords, private keys, API tokens,
WireGuard keys, recovery phrases, SSH private key paths, one-time setup codes,
or private service credentials. If a host or route depends on a secret, record
only the encrypted file path, secret owner, or secret name reference.

## Allowed Values

Use these values so the intake can be promoted without translation drift.

| Field | Allowed values |
| --- | --- |
| Architecture | `arm64`, `armv7` |
| Storage type | `ssd`, `sdcard` |
| Runtime roles | `k3s_server`, `k3s_agent`, `docker_host`, `swarm_manager`, `swarm_worker`, `edge_node` |
| Public exposure flag | `true`, `false` |
| Public route exposure state | `active`, `production`, `planned`, `non-production`, or `none` when the host has no public route |
| Raspberry Pi Zero placement | A host whose `hardware_model` contains `zero`, case-insensitively, must be promoted into the `pi_zero` inventory group. Other hosts must not be placed there. |

If discovery finds a value outside the allowed inventory contract, write it in
the notes and resolve the contract decision before promotion. Do not invent a
new production inventory value in this document.

## Public Exposure Rules

If `Public exposure flag` is `true`, fill in the public exposure metadata for
every active, production, planned, or non-production route on that host.

Active production routes must also be represented in both:

- `docs/public-exposure.md`
- `docs/services.md`

The route metadata here should match those documents when the route is active
or production. Planned and non-production records may stay source-local drafts
until they are promoted, but they still need complete structure so they can be
reviewed.

## Host Record Template

Copy this block if more than 20 machines are discovered.

```markdown
### Host NN

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |
```

## Discovery Records

### Host 01

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 02

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 03

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 04

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 05

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 06

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 07

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 08

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 09

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 10

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 11

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 12

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 13

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 14

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 15

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 16

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 17

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 18

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 19

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

### Host 20

| Field | Value |
| --- | --- |
| Hostname | `unknown` |
| Management IP | `unknown` |
| Architecture | `unknown` |
| Hardware model | `unknown` |
| Storage type | `unknown` |
| Runtime roles | `unknown` |
| Reliability notes | `unknown` |
| Placement notes | `unknown` |
| Public exposure flag | `false` |

| Public exposure metadata | Value |
| --- | --- |
| Exposure state | `none` |
| Route identifier | `none` |
| Service name | `none` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy owner | `none` |
| Internal target | `none` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `none` |

## Promotion Checklist

Before moving facts from this intake into
`ansible/inventories/homelab/hosts.yml`:

- Confirm every host has a real hostname and management IP address.
- Confirm each architecture is one of the allowed inventory values.
- Confirm each storage type reflects the storage intended for workloads, not
  only the boot media when an SSD is attached for service data.
- Confirm every runtime role maps to a required inventory group.
- Confirm Raspberry Pi Zero-class hosts are identifiable from
  `hardware_model` and will be in the `pi_zero` group.
- Confirm hosts with `Public exposure flag` of `true` will be in the
  `public_exposed` group.
- Confirm active or production public routes are also recorded in
  `docs/public-exposure.md` and `docs/services.md`.
- Confirm no sensitive values were recorded in this intake.

After promotion, run the supported validation commands from
`docs/pre-merge-checklist.md`.
