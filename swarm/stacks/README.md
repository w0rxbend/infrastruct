# Swarm Stacks

## Ownership

This directory owns Docker Swarm stack files. Stack state should be changed in Git and deployed from an inventory-declared Swarm manager.

Owner tools: Docker Swarm for runtime scheduling, applied through future Ansible playbooks or documented manager commands.

## Stack Layout

Each stack file should include labels or README metadata covering service name, stack name, target manager group, placement constraints, public exposure, data paths, storage type, secret source, update path, rollback path, and removal command.

## Applying Changes

Planned deployment pattern:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/deploy-swarm.yml -e swarm_stack=<stack-name>
```

Until that playbook exists, run deployment from a Swarm manager:

```sh
docker stack deploy -c swarm/stacks/<stack-name>.yml <stack-name>
```

## Verification

```sh
docker node ls
docker stack ls
docker stack services <stack-name>
docker stack ps <stack-name>
```

## Manual Edit Boundary

Do not make durable service changes with one-off `docker service update`, manager-local stack files, or unmanaged Swarm secrets. The intended stack definition must be committed here.

## Secrets

Real Swarm secret values must be encrypted with SOPS before Git commit. Document whether a stack consumes Docker secrets, encrypted environment files, or external secret material.

## Rollback And Recovery

Rollback uses a previous Git revision and another `docker stack deploy`. Emergency `docker service rollback` may restore service health, but the final desired state still needs to be committed in this directory.
