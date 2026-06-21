# Homelab K3s Cluster

## Ownership

This directory owns GitOps desired state for the homelab K3s cluster.

Owner tools: Flux CD for reconciliation, with Ansible owning host lifecycle, node joins, upgrades, labels, and reboots.

## Directory Layout

```text
clusters/homelab/
  flux-system/      # Flux bootstrap and sync resources
  infrastructure/   # cluster infrastructure controllers and shared services
  apps/             # application workloads reconciled by Flux
```

## Applying Changes

Kubernetes changes are applied by committing manifests here and allowing Flux to reconcile them:

```sh
flux reconcile source git flux-system
flux reconcile kustomization <name>
```

These commands are planned until Flux bootstrap manifests exist.

## Verification

```sh
flux get sources git
flux get kustomizations
flux get helmreleases --all-namespaces
kubectl get nodes -o wide
```

## Manual Edit Boundary

Manual `kubectl` changes must not become the source of truth. If `kubectl edit`, `kubectl apply`, a dashboard, or a Helm CLI command is used for emergency recovery, commit the intended final state here immediately afterward.

## Secrets

Kubernetes secret manifests must be encrypted with SOPS before entering Git. Cluster-owned encrypted secrets should live beside the consuming manifest under `apps/` or `infrastructure/`, or under `secrets/kubernetes/` when shared.

## Rollback And Recovery

Use Git revert and Flux reconciliation for rollback. For cluster rebuilds, restore K3s nodes with Ansible first, then restore Flux bootstrap resources and let this directory reconcile.
