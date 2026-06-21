# SOPS Workflow Proof

This note is the auditable, non-secret proof record for the repository SOPS
workflow. It documents how to reproduce `scripts/prove-sops-workflow` in the
supported validation runner with the operator private age identity mounted
read-only from outside the repository.

Do not paste private age identity contents, decrypted secret values, editor
buffers, or recovery backup material into this file. Redact private material as
`<redacted private age identity>` and record only public recipients, command
shape, image tag, and pass/fail evidence.

## Current Proof Record

Status: reproduced by operator-provided evidence on 2026-06-22.

Repository recipient source: `.sops.yaml` creation rules. The current public
age recipient is:

```text
age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d
```

Validation runner: image tag `infrastruct-validate:local`, built from the
committed `Containerfile`.

Relevant tool pins from `Containerfile`:

```text
SOPS_VERSION=3.11.0
AGE_VERSION=1.2.1
```

Private identity handling:

- Source path on the operator workstation:
  `$HOME/.config/sops/age/keys.txt`
- Container mount:
  `$HOME/.config/sops/age:/agekeys:ro`
- Container environment:
  `SOPS_AGE_KEY_FILE=/agekeys/keys.txt`
- Redaction rule:
  record only the path and mount mode; never record the file contents.

Observed command:

```sh
docker run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -e SOPS_AGE_RECIPIENTS=age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d \
  -v "$PWD:/workspace:ro" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  scripts/prove-sops-workflow
```

Expected pass evidence:

```text
SOPS readiness proof passed. Temporary proof files were created outside tracked secret paths and will be removed on exit.
```

Expected failure evidence includes a nonzero exit and one of these diagnostic
classes:

- Missing tool: `Required command 'sops' is not installed or is not on PATH.`
- Missing identity: `No readable age private identity found.`
- Policy drift: `None of the SOPS_AGE_RECIPIENTS values are present in an applicable .sops.yaml creation rule.`
- Dummy recipient: `.sops.yaml still contains the documented dummy age recipient.`
- Rotation failure: `SOPS updatekeys failed on the temporary encrypted proof copy.`

## Reproduction Procedure

Build or refresh the supported runner from the committed `Containerfile`:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:local \
  scripts/validate-runner --versions
```

For a no-cache toolchain proof, use:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:local \
  scripts/validate-runner --proof
```

Then run the SOPS workflow proof with the operator private age identity mounted
read-only. This command intentionally does not use `scripts/validate-runner`
directly because the identity mount must stay explicit and outside the normal
repository validation container:

```sh
docker run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -e SOPS_AGE_RECIPIENTS="$(awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/keys.txt")" \
  -v "$PWD:/workspace:ro" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  scripts/prove-sops-workflow
```

Required environment variables:

- `HOME=/tmp`: keeps SOPS and age runtime state out of the mounted repository.
- `SOPS_AGE_KEY_FILE=/agekeys/keys.txt`: points to the read-only mounted
  private identity inside the container.
- `SOPS_AGE_RECIPIENTS`: must be the public recipient exported from the mounted
  identity and present in an applicable `.sops.yaml` creation rule.

The public recipient value must come from the operator age identity comment:

```sh
awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/keys.txt"
```

If using Podman, keep the same mount and environment shape:

```sh
podman run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -e SOPS_AGE_RECIPIENTS="$(awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/keys.txt")" \
  -v "$PWD:/workspace:ro" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  scripts/prove-sops-workflow
```

Record only:

- Date and operator initials or review identifier.
- Container engine and image tag.
- Whether the image was rebuilt from `Containerfile`.
- Public recipient value.
- Exact command shape.
- Pass output or failure diagnostic class.

Do not record:

- Contents of `keys.txt`.
- Decrypted proof files or editor buffers.
- Temporary directory names containing local workstation details unless needed
  for debugging a failed run.
- Real production secret values.

## Follow-Up Proof: `sops edit`

Use only an ignored non-production test secret under `secrets/local/`.

```sh
mkdir -p secrets/local
printf 'password: replace-before-use\ntoken: replace-before-use\n' \
  > secrets/local/test-secret.sops.yaml

SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
SOPS_AGE_RECIPIENTS="$(awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/keys.txt")" \
  sops --encrypt --in-place secrets/local/test-secret.sops.yaml

SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
  sops secrets/local/test-secret.sops.yaml
```

