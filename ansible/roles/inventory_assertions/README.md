# Inventory Assertions

This role performs non-mutating checks against inventory metadata before any
baseline role makes host changes.

It validates required host fields, hostname identity, management address shape,
supported architecture and storage values, runtime-role structure, runtime,
architecture, storage, Raspberry Pi Zero, and public exposure group placement,
and public exposure metadata.

Group placement is checked from Ansible's rendered inventory for each host.
The host variable names come from
`ansible/inventories/homelab/group_contract.yml`; the names below are the
current production schema, not role-local constants:

- `runtime_roles` must match the corresponding runtime groups.
- `architecture` must match the architecture groups.
- `storage_type` must match the storage groups.
- Raspberry Pi Zero-class hardware must be in `pi_zero`, and only matching
  hardware may be in that group.
- `public_exposure.exposed` must match `public_exposed` membership.

Keep the allowed values and group mappings aligned with
`ansible/inventories/homelab/group_vars/all.yml` and `scripts/validate-inventory`.
