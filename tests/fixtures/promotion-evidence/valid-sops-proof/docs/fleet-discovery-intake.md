# Real Fleet Discovery Intake

The authoritative current production inventory is
`ansible/inventories/homelab/hosts.yml`.

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
