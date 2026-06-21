# Ansible Inventory Contract

The production Ansible inventory is guarded by `repo-mode.yml`.

Current discovery contract:

```yaml
mode: discovery
expected_host_count: 0
```

Discovery mode is only for the current scaffold state. It allows
`ansible/inventories/homelab/hosts.yml` to keep the required group structure
while declaring no production hosts.

Before adding the real 20-machine inventory, update `repo-mode.yml` first:

```yaml
mode: real-fleet
expected_host_count: 20
```

After that switch, `scripts/validate-inventory` requires the production
inventory host count to exactly match `expected_host_count`. The validator still
enforces required group shape, required host fields, placeholder rejection,
RFC 5737 documentation address rejection, and public exposure group consistency.

The baseline playbook also starts with the non-mutating
`inventory_assertions` role. It checks each targeted host's required metadata,
hostname identity, management IP shape, supported architecture and storage
values, runtime roles, reliability notes, placement notes, and public exposure
structure before any future mutating baseline role runs. The allowed
architecture, storage, runtime role, and public exposure field lists live in
`ansible/inventories/homelab/group_vars/all.yml`.

See `ansible/README.md` and `ansible/inventories/homelab/README.md` for the
full Ansible workflow and host metadata requirements.