In the editor, change only fake values such as `replace-before-use` to another
non-production placeholder. Do not paste real credentials.

Pass evidence:

- `sops` opens the encrypted file for editing.
- Saving the editor exits with status 0.
- `sops --decrypt secrets/local/test-secret.sops.yaml` shows only fake
  non-production values.
- `git status --short secrets/local/test-secret.sops.yaml` shows nothing
  tracked because `secrets/local/` is ignored.

Failure evidence:

- `sops` cannot decrypt the file with the mounted identity.
- The editor writes plaintext into a tracked path.
- Any real credential appears in the test file or terminal transcript.

## Follow-Up Proof: Recipient Rotation

Use the same non-production `secrets/local/test-secret.sops.yaml` file. Keep the
old working private identity available until `sops updatekeys` completes.

```sh
age-keygen -o "$HOME/.config/sops/age/replacement-keys.txt"
chmod 600 "$HOME/.config/sops/age/replacement-keys.txt"
export NEW_SOPS_AGE_RECIPIENT="$(awk '/^# public key: / {print $4; exit}' "$HOME/.config/sops/age/replacement-keys.txt")"
printf '%s\n' "$NEW_SOPS_AGE_RECIPIENT"
```

Add `NEW_SOPS_AGE_RECIPIENT` to the applicable `.sops.yaml` creation rule, then
update the non-production encrypted test file while using the original working
identity:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
  sops updatekeys -y secrets/local/test-secret.sops.yaml
```

Prove the replacement identity can decrypt the test file:

```sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/replacement-keys.txt" \
  sops --decrypt secrets/local/test-secret.sops.yaml >/tmp/sops-rotation-proof.yaml
rm -f /tmp/sops-rotation-proof.yaml
```

Pass evidence:

- `sops updatekeys -y secrets/local/test-secret.sops.yaml` exits 0.
- Decrypting with the replacement identity exits 0.
- Decrypted output is removed immediately and contains only fake
  non-production values if inspected.

Failure evidence:

- `sops updatekeys` exits nonzero.
- Replacement identity cannot decrypt.
- `.sops.yaml` no longer contains the recipient needed by current encrypted
  files.

## Follow-Up Proof: Identity Backup Recovery

This proof verifies that an operator private identity backup can recover access
to a non-production test secret. It must not use production encrypted files.

Prerequisites:

- `secrets/local/test-secret.sops.yaml` exists and contains only fake values.
- The private identity backup is restored outside the repository, for example
  to `/run/user/$UID/sops-recovery/keys.txt` or another operator-controlled
  temporary path.
- The restored path is mounted or referenced read-only where possible.

Recovery proof:

```sh
export RECOVERY_SOPS_AGE_KEY_FILE="/run/user/$UID/sops-recovery/keys.txt"
export RECOVERY_SOPS_AGE_RECIPIENT="$(awk '/^# public key: / {print $4; exit}' "$RECOVERY_SOPS_AGE_KEY_FILE")"

SOPS_AGE_KEY_FILE="$RECOVERY_SOPS_AGE_KEY_FILE" \
  sops --decrypt secrets/local/test-secret.sops.yaml >/tmp/sops-recovery-proof.yaml
rm -f /tmp/sops-recovery-proof.yaml
```

If recovering to a new replacement identity, add the replacement public
recipient to `.sops.yaml` while a surviving identity is available, then run:

```sh
SOPS_AGE_KEY_FILE="$RECOVERY_SOPS_AGE_KEY_FILE" \
  sops updatekeys -y secrets/local/test-secret.sops.yaml
```

Pass evidence:

- The restored identity decrypts only the non-production test secret.
- Any temporary decrypted output is removed immediately.
- The proof record includes the restored public recipient, not private key
  material.

Failure evidence:

- The backup identity cannot decrypt the test secret.
- The backup file contents are exposed in logs, shell history, or Git.
- The proof accidentally uses production encrypted content.

If every private identity for an encrypted file is lost, SOPS recovery is not
possible for that file. Generate new secrets at their source systems, encrypt
them to new recipients, and rotate every consumer that used the lost values.
