# Real Fleet Discovery Intake

This file began as the human discovery worksheet used before promoting the
real-fleet inventory. The current authoritative production inventory is
`ansible/inventories/homelab/hosts.yml`; use that file, not this document,
for automation, group membership, host variables, and current desired state.

The records below are a non-secret snapshot copied from the promoted
inventory so the worksheet no longer contradicts production state. If a
future discovery pass finds drift, update `hosts.yml` first and keep this
document as supporting audit context only.

Do not record secrets here. Do not include passwords, private keys, API tokens,
WireGuard keys, recovery phrases, SSH private key paths, one-time setup codes,
or private service credentials. If a host or route depends on a secret, record
only the encrypted file path, secret owner, or secret name reference.

## Allowed Values

These are the currently supported production inventory values.

| Field | Allowed values |
| --- | --- |
| Architecture | `arm64`, `armv7` |
| Storage type | `ssd`, `sdcard` |
| Runtime roles | `k3s_server`, `k3s_agent`, `docker_host`, `swarm_manager`, `swarm_worker`, `edge_node` |
| Public exposure flag | `true`, `false` |
| Public route exposure state | `active`, `production`, `planned`, `non-production`, or `none` when the host has no public route |
| Raspberry Pi Zero placement | A host whose `hardware_model` contains `zero`, case-insensitively, belongs in the `pi_zero` inventory group. Other hosts must not be placed there. |

If discovery finds a value outside the allowed inventory contract, write it in
review notes and resolve the contract decision before changing production
inventory values.

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

Copy this block only for a new discovery record. The `unknown` values below are
template-only placeholders; replace them with confirmed non-secret facts before
promotion.

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

## Promoted Inventory Snapshot

These records mirror the current non-secret host facts in
`ansible/inventories/homelab/hosts.yml` as of the real-fleet promotion. The
inventory file remains authoritative if this snapshot ever drifts.

### lab-cp-01

| Field | Value |
| --- | --- |
| Hostname | `lab-cp-01` |
| Management IP | `10.42.10.11` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 5 |
| Storage type | `ssd` |
| Runtime roles | `k3s_server` |
| Reliability notes | Primary control-plane host on UPS-backed power and SSD media. |
| Placement notes | Prefer control-plane services and cluster coordination workloads. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-cp-02

| Field | Value |
| --- | --- |
| Hostname | `lab-cp-02` |
| Management IP | `10.42.10.12` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 5 |
| Storage type | `ssd` |
| Runtime roles | `k3s_server` |
| Reliability notes | Secondary control-plane host on UPS-backed power and SSD media. |
| Placement notes | Prefer control-plane services and cluster coordination workloads. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-cp-03

| Field | Value |
| --- | --- |
| Hostname | `lab-cp-03` |
| Management IP | `10.42.10.13` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `ssd` |
| Runtime roles | `k3s_server` |
| Reliability notes | Tertiary control-plane host with active cooling and SSD media. |
| Placement notes | Prefer quorum, cluster add-ons, and light stateful workloads. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-01

| Field | Value |
| --- | --- |
| Hostname | `lab-app-01` |
| Management IP | `10.42.10.14` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `ssd` |
| Runtime roles | `k3s_agent`, `docker_host` |
| Reliability notes | Worker host with SSD service data and active cooling. |
| Placement notes | Prefer K3s application workloads and Compose services needing SSD media. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-02

| Field | Value |
| --- | --- |
| Hostname | `lab-app-02` |
| Management IP | `10.42.10.15` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `ssd` |
| Runtime roles | `k3s_agent`, `docker_host` |
| Reliability notes | Worker host with SSD service data and active cooling. |
| Placement notes | Prefer K3s application workloads and Compose services needing SSD media. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-03

| Field | Value |
| --- | --- |
| Hostname | `lab-app-03` |
| Management IP | `10.42.10.16` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `ssd` |
| Runtime roles | `k3s_agent`, `docker_host` |
| Reliability notes | Worker host with SSD service data and active cooling. |
| Placement notes | Prefer K3s application workloads and Compose services needing SSD media. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-04

| Field | Value |
| --- | --- |
| Hostname | `lab-app-04` |
| Management IP | `10.42.10.17` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `ssd` |
| Runtime roles | `k3s_agent`, `docker_host` |
| Reliability notes | Worker host with SSD service data and active cooling. |
| Placement notes | Prefer K3s application workloads and Compose services needing SSD media. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-05

| Field | Value |
| --- | --- |
| Hostname | `lab-app-05` |
| Management IP | `10.42.10.18` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `sdcard` |
| Runtime roles | `k3s_agent` |
| Reliability notes | Worker host uses SD-card media and active cooling. |
| Placement notes | Prefer stateless K3s workloads with low write volume. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-app-06

| Field | Value |
| --- | --- |
| Hostname | `lab-app-06` |
| Management IP | `10.42.10.19` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `sdcard` |
| Runtime roles | `k3s_agent` |
| Reliability notes | Worker host uses SD-card media and active cooling. |
| Placement notes | Prefer stateless K3s workloads with low write volume. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-swarm-01

