# Clusters

## Ownership

This area owns Kubernetes desired state for K3s clusters. `clusters/homelab/` is reserved for the homelab cluster and will contain Flux, infrastructure, and application manifests.

Owner tools: Flux CD for in-cluster reconciliation, with Ansible owning host lifecycle outside the cluster.

## Applying Changes

Kubernetes application changes are applied by committing manifests to this directory and allowing Flux to reconcile them. K3s installation, node joins, upgrades, and host-level settings belong in Ansible, not in this tree.

## Verification

Planned verification commands include:

```sh
flux get kustomizations
flux get helmreleases --all-namespaces
kubectl get nodes -o wide
```

These commands are placeholders until Flux and K3s manifests are added.

## Manual Edit Boundary

Do not make lasting Kubernetes changes with `kubectl edit`, `kubectl apply`, or dashboard actions unless the same desired state is committed here. Manual cluster edits must not become the source of truth.

## Secrets

Kubernetes secrets must be encrypted with SOPS before entering Git. Secret manifests may live under `clusters/homelab/` when they are cluster-owned, with supporting policy and key handling documented in `secrets/`.

## Rollback And Recovery

Rollback should use Git revert and Flux reconciliation. For cluster recovery, rebuild K3s host state with Ansible first, then restore Flux bootstrap and allow this directory to reconcile applications.
