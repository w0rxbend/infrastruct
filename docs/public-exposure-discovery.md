# Public Exposure Discovery Evidence

## Purpose

This note records the reviewed evidence behind the current zero-active-public-route
claim. It is an evidence surface for live host and service discovery, not the
authoritative public exposure register.

The authoritative register remains `docs/public-exposure.md`. If discovery
finds any active production public route, add matching active records to
`ansible/inventories/homelab/hosts.yml`, `docs/services.md`, and
`docs/public-exposure.md` in the same change.

Reproduced discovery evidence must agree with the active-route source of truth.
If `Status: reproduced` and the findings say zero active production public
routes were confirmed, the inventory, `docs/services.md`, and
`docs/public-exposure.md` must also contain zero active production public route
records. If `Status: reproduced` and the findings say active production public
routes were found, at least one active production route must be represented
consistently across all three sources and pass
`scripts/validate-public-exposure-docs`.

The `Findings` field is machine-classified by an explicit phrase contract.
For reproduced zero-route evidence, include one of these exact phrases as a
standalone sentence or sentence-local clause:

- `zero active production public routes confirmed`
- `zero active production public routes were confirmed`
- `zero active production public routes were found`
- `no active production public routes confirmed`
- `no active production public routes were confirmed`
- `no active production public routes were found`

For reproduced active-route evidence, include one of these exact phrases as a
standalone sentence or sentence-local clause:

- `active production public routes confirmed`
- `active production public routes were confirmed`
- `active production public routes found`
- `active production public routes were found`

Richer prose is allowed only outside the machine-classified findings phrase or
in separate review notes. Keep unrelated conclusions, such as drift or
mismatch summaries, in their own sentence or later clause so the classified
phrase remains unambiguous. The validator still cross-checks the classified
finding against the active public exposure register: wording alone cannot prove
live discovery and cannot override inventory, service documentation, or
`docs/public-exposure.md` alignment.

## Reconfirmation Record

| Field | Value |
| --- | --- |
| Status | `not-yet-run` |
| Discovery date | `not-yet-run` |
| Reviewer | `not-yet-assigned` |
| Discovery method | Run from a supported workstation or pinned validation runner with management-network access; render inventory, run `make live-inventory-healthcheck`, then inspect active proxy, firewall, Compose, Swarm, K3s ingress, and host listener state for public routes. |
| Checked scope | `not-yet-run`; expected scope is all 20 promoted inventory hosts plus any source-controlled service records, proxy configurations, firewall rules, published ports, K3s ingress resources, and Swarm/Compose published ports. |
| Findings | No reviewed live host or service discovery output has been captured in this note yet. Do not treat this note as proof that zero active public routes exist. |
| Follow-up owner | `not-yet-assigned` |
| Follow-up action | Run the discovery method above before enabling mutating baseline, firewall, proxy, or service deployment changes. If any active production route exists, promote it into inventory, `docs/services.md`, and `docs/public-exposure.md` together so `scripts/validate-public-exposure-docs` continues to enforce alignment. |

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
- Before using `Status: reproduced`, fill in reviewed non-placeholder values
  for `Discovery date`, `Reviewer`, `Checked scope`, `Findings`,
  `Follow-up owner`, and `Follow-up action`.
- Required reproduced-evidence fields cannot use generic or repository-native
  placeholders such as `unknown`, `tbd`, `pending`, `not recorded`,
  `not-yet-run`, `not-yet-reproduced`, or `not-yet-assigned`.
- The `Findings` field must explicitly state either that zero active production
  public routes were confirmed or that active production public routes were
  found.
- For `Status: reproduced`, use one of the accepted `Findings` phrases listed
  above as a standalone sentence or sentence-local clause; put any richer
  explanation outside that phrase or in separate review notes.
- Zero-route findings are valid only when the active public exposure register
  is also empty across inventory, `docs/services.md`, and
  `docs/public-exposure.md`.
- Active-route findings are valid only when the active route records are
  complete and aligned across inventory, `docs/services.md`, and
  `docs/public-exposure.md`.
- Do not leave active production exposure as prose only. Active routes must be
  represented consistently in inventory, service docs, and the public exposure
  register.
