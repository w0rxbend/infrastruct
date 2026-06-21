# Inventory Assertions

This role performs non-mutating checks against inventory metadata before any
baseline role makes host changes.

It validates required host fields, hostname identity, management address shape,
supported architecture and storage values, runtime-role structure, and public
exposure metadata. Keep the allowed values in
`ansible/inventories/homelab/group_vars/all.yml` aligned with
`scripts/validate-inventory`.
