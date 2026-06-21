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

Inventory group placement rules are centralized in
`ansible/inventories/homelab/group_contract.yml`.
`scripts/validate-inventory` remains the schema authority for that contract:
it validates the contract shape, supported keys, required groups, repository
mode, host count, and production inventory structure before Ansible is trusted.
The non-mutating `inventory_assertions` role consumes the validated contract as
a runtime preflight against Ansible's rendered host facts and group placement.
The `host_var` names and public exposure `exposed_field` in that contract are
real extension points consumed by both validators. The current production
schema uses `runtime_roles`, `architecture`, `storage_type`, `hardware_model`,
and `public_exposure`, and those vars must map to rendered Ansible groups
according to the contract rather than separate tool-local assumptions.

The baseline playbook also starts with the non-mutating
`inventory_assertions` role. It checks each targeted host's required metadata,
hostname identity, management IP shape, supported architecture and storage
values, runtime roles, reliability notes, placement notes, and public exposure
structure before any future mutating baseline role runs. The allowed
architecture, storage, runtime role, and public exposure field lists live in
`ansible/inventories/homelab/group_vars/all.yml`.
Obvious placeholder management addresses and RFC 5737 documentation IPv4
ranges are rejected in both `scripts/validate-inventory` and this Ansible
preflight role, so direct role execution and repository-local validation share
the same production-safety boundary for management addresses.

When changing `ansible/inventories/homelab/group_contract.yml` or
`ansible/roles/inventory_assertions/`, run the semantic assertion fixture gate:

```sh
make test-inventory-assertions-runner
```

The full validation runner is also acceptable. A local
`scripts/test-inventory-assertions` or `make validate-local-contracts` run may
skip the real Ansible role fixtures when `ansible-playbook` is unavailable, so
those local checks are not enough to prove assertion behavior for contract or
role changes.

See `ansible/README.md` and `ansible/inventories/homelab/README.md` for the
full Ansible workflow and host metadata requirements.
