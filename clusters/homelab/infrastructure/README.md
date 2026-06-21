# Homelab Cluster Infrastructure

## Ownership

This directory will contain cluster infrastructure managed by Flux, such as ingress controllers, certificate managers, storage classes, monitoring components, and shared controllers.

Infrastructure here is cluster-level Kubernetes state. Host packages, K3s installation, node labels, firewall policy, and reboots belong in Ansible.

## Reconciliation

Planned commands:

```sh
flux get kustomizations
flux reconcile kustomization <infrastructure-name>
kubectl get pods --all-namespaces
```

Manual `kubectl` edits must not become the durable source of truth. Commit the desired infrastructure state here and let Flux reconcile it.

## Secrets

Shared infrastructure secrets must be SOPS-encrypted and documented with their consumers, rotation procedure, and recovery expectations.
