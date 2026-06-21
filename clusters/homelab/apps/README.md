# Homelab Apps

## Ownership

This directory will contain application workloads reconciled by Flux. Each app should define its namespace, Kustomization or HelmRelease, service routing, data paths, secret source, backup policy, and maintenance notes.

## Reconciliation

Planned commands:

```sh
flux get kustomizations
flux reconcile kustomization <app-name>
kubectl -n <namespace> get all
```

Flux is the owner of application desired state. Manual `kubectl` changes are temporary recovery actions only and must be converted back into Git commits.

## Secrets

App secrets must be SOPS-encrypted and referenced by the app documentation. Do not commit plaintext Kubernetes Secret manifests.
