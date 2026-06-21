# Example Compose Service

## Purpose

This is a non-production reference pattern for standalone Docker Compose services. Replace the placeholder host, data path, image, ports, and metadata before deploying a real service.

## Placement Metadata

- Service name: `example-service`
- Runtime: Docker Compose
- Owner tool: Docker Compose, applied through future Ansible deployment
- Intended inventory group: `docker_hosts`
- Target host: `example-docker-host`
- Data path: `/srv/compose/example-service`
- Storage type: ephemeral in this example; real services must declare SSD or SD card when data matters
- Public exposure: none
- Secret source: none

## Data Path Expectations

Persistent data should live under a service-specific host path such as `/srv/compose/<service-name>/`. The service README must state whether that path is backed by SSD, SD card, or disposable storage and whether it has a backup policy.

## Secret Handling

Do not place real secrets in `compose.yml` or plaintext `.env` files. Use an encrypted file such as:

```text
docker/compose/example-service/example-service.sops.env
```

Document the encrypted file path, consumers, rotation steps, and required restart or redeploy action.

## Apply

Planned Ansible deployment:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/deploy-compose.yml --limit example-docker-host -e compose_service=example-service
```

Manual placeholder command from this directory on the target host:

```sh
docker compose -f compose.yml up -d
```

## Verify

```sh
docker compose -f compose.yml ps
docker compose -f compose.yml logs --tail=100
curl -fsS http://127.0.0.1:8080/
```

## Update

```sh
docker compose -f compose.yml pull
docker compose -f compose.yml up -d
```

## Restart

```sh
docker compose -f compose.yml restart
```

## Remove

```sh
docker compose -f compose.yml down
```

Add `--volumes` only after confirming the service data path is disposable or restored elsewhere.

## Rollback

Revert the service directory to the previous Git revision and run `docker compose -f compose.yml up -d`. If an image tag changed, confirm whether local cached images or registry availability affect rollback.
