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

Copy this template for each service. Use `none`, `unknown`, or `planned` when a value is not available yet; do not leave required fields blank.

```markdown
### <service name>

| Field | Value |
| --- | --- |
| Route identifier | `<stable-route-id-or-none>` |
| Service name | `<service name>` |
| Runtime | `<K3s | Docker Compose | Docker Swarm>` |
| Host or cluster placement | `<hostname, Swarm placement, or K3s cluster/namespace>` |
| Public host or port | `<none | public hostname | public port and protocol | route name>` |
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

## Service Records

Add service records below as workloads are brought under source control.

### Example

| Field | Value |
| --- | --- |
| Route identifier | `none` |
| Service name | `example-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
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

- Public routes and ports must also be recorded in `docs/public-exposure.md`.
- Services with `required` backups must have a documented restore path before they are considered protected.
- Stateful services should prefer SSD-backed placement unless there is an explicit reason to accept SD-card risk.
- Secrets must not be written in plaintext in this file. Reference the encrypted source or secret owner instead.
- Runtime placement should match the relevant Compose file, Swarm stack, or K3s manifest before changes are applied.
