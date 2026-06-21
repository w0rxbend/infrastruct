# Flux System

## Ownership

This directory is reserved for Flux bootstrap and synchronization resources for the homelab K3s cluster.

Owner tool: Flux CD.

## Reconciliation

Flux should watch this repository and reconcile the `clusters/homelab/` tree. Planned commands:

```sh
flux get sources git
flux get kustomizations
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

## Manual Edit Boundary

Do not make lasting changes to Flux resources with `kubectl edit`, `kubectl apply`, or `flux create` unless the generated desired state is committed here. In-cluster Flux state is not the source of truth; Git is.

## Recovery

If Flux is lost, bootstrap it back to this repository and reconcile from Git. If emergency changes are made directly in the cluster, preserve only the intended final state by committing it here.
