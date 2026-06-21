# Docker Compose Services

## Ownership

This directory owns standalone Docker Compose service definitions for hosts in the `docker_hosts` inventory group.

Owner tools: Docker Compose for runtime execution, deployed through future Ansible playbooks.

## Service Layout

Each service should live in its own directory:

```text
docker/compose/<service-name>/
  compose.yml
  README.md
  *.sops.env        # optional encrypted environment files
```

The service README must document placement metadata, target host, data path, storage type, public exposure, secret source, update command, restart command, removal command, and rollback expectations.

## Applying Changes

Planned deployment pattern:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/deploy-compose.yml --limit <host> -e compose_service=<service-name>
```

Until that playbook exists, documented manual commands must be run on the intended Docker host from the checked-out service directory:

```sh
docker compose -f compose.yml up -d
```

## Verification

```sh
docker compose -f compose.yml ps
docker compose -f compose.yml logs --tail=100
docker ps --filter label=com.docker.compose.project=<service-name>
```

## Manual Edit Boundary

Do not use ad hoc `docker run` commands as durable service state. Do not edit host-local Compose files, environment files, volumes, or `/opt` copies without committing the intended state here.

## Secrets

Plaintext real secrets do not belong in this directory. Use SOPS-encrypted `*.sops.env` or encrypted YAML files and document the secret source in each service README.

## Rollback And Recovery

Rollback uses Git history and `docker compose up -d` with the previous service definition. Service recovery depends on the service README documenting whether data is stored on SSD, SD card, or ephemeral storage and whether backups are required.
