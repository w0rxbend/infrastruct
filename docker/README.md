# Docker Compose

## Ownership

This area owns standalone Docker Compose service definitions and service-level documentation for hosts that are not managed as Kubernetes apps or Swarm stacks.

Owner tools: Docker Compose for local service runtime, applied through Ansible-managed deployment patterns.

Primary location: `compose/`.

## Applying Changes

Compose changes are made in Git under `docker/compose/<service-name>/` and deployed to the intended Docker host through future Ansible playbooks. No service should require an undocumented manual `docker run` command.

## Verification

Planned verification commands include:

```sh
docker compose ps
docker compose logs --tail=100
docker ps
```

Run these on the target Docker host after deployment or through future Ansible health checks.

## Manual Edit Boundary

Do not make lasting changes directly in `/opt`, host-local compose files, containers, volumes, or environment files without bringing the desired state back into this directory.

## Secrets

Compose secrets and environment files must be encrypted before they are committed. Store encrypted secret material under `secrets/` or beside the Compose service only when the service README documents the source and recovery path.

## Rollback And Recovery

Rollback should use Git history and redeploy the previous Compose definition. Recovery expectations for each service must document data paths, storage type, backup policy, and whether the service is disposable.
