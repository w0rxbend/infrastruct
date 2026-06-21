# Public Exposure Discovery Evidence

## Purpose

This note records the reviewed evidence behind the current zero-active-public-route
claim. It is an evidence surface for live host and service discovery, not the
authoritative public exposure register.

The authoritative register remains `docs/public-exposure.md`. If discovery
finds any active production public route, add matching active records to
`ansible/inventories/homelab/hosts.yml`, `docs/services.md`, and
`docs/public-exposure.md` in the same change.

## Reconfirmation Record

| Field | Value |
| --- | --- |
| Status | `not-yet-run` |
| Discovery date | `not-yet-run` |
| Reviewer | `not-yet-assigned` |
| Discovery method | Run from a supported workstation or pinned validation runner with management-network access; render inventory, run `make live-inventory-healthcheck`, then inspect active proxy, firewall, Compose, Swarm, K3s ingress, and host listener state for public routes. |
| Checked hosts or services | `not-yet-run`; expected scope is all 20 promoted inventory hosts plus any source-controlled service records, proxy configurations, firewall rules, published ports, K3s ingress resources, and Swarm/Compose published ports. |
| Findings | No reviewed live host or service discovery output has been captured in this note yet. Do not treat this note as proof that zero active public routes exist. |
| Follow-up | Run the discovery method above before enabling mutating baseline, firewall, proxy, or service deployment changes. If any active production route exists, promote it into inventory, `docs/services.md`, and `docs/public-exposure.md` together so `scripts/validate-public-exposure-docs` continues to enforce alignment. |

## Command Shape

Use one of these shapes from a supported workstation or pinned runner. Capture
the exact command, date, runner or workstation identity, and summarized output
in the record above.

```sh
make live-inventory-healthcheck
```

```sh
scripts/live-inventory-healthcheck
```

Optional host-limited probes may be used during troubleshooting, but the final
reconfirmation record should cover the full promoted inventory before changing
the status to reproduced.

## Evidence Rules

- Keep private keys, tokens, public IP ownership data, and sensitive service
  details out of this file.
- Use `Status: not-yet-run` until live discovery output has been reviewed.
- Use `Status: partial` only when some hosts or service surfaces were checked
  and the unchecked scope is named explicitly.
- Use `Status: reproduced` only when the promoted inventory and relevant
  service, proxy, firewall, published-port, and ingress surfaces have been
  reviewed and the findings are recorded.
- Do not leave active production exposure as prose only. Active routes must be
  represented consistently in inventory, service docs, and the public exposure
  register.
