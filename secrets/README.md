# Secrets

## Ownership

This area owns repository-wide secret handling policy, encryption expectations, key management notes, rotation procedures, and recovery expectations.

Owner tools: SOPS + age.

## Applying Changes

Secrets must be encrypted before they enter Git. Future encrypted material may support:

- Ansible inventory vars and host policy
- Kubernetes manifests reconciled by Flux
- Docker Compose environment files
- Docker Swarm stack inputs

Plaintext examples may only be fake, non-sensitive values clearly marked as examples.

## Age Key Setup

Create an age key outside the repository:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Copy only the public recipient into `.sops.yaml`. Do not commit `keys.txt` or any private key material.

## Encryption And Editing

Use SOPS for all secret edits:

```sh
sops --encrypt --in-place secrets/example.sops.yaml
sops secrets/example.sops.yaml
sops --decrypt secrets/example.sops.yaml
```

For environment files, use a SOPS-managed file name such as `service.sops.env` and verify the committed content is encrypted before staging it.

## Secret Placement By Runtime

- Ansible: encrypted group or host variables may live under `ansible/inventories/homelab/` when tied to inventory, or under `secrets/ansible/` when shared.
- Kubernetes: encrypted manifests may live beside the consuming app under `clusters/homelab/apps/` or `clusters/homelab/infrastructure/`; shared cluster secrets may live under `secrets/kubernetes/`.
- Docker Compose: encrypted `*.sops.env` or encrypted YAML files may live beside the service under `docker/compose/<service-name>/` or under `secrets/compose/`.
- Docker Swarm: encrypted stack inputs may live beside `swarm/stacks/<stack-name>.yml` or under `secrets/swarm/`; Docker secret creation must be documented by the stack.

Every consuming service, playbook, or manifest must document its secret source and restart or reconciliation requirement after rotation.

## Verification

Planned verification commands include:

```sh
sops --decrypt <encrypted-file>
sops --encrypt --in-place <file>
rg --hidden --glob '!*.sops.*' --glob '!*.enc.*' 'password|token|secret|api_key|private key'
```

Verification should confirm that committed files contain encrypted values and that operators with the correct age key can decrypt them.

## Manual Edit Boundary

Do not commit plaintext tokens, passwords, private keys, API keys, session secrets, database credentials, or production-like secret values. Do not store age private keys in this repository.

## Secret Placement

Repository policy lives here. Encrypted secret files may live here or beside the runtime configuration they support, but every consuming service or playbook must document the secret source.

## Rollback And Recovery

Secret rollback uses Git history only for encrypted content. Recovery depends on age private keys stored outside the repository. Key rotation must re-encrypt affected files and document which consumers need restart or reconciliation.

## Rotation

Rotation requires:

1. Generate or obtain the replacement secret outside Git.
2. Edit the encrypted file with `sops <file>`.
3. Apply the consuming runtime change through Ansible, Flux, Compose, or Swarm.
4. Restart or reconcile consumers that do not reload secrets automatically.
5. Record any service-specific recovery notes in the service README.

## Recovery Expectations

Store age private keys in an operator-controlled password manager or offline backup, not in this repository. If a private key is lost, add a new recipient to `.sops.yaml`, re-encrypt all affected files while an old key is still available, and remove access for retired recipients.
