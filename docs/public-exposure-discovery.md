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
| Status | `partial` |
| Discovery date | `2026-06-22` |
| Reviewer | `autonomous implementation agent on workstation ubuntu as worxbend` |
| Discovery method | Checked workstation identity and network placement with `hostname`, `id -un`, `ip -brief addr`, and `ip route`; checked local prerequisites with `command -v ansible-inventory`, `command -v ansible`, `command -v nmap`, `command -v ss`, `command -v ip`, `command -v docker`, `command -v kubectl`, `command -v ufw`, `command -v iptables`, and `command -v nft`; attempted the supported read-only path with `make live-inventory-healthcheck`; checked the source-controlled active public exposure register with `scripts/validate-public-exposure-docs`; probed promoted management addresses with `nmap -sn 10.42.10.11-30` from the local workstation. |
| Checked scope | Source-controlled public exposure records in `ansible/inventories/homelab/hosts.yml`, `docs/services.md`, and `docs/public-exposure.md` were checked and aligned. The current workstation was confirmed as `ubuntu` / `worxbend` on `192.168.1.200/24`, not on the promoted `10.42.10.0/24` management subnet. Live host listeners, firewall rules, proxy configuration, Docker Compose projects, Docker Swarm stacks, K3s ingress or service exposure, and represented edge hosts `lab-edge-01` and `lab-edge-02` were not reproduced because no promoted management host was reachable and `ansible-inventory` / `ansible` are not installed locally. |
| Findings | `scripts/validate-public-exposure-docs` passed and the repository registers still contain zero active production public route records. Live public exposure discovery was not reproduced: `make live-inventory-healthcheck` failed before inventory render because `ansible-inventory` is missing, and `nmap -sn 10.42.10.11-30` reported zero hosts up from this workstation at `2026-06-22T02:36:48+03:00`. Do not treat this partial record as proof that zero active public routes exist. |
| Follow-up owner | `supported-workstation operator with management-network access` |
| Follow-up action | Rerun the discovery method from a supported workstation or pinned runner with `ansible-core` installed and management-network access. Inspect host listeners, firewall rules, proxy configuration, Docker Compose projects, Docker Swarm stacks, K3s ingress and service exposure, and represented edge or reverse-proxy hosts. If any active production route exists, promote it into inventory, `docs/services.md`, and `docs/public-exposure.md` together so `scripts/validate-public-exposure-docs` continues to enforce alignment. |

## Reviewed Command Set

Commands run on `2026-06-22` from workstation `ubuntu` as `worxbend`:

```sh
hostname
id -un
ip -brief addr
ip route
command -v ansible-inventory
command -v ansible
command -v nmap
command -v ss
command -v ip
command -v docker
command -v kubectl
command -v ufw
command -v iptables
command -v nft
make live-inventory-healthcheck
scripts/validate-public-exposure-docs
scripts/validate-operational-readiness
nmap -sn 10.42.10.11-30
```

Observed non-secret results:

- Workstation identity: `ubuntu` / `worxbend`.
- Workstation network: `192.168.1.200/24` with default route via
  `192.168.1.1`; no interface on `10.42.10.0/24`.
- `ansible-inventory` and `ansible` were not found in `PATH`.
- `make live-inventory-healthcheck` failed before inventory rendering with
  `MISSING TOOL: ansible-inventory is required for live inventory healthcheck`.
- `scripts/validate-public-exposure-docs` passed and reported that inventory,
  `docs/services.md`, and `docs/public-exposure.md` agree.
- `scripts/validate-operational-readiness` passed while keeping public
  exposure discovery at `partial`.
- `nmap -sn 10.42.10.11-30` scanned the 20 promoted management addresses and
  reported `0 hosts up`.

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
