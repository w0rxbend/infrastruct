# Homelab Inventory

This directory is the Ansible source of truth for homelab host identity, placement, runtime roles, storage class, and public exposure metadata.

The current `hosts.yml` contains placeholder hosts only. Replace them with real fleet facts before using this inventory for mutating playbooks.

## Render The Inventory

Show the group tree:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --graph
```

Show the rendered host and group variables:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --list --yaml
```

Inspect one host:

```sh
ansible-inventory -i ansible/inventories/homelab/hosts.yml --host homelab-example-k3s-server-01 --yaml
```

## Required Host Fields

Every real host must declare these fields directly in inventory:

| Field | Purpose |
| --- | --- |
| `hostname` | Expected system hostname. |
| `ansible_host` | Management IP address used by Ansible. |
| `architecture` | CPU architecture, currently `arm64` or `armv7`. |
| `hardware_model` | Human-readable board or machine model. |
| `storage_type` | Primary workload storage class, currently `ssd` or `sdcard`. |
| `runtime_roles` | List of roles such as `k3s_server`, `k3s_agent`, `docker_host`, `swarm_manager`, `swarm_worker`, or `edge_node`. |
| `reliability_notes` | Known power, thermal, SD-card, network, uptime, or hardware concerns. |
| `placement_notes` | Workload placement guidance and reasons for preferring or avoiding the host. |
| `public_exposure` | Structured metadata showing whether the host exposes any public services. |

`public_exposure` must include:

| Field | Purpose |
| --- | --- |
| `exposed` | Boolean indicating whether any service on the host is publicly reachable. |
| `services` | List of public service records, or an empty list. |
| `notes` | Review notes or a pointer to `docs/public-exposure.md`. |

Each public service record should include at least `name`, `protocol`, `public_port`, `owner`, and `internal_target`.

## Required Groups

The inventory keeps runtime, hardware, storage, and exposure groups queryable:

- `k3s_servers`
- `k3s_agents`
- `docker_hosts`
- `swarm_managers`
- `swarm_workers`
- `edge_nodes`
- `arm64`
- `armv7`
- `pi_zero`
- `ssd_storage`
- `sdcard_storage`
- `public_exposed`

A host may belong to several groups. Group membership must match `runtime_roles`, `architecture`, `storage_type`, and `public_exposure.exposed`.

## Group Vars

`group_vars/all.yml` defines shared contract values and allowed metadata names. Runtime group files are intentionally minimal until playbooks define concrete policy. Put future K3s, Docker, and Swarm defaults in the matching runtime group var file.

Do not put plaintext secrets in group vars. Use SOPS-encrypted files for credentials, tokens, private keys, and password material.

## Change Rules

- Replace placeholder hosts with real host facts before running mutating playbooks.
- Keep public exposure changes reviewable as inventory and documentation diffs.
- Record host-specific exceptions in host vars or a clearly named encrypted var file if the exception is sensitive.
- Do not rely on manual host changes as the long-term source of truth.
