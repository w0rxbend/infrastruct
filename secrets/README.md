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

Do not add real secrets yet. `.sops.yaml` currently contains the dummy
`age1exampleexampleexampleexampleexampleexampleexampleexampleq4n5r3` recipient,
which is not an operator-controlled key. Replace every dummy recipient with real
age public recipients before encrypting anything that matters.

`make validate` includes `scripts/validate-sops-policy`, which blocks
non-example committed paths from containing SOPS-encrypted secret files or
plaintext-looking secret material while the dummy recipient remains. Example
paths may contain fake data, and ignored local test paths such as
`secrets/local/` remain available for workstation-only SOPS checks.

## Age Key Setup

Create an age identity outside the repository:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Export the public recipient from the generated identity:

```sh
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
export SOPS_AGE_RECIPIENTS="$(awk '/^# public key: / {print $4; exit}' "$SOPS_AGE_KEY_FILE")"
printf '%s\n' "$SOPS_AGE_RECIPIENTS"
```

Copy only the public recipient into `.sops.yaml`. Do not commit `keys.txt` or
any private key material.

## Non-Production Encrypted-Secret Workflow

Use this workflow only for local test secrets until real recipients and real
secret file locations are reviewed. The paths below align with `.gitignore`:
age identities stay outside the repository, local test files stay under
`secrets/local/`, and decrypted outputs stay under `secrets/decrypted/`.

After exporting `SOPS_AGE_KEY_FILE` and `SOPS_AGE_RECIPIENTS`, replace every
documented dummy recipient in `.sops.yaml` with the operator-controlled public
recipient:

```sh
perl -0pi -e 's/age1exampleexampleexampleexampleexampleexampleexampleexampleq4n5r3/$ENV{SOPS_AGE_RECIPIENTS}/g' .sops.yaml
```

Prove the local SOPS workflow before adding any real encrypted secret material:

```sh
scripts/prove-sops-workflow
```

Create a fake ignored local test secret:

```sh
mkdir -p secrets/local
cat > secrets/local/test-secret.sops.yaml <<'EOF'
password: replace-before-use
token: replace-before-use
EOF
```

Encrypt the test secret with the repository `.sops.yaml` policy:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
SOPS_AGE_RECIPIENTS="$SOPS_AGE_RECIPIENTS" \
  sops --encrypt --in-place secrets/local/test-secret.sops.yaml
```

Edit the encrypted test secret:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
  sops secrets/local/test-secret.sops.yaml
```

Decrypt it only to an ignored local output path:

```sh
mkdir -p secrets/decrypted
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
  sops --decrypt secrets/local/test-secret.sops.yaml > secrets/decrypted/test-secret.yaml
```

Remove decrypted output as soon as it is no longer needed:

```sh
rm -f secrets/decrypted/test-secret.yaml
```

Rotate recipients by adding or replacing recipients in `.sops.yaml`, then
updating encrypted files while an existing private key is still available:

```sh
age-keygen -o ~/.config/sops/age/replacement-keys.txt
chmod 600 ~/.config/sops/age/replacement-keys.txt
export NEW_SOPS_AGE_RECIPIENT="$(awk '/^# public key: / {print $4; exit}' ~/.config/sops/age/replacement-keys.txt)"
printf '%s\n' "$NEW_SOPS_AGE_RECIPIENT"
# Edit .sops.yaml to add or replace recipients with $NEW_SOPS_AGE_RECIPIENT.
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
  sops updatekeys -y secrets/local/test-secret.sops.yaml
```

After replacement recipients are verified, run the proof again with a surviving
identity:

```sh
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/replacement-keys.txt"
export SOPS_AGE_RECIPIENTS="$NEW_SOPS_AGE_RECIPIENT"
scripts/prove-sops-workflow
```

Store private keys in an operator-controlled password manager or offline backup
and keep all `keys.txt` files out of Git.

If the local identity is lost but another trusted operator still has a working
identity, generate a new identity, add its public recipient to `.sops.yaml`,
and have that operator re-encrypt affected files:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/recovered-keys.txt
chmod 600 ~/.config/sops/age/recovered-keys.txt
export RECOVERY_SOPS_AGE_RECIPIENT="$(awk '/^# public key: / {print $4; exit}' ~/.config/sops/age/recovered-keys.txt)"
printf '%s\n' "$RECOVERY_SOPS_AGE_RECIPIENT"
# Add $RECOVERY_SOPS_AGE_RECIPIENT to .sops.yaml.
SOPS_AGE_KEY_FILE=/path/to/surviving/operator/keys.txt \
  sops updatekeys -y secrets/local/test-secret.sops.yaml
```

If every private identity for an encrypted file is lost, that encrypted content
cannot be decrypted. Generate new secrets at the source system, encrypt them to
new recipients, and rotate every consumer that used the lost values.

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
