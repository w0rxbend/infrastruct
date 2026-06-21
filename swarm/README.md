# Docker Swarm

## Ownership

This area owns Docker Swarm stack definitions and documentation for multi-host Docker workloads.

Owner tools: Docker Swarm for runtime scheduling, applied through Ansible from an inventory-selected Swarm manager.

Primary location: `stacks/`.

## Applying Changes

Swarm stack changes are made in Git under `swarm/stacks/` and deployed from a Swarm manager through future Ansible playbooks or documented `docker stack deploy` commands.

## Verification

Planned verification commands include:

```sh
docker node ls
docker stack ls
docker stack services <stack-name>
docker service ps <service-name>
```

Run these from a Swarm manager after deployment.

## Manual Edit Boundary

Do not make lasting changes with ad hoc `docker service update`, `docker config`, `docker secret`, or manager-local stack files without reflecting the desired state in Git.

## Secrets

Swarm secrets must not be committed in plaintext. Encrypted inputs and rotation notes belong under `secrets/` or in a documented encrypted file path referenced by the stack README.

## Rollback And Recovery

Rollback should redeploy a previous Git version of the stack or use Swarm rollback commands when appropriate, then commit the intended final state. Manager recovery depends on inventory documenting manager and worker roles.
