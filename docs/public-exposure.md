# Public Exposure

## Purpose

This document is the public exposure register for the homelab. Every route, listener, or published port reachable from the public internet must be recorded here before it is treated as intentional.

Public exposure is owned by documentation plus the relevant firewall, proxy, inventory, Compose, Swarm, or K3s configuration. No runtime state should be considered authoritative unless the same exposure can be reviewed from Git.

## Review Rule

All public exposure changes must be reviewable as a Git diff before they are applied.

That includes:

- new public ports or protocols
- changed public ports or protocols
- proxy owner changes such as Traefik, Caddy, nginx, direct host port, or Swarm published port
- changed internal targets
- changed firewall intent
- changed secret dependencies
- removal of public exposure

Emergency manual exposure changes must be temporary. Record the final desired state in this document and the owning configuration before the change is considered complete.

## Required Record Format

Use this template for every public route or port.

```md
### <service-name>

| Field | Value |
| --- | --- |
| Route identifier | `<stable-route-id>` |
| Service name | `<service-name>` |
| Exposure state | `active`, `production`, `planned`, or `non-production` |
| Runtime | `K3s`, `Docker Compose`, `Docker Swarm`, `host`, or `other` |
| Public host or port | `<public-hostname-or-port-number>` |
| Protocol | `tcp`, `udp`, `http`, `https`, or explicit combination |
| Proxy owner | `Traefik`, `Caddy`, `nginx`, `direct host port`, `Swarm published port`, or `none` |
| Host or cluster | `<hostname>`, `<swarm-name>`, or `<cluster-name>` |
| Internal target | `<host-or-service>:<port>` |
| Firewall intent | `allow from internet`, `allow restricted source`, `deny`, or planned rule name |
| Secret dependency | `none`, encrypted file path, or secret name reference |
| Review notes | Reason for exposure, expected users, known risks, expiry or review date |
```

Required fields must not be left blank for real production exposure. Use
`none` only when there is intentionally no value, such as no secret dependency.
Use `Exposure state` only when a record needs to be modeled before it is active:
`planned` and `non-production` records are not counted as active public routes
and may carry placeholders such as `unknown`; `active` and `production` records
must provide complete values.

## Validation Contract

Public exposure records are checked as a shared contract across:

- `ansible/inventories/homelab/hosts.yml`
- `docs/services.md`
- `docs/public-exposure.md`

When any source declares a public route, every required source must describe the
same route with the same canonical values. The validated route fields are:
route identifier, runtime, proxy owner, public host or port, protocol, target
host or cluster, target, firewall intent, secret dependency, and review notes.

Use the `Public host or port` field name for service records in
`docs/services.md`; it is the supported service-record field for public
exposure data. Use `Protocol` for the public protocol in both documentation
records and `protocol` in inventory public exposure metadata. The public
exposure register uses `Host or cluster` for the same canonical placement value
that service records provide through `Host or cluster placement` and inventory
provides through `target_host_or_cluster`. The public exposure register uses
`Internal target` for the same canonical target value that service records
provide through `Internal target` and inventory provides through public exposure
metadata.

Blank values and obvious empty placeholders such as `none`, `n/a`, and `not
declared` are treated as empty by validation. `unknown` and `planned` are not
valid substitutes for active production route values unless the same record is
explicitly marked with `Exposure state` of `planned` or `non-production`.

## Current Public Exposure

No production public routes or ports have been declared in this repository yet. Real route discovery is pending, and the production `public_exposed` inventory group is intentionally empty until real hosts and routes are documented.

Add real entries below this line as services are brought under management.

## Change Checklist

Before adding or changing public exposure:

- Confirm the service is documented in `docs/services.md`.
- Confirm the host or cluster placement is documented.
- Confirm the proxy owner is unambiguous.
- Confirm the firewall intent matches the implementation.
- Confirm secrets are referenced by encrypted source or runtime secret name, not plaintext.
- Confirm rollback is possible by reverting the Git change and reapplying the owning runtime configuration.
