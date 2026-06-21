# Real Fleet Discovery Intake

The current authoritative production inventory is
`ansible/inventories/homelab/hosts.yml`. These records are supporting
non-secret discovery evidence only.

### Host 01

| Field | Value |
| --- | --- |
| Hostname | `lab-cp-01` |
| Management IP | `10.42.10.11` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 5 |
| Storage type | `ssd` |
| Runtime roles | `k3s_server` |
| Reliability notes | Primary control-plane host. |
| Placement notes | Prefer control-plane services. |
| Public exposure flag | `false` |
| Exposure state | `none` |

### Host 02

| Field | Value |
| --- | --- |
| Hostname | `lab-app-01` |
| Management IP | `10.42.10.14` |
| Architecture | `arm64` |
| Hardware model | Raspberry Pi 4 Model B |
| Storage type | `sdcard` |
| Runtime roles | `k3s_agent`, `docker_host` |
| Reliability notes | Worker host with SSD media. |
| Placement notes | Prefer application workloads. |
| Public exposure flag | `false` |
| Exposure state | `none` |
