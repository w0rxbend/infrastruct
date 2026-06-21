# Service Contract

This file is the human-maintained contract for services running in the homelab. It records where a service runs, how it is exposed, where its data lives, how secrets are provided, and what recovery expectations exist.

Every service managed by Docker Compose, Docker Swarm, or K3s must have a record here before it is treated as production-like. Runtime manifests and playbooks are the source of applied state; this document is the source of operational intent.

## Current Operating Assumptions

- A public static IP exists.
- No DNS provider has been selected yet.
- No preferred secrets manager has been selected yet.
- No critical backups exist yet.
- Storage is mixed between SSD-backed hosts and SD-card-backed hosts.
- Docker Compose, Docker Swarm, and K3s are all first-class runtimes.

## Service Record Template

Copy this template for each service. Use `none` for explicit non-exposure
values. Use `unknown` or `planned` only when `Exposure state` is `planned` or
`non-production`; active production exposure must not leave required fields
blank or placeholder-only.

```markdown
### <service name>

| Field | Value |
| --- | --- |
| Exposure state | `<active | production | planned | non-production>` |
| Route identifier | `<stable-route-id-or-none>` |
| Service name | `<service name>` |
| Runtime | `<K3s | Docker Compose | Docker Swarm>` |
| Host or cluster placement | `<hostname, Swarm placement, or K3s cluster/namespace>` |
| Public host or port | `<none | public hostname | public port and protocol | route name>` |
| Protocol | `<none | tcp | udp | http | https | explicit combination>` |
| Proxy or direct-port routing | `<Traefik | Caddy | nginx | direct host port | Swarm published port | none>` |
| Internal target | `<container port, service DNS name, ClusterIP, or host socket>` |
| Firewall intent | `<allow from internet | allow restricted source | deny | planned rule name | none>` |
| Data path | `<host path, volume name, PVC, object store, or ephemeral>` |
| Storage type | `<SSD | SD card | ephemeral | mixed | other>` |
| Secret dependency | `<SOPS file, encrypted Ansible vars, Kubernetes Secret, Compose env file, Swarm secret, none>` |
| Backup policy | `<none | optional | required>` |
| Review notes | `<reason for exposure, expected users, known risks, expiry, review date, or none>` |
| Maintenance notes | `<update, restart, migration, restore, or owner notes>` |
```

## Public Exposure Contract

For services with public exposure, the service record must agree with
`docs/public-exposure.md` and `ansible/inventories/homelab/hosts.yml`. The
validated canonical fields are route identifier, runtime, proxy owner, public
host or port, protocol, target host or cluster, target, firewall intent, secret
dependency, and review notes.

Use `Public host or port` exactly for the service-record field that declares
the public hostname, route name, published port, or `none`. Use `Protocol`
exactly for the public protocol. The corresponding placement field is `Host or
cluster placement`, the corresponding proxy-owner field is `Proxy or
direct-port routing`, and the corresponding target field is `Internal target`.

If a service has no public exposure, keep `Route identifier`, `Public host or
port`, `Protocol`, `Proxy or direct-port routing`, `Firewall intent`, and
`Secret dependency` set to explicit non-exposure values such as `none`. If a
route is planned, unknown, or non-production, set `Exposure state` to `planned`
or `non-production`; those records are not counted as active public routes.
Do not use `unknown` or `planned` as placeholders for active production public
routes. Do not document a public route in only this file; every active public
route must be represented consistently in inventory, service docs, and the
public exposure register.

## Service Records

Add service records below as workloads are brought under source control.

### Example

| Field | Value |
| --- | --- |
| Exposure state | `active` |
| Route identifier | `none` |
| Service name | `example-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `example-service:8080` |
| Firewall intent | `none` |
| Data path | `/srv/example-service` |
| Storage type | `SSD` |
| Secret dependency | `none` |
| Backup policy | `none` |
| Review notes | `Example only; no production public route is declared.` |
| Maintenance notes | `Example only; replace with real update, restart, and recovery expectations.` |

## Maintenance Rules

- Public routes and ports must also be recorded in `docs/public-exposure.md`
  and inventory public exposure metadata with matching canonical values.
- Services with `required` backups must have a documented restore path before they are considered protected.
- Stateful services should prefer SSD-backed placement unless there is an explicit reason to accept SD-card risk.
- Secrets must not be written in plaintext in this file. Reference the encrypted source or secret owner instead.
- Runtime placement should match the relevant Compose file, Swarm stack, or K3s manifest before changes are applied.
