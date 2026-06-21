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

See `ansible/README.md` and `ansible/inventories/homelab/README.md` for the
full Ansible workflow and host metadata requirements.