| Field | Value |
| --- | --- |
| Hostname | `lab-swarm-01` |
| Management IP | `10.42.10.20` |
| Architecture | `arm64` |
| Hardware model | ROCK64 |
| Storage type | `ssd` |
| Runtime roles | `docker_host`, `swarm_manager` |
| Reliability notes | Swarm manager host with SSD service data. |
| Placement notes | Prefer Swarm manager duties and low-churn Compose services. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-swarm-02

| Field | Value |
| --- | --- |
| Hostname | `lab-swarm-02` |
| Management IP | `10.42.10.21` |
| Architecture | `arm64` |
| Hardware model | ROCK64 |
| Storage type | `ssd` |
| Runtime roles | `docker_host`, `swarm_manager` |
| Reliability notes | Swarm manager host with SSD service data. |
| Placement notes | Prefer Swarm manager duties and low-churn Compose services. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-swarm-03

| Field | Value |
| --- | --- |
| Hostname | `lab-swarm-03` |
| Management IP | `10.42.10.22` |
| Architecture | `arm64` |
| Hardware model | ROCK64 |
| Storage type | `ssd` |
| Runtime roles | `docker_host`, `swarm_worker` |
| Reliability notes | Swarm worker host with SSD service data. |
| Placement notes | Prefer Swarm workloads that need persistent local storage. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-swarm-04

| Field | Value |
| --- | --- |
| Hostname | `lab-swarm-04` |
| Management IP | `10.42.10.23` |
| Architecture | `arm64` |
| Hardware model | ROCK64 |
| Storage type | `ssd` |
| Runtime roles | `docker_host`, `swarm_worker` |
| Reliability notes | Swarm worker host with SSD service data. |
| Placement notes | Prefer Swarm workloads that need persistent local storage. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-swarm-05

| Field | Value |
| --- | --- |
| Hostname | `lab-swarm-05` |
| Management IP | `10.42.10.24` |
| Architecture | `arm64` |
| Hardware model | ROCK64 |
| Storage type | `sdcard` |
| Runtime roles | `docker_host`, `swarm_worker` |
| Reliability notes | Swarm worker host uses SD-card media. |
| Placement notes | Prefer stateless Swarm tasks with minimal local writes. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-edge-01

| Field | Value |
| --- | --- |
| Hostname | `lab-edge-01` |
| Management IP | `10.42.10.25` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `sdcard` |
| Runtime roles | `docker_host`, `edge_node` |
| Reliability notes | Edge host uses SD-card media and local network placement. |
| Placement notes | Prefer edge-adjacent services and non-critical Docker workloads. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-edge-02

| Field | Value |
| --- | --- |
| Hostname | `lab-edge-02` |
| Management IP | `10.42.10.26` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `sdcard` |
| Runtime roles | `docker_host`, `edge_node` |
| Reliability notes | Edge host uses SD-card media and local network placement. |
| Placement notes | Prefer edge-adjacent services and non-critical Docker workloads. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-pi-01

| Field | Value |
| --- | --- |
| Hostname | `lab-pi-01` |
| Management IP | `10.42.10.27` |
| Architecture | `armv7` |
| Hardware model | Raspberry Pi 3 Model B |
| Storage type | `sdcard` |
| Runtime roles | `docker_host` |
| Reliability notes | ARMv7 Docker host uses SD-card media. |
| Placement notes | Prefer low-write utility containers and maintenance targets. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-pi-02

| Field | Value |
| --- | --- |
| Hostname | `lab-pi-02` |
| Management IP | `10.42.10.28` |
| Architecture | `armv7` |
| Hardware model | Raspberry Pi 3 Model B |
| Storage type | `sdcard` |
| Runtime roles | `docker_host` |
| Reliability notes | ARMv7 Docker host uses SD-card media. |
| Placement notes | Prefer low-write utility containers and maintenance targets. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-zero-01

| Field | Value |
| --- | --- |
| Hostname | `lab-zero-01` |
| Management IP | `10.42.10.29` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi Zero 2 W |
| Storage type | `sdcard` |
| Runtime roles | `edge_node` |
| Reliability notes | Compact edge host with SD-card media and limited compute capacity. |
| Placement notes | Prefer lightweight edge checks and avoid write-heavy services. |
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
| Review notes | Discovery recorded no active production public route on this host. |

### lab-zero-02

| Field | Value |
| --- | --- |
| Hostname | `lab-zero-02` |
| Management IP | `10.42.10.30` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi Zero 2 W |
| Storage type | `sdcard` |
| Runtime roles | `edge_node` |
| Reliability notes | Compact edge host with SD-card media and limited compute capacity. |
| Placement notes | Prefer lightweight edge checks and avoid write-heavy services. |
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
| Review notes | Discovery recorded no active production public route on this host. |
