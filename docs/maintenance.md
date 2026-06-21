# Maintenance

## Purpose

This runbook defines the initial maintenance contract for the homelab. The routines and commands are placeholders until the matching Ansible playbooks and runtime automation exist.

Maintenance should be performed through documented commands and reviewable configuration. Manual host or runtime changes are acceptable for investigation or emergency recovery, but lasting changes must be brought back into Git.

## Weekly Routine

Planned weekly checks:

- Review host reachability and basic health.
- Review disk usage on SSD and SD-card backed hosts.
- Review Docker container and volume usage.
- Review Swarm service health if Swarm is in use.
- Review K3s node readiness and application health if K3s is in use.
- Review Flux reconciliation status if Flux is bootstrapped.
- Review public exposure entries for unexpected changes.

## Monthly Routine

Planned monthly checks:

- Apply OS package updates through a controlled Ansible workflow.
- Reboot hosts only when updates or health state require it.
- Review Docker image, container, network, and volume cleanup candidates.
- Review service backup policies and mark any newly important service as requiring backups.
- Review secrets that need rotation or recovery testing.
- Review public routes and remove unused exposure.

## Quarterly Routine

Planned quarterly checks:

- Test recovery notes for at least one host or service.
- Review runtime placement for SD-card wear and SSD capacity.
- Review K3s, Docker, Docker Compose, Swarm, Flux, and Ansible version drift.
- Review firewall and proxy ownership documentation.
- Review whether monitoring, backup, or dependency update automation should be promoted from placeholder to implementation.

## Planned Commands

The commands below are planned interfaces. Do not treat them as available until the referenced playbooks or runtime layers exist.

### Ansible Health Checks

Planned:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/healthcheck.yml
```

Expected purpose: gather non-mutating host facts such as identity, architecture, uptime, memory, and disk state.

### OS Updates

Planned:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/update-os.yml --limit '<host-or-group>'
```

Expected purpose: apply package updates in a targeted, reviewable way. Broad all-host updates should wait until host grouping and reboot policy are documented.

### Controlled Reboots

Planned:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/reboot.yml --limit '<host-or-group>'
```

Expected purpose: reboot only selected hosts or safe batches. K3s servers, Swarm managers, and public edge nodes require extra care before rebooting.

### Docker Cleanup

Planned:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/docker-cleanup.yml --limit docker_hosts
```

Expected purpose: inspect and clean unused Docker images, stopped containers, unused networks, and safe volume candidates according to a documented policy.

Do not remove volumes manually unless the owning service README states that the data is disposable.

### Swarm Checks

Planned:

```sh
docker node ls
docker service ls
docker stack ls
```

Expected purpose: run from a Swarm manager to confirm manager quorum, worker availability, service health, and deployed stacks.

Future Ansible wrapper:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/swarm-healthcheck.yml --limit swarm_managers
```

### K3s Checks

Planned:

```sh
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp
```

Expected purpose: confirm node readiness, workload health, and recent cluster events.

Future Ansible wrapper:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/k3s-healthcheck.yml --limit k3s_servers
```

### Flux Reconciliation

Planned:

```sh
flux get sources all -A
flux get kustomizations -A
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system
```

Expected purpose: inspect GitOps reconciliation and request reconciliation after a Git change has been merged.

Manual `kubectl` edits must not become the source of truth for Flux-managed resources. Any persistent Kubernetes application change belongs under `clusters/homelab/`.

## Rollback And Recovery

Rollback should start with the smallest source-of-truth change:

- Revert the Git change that introduced the issue.
- Reapply the owning playbook, Compose service, Swarm stack, or Flux reconciliation.
- Use manual commands only to restore access or stop active impact.
- Document any emergency manual fix as a follow-up Git change.

