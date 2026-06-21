# Example Inventories

This directory contains non-production inventory examples only.

These files must never be used as the homelab production source of truth. They contain RFC 5737 documentation addresses, placeholder hostnames, and replace-before-use values that exist only to demonstrate inventory shape.

Use examples for reference when adding real hosts to `ansible/inventories/homelab/hosts.yml`, then validate the production inventory before applying any infrastructure change.

## Contents

- `hosts.yml`: sample K3s, Docker, Swarm, edge, storage, architecture, and public exposure group membership.

## Rules

- Do not target mutating playbooks at this directory.
- Do not copy example hostnames, RFC 5737 addresses, or `replace-before-use` values into production inventory.
- Do not treat the example public exposure record as an approved public route.
