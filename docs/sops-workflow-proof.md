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

Status: reproduced.

The reproduced status means the current reviewer independently reran the
required non-production SOPS workflow gates on 2026-06-22 from workstation
`ubuntu`, using the supported validation runner image with the operator private
age identity mounted read-only from outside the repository. The proof used fake
test values only. No private age identity contents, decrypted secret values, or
recovery backup material were recorded in this file.

Allowed status values:

- `reproduced`: a reviewer has rerun the proof through the documented command
  shape in a supported environment. This is required before real encrypted
  non-example secrets may be committed.
- `operator-provided`: an operator has supplied a non-secret pass record, but
  the current review has not reproduced it. This does not allow real encrypted
  non-example secrets.
- `not-yet-reproduced`: no accepted pass record exists in the current review.
  This does not allow real encrypted non-example secrets.

Validator policy:

- In `real-fleet` mode with a non-dummy public age recipient configured in
  `.sops.yaml`, `scripts/validate-promotion-evidence` treats
  `operator-provided` and `not-yet-reproduced` as informational only while no
  real encrypted non-example secret files are present.
- Any repository-owned non-example file with SOPS metadata is treated as real
  encrypted secret material, even if the file path does not match an existing
  `.sops.yaml` creation rule.
- If any real encrypted non-example SOPS file is present, the same validator
  requires `Status: reproduced`; `operator-provided` and
  `not-yet-reproduced` fail.
- Every detected real encrypted non-example SOPS file must also be covered by
  an intended `.sops.yaml` creation rule. A file with SOPS metadata outside
  policy coverage is still real encrypted secret material and must be reported
  as missing policy coverage.
- This proof record is evidence documentation only. The validator checks the
  status, command shape, and external read-only identity mount language; it
  does not decrypt files or prove the cryptographic command was actually rerun.

Required evidence gates:

- Encrypt/decrypt round trip using `scripts/prove-sops-workflow`.
- Interactive edit using `sops edit` or `sops <file>` against a non-production
  encrypted test secret.
- Recipient rotation using `sops updatekeys`.
- Recovery using the documented private identity backup process.

Each gate has its own status field. Allowed gate status values are:

- `reproduced`: a reviewer has rerun this gate through the documented command
  shape and reviewed the result.
- `operator-provided`: an operator has supplied a non-secret result for this
  gate, but the current review has not independently reproduced it.
- `not-yet-reproduced`: no accepted non-secret result exists for this gate.

Repository recipient source: `.sops.yaml` creation rules. The current public
age recipient is:

```text
age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d
```

Validation runner: image tag `infrastruct-validate:local`, built from the
committed `Containerfile`; observed image id
`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`, created
`2026-06-21 16:35:02.910940398 +0000 UTC`.

Container engine: Podman 5.7.0. Docker-compatible commands on this workstation
are serviced by Podman.

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

## Evidence Gate 1: Encrypt/Decrypt Round Trip

Status: reproduced

Allowed status values: `reproduced`, `operator-provided`,
`not-yet-reproduced`.

Command date: 2026-06-22.

Runner image or workstation: workstation `ubuntu`, Podman 5.7.0,
`infrastruct-validate:local`
`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`.
Observed runner tools: SOPS 3.11.0 and age 1.2.1.

Command shape:

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

Public recipient:
`age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d`

Redacted external identity mount path: host
`$HOME/.config/sops/age/keys.txt` mounted as container
`/agekeys/keys.txt` through `$HOME/.config/sops/age:/agekeys:ro`. Private
identity contents are `<redacted private age identity>` and must stay outside
the repository.

Result: pass. `scripts/prove-sops-workflow` exited 0 and printed:
`SOPS readiness proof passed. Temporary proof files were created outside tracked secret paths and will be removed on exit.`

## Evidence Gate 2: `sops edit`

Status: reproduced

Allowed status values: `reproduced`, `operator-provided`,
`not-yet-reproduced`.

Command date: 2026-06-22.

Runner image or workstation: workstation `ubuntu`, Podman 5.7.0,
`infrastruct-validate:local`
`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`.
Observed runner tools: SOPS 3.11.0 and age 1.2.1.

Command shape:

```sh
podman run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -v "$PWD:/workspace:rw" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  sh -lc 'create ignored secrets/local/test-secret.sops.yaml, encrypt it, run EDITOR=/tmp/sops-editor.sh sops edit, decrypt to an ignored temporary output, verify fake edited values, remove decrypted output'
```

Public recipient:
`age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d`, or the
operator-controlled public recipient exported from the mounted identity if the
policy recipient changes.

Redacted external identity mount path: expected host path
`$HOME/.config/sops/age/keys.txt`, or a reviewer-recorded equivalent outside
Git, with private contents recorded only as `<redacted private age identity>`.

Result: pass. `sops edit` exited 0 using a temporary noninteractive editor
script inside the container. Decryption verified only fake non-production
values, and the temporary decrypted output was removed. The ignored
`secrets/local/test-secret.sops.yaml` sample was removed after the proof.

## Evidence Gate 3: Recipient Rotation With `sops updatekeys`

Status: reproduced

Allowed status values: `reproduced`, `operator-provided`,
`not-yet-reproduced`.

Command date: 2026-06-22.

Runner image or workstation: workstation `ubuntu`, Podman 5.7.0,
`infrastruct-validate:local`
`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`.
Observed runner tools: SOPS 3.11.0 and age 1.2.1.

Command shape:

```sh
podman run --rm --network none \
  -e HOME=/tmp \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -v "$PWD:/workspace:rw" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -w /workspace \
  infrastruct-validate:local \
  sh -lc 'generate /tmp/replacement-keys.txt, add its public recipient to a temporary /tmp/sops-rotation.yaml policy copy, run sops --config /tmp/sops-rotation.yaml updatekeys -y secrets/local/test-secret.sops.yaml, decrypt with /tmp/replacement-keys.txt, verify fake values, remove decrypted output'
```

Public recipient: original recipient
`age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d`; replacement
recipient
`age1fw5fsd77euypnh9pn7l2w3hsherwclnhwz330tfep794petvhczshah78l`.

Redacted external identity mount path: expected original host path
`$HOME/.config/sops/age/keys.txt`, mounted as `/agekeys/keys.txt` through
`$HOME/.config/sops/age:/agekeys:ro`. The replacement private identity existed
only as `/tmp/replacement-keys.txt` inside the disposable container. Private
identity contents are `<redacted private age identity>`.

Result: pass. `sops updatekeys -y` exited 0, the generated replacement identity
decrypted the non-production sample, and temporary decrypted output was removed.
The tracked `.sops.yaml` was not changed; rotation used a temporary policy copy.

## Evidence Gate 4: Private Identity Backup Recovery

Status: reproduced

Allowed status values: `reproduced`, `operator-provided`,
`not-yet-reproduced`.

Command date: 2026-06-22.

Runner image or workstation: workstation `ubuntu`, Podman 5.7.0,
`infrastruct-validate:local`
`70c083ade1399bda1aea0e15bd008c902a186a677160766b7e56a6acbf2c776a`.
Observed runner tools: SOPS 3.11.0 and age 1.2.1.

Command shape:

```sh
install -m 0400 "$HOME/.config/sops/age/keys.txt" "/run/user/$UID/sops-recovery/keys.txt"
podman run --rm --network none \
  -e HOME=/tmp \
  -e RECOVERY_SOPS_AGE_KEY_FILE=/recovery/keys.txt \
  -e SOPS_AGE_KEY_FILE=/recovery/keys.txt \
  -v "$PWD:/workspace:rw" \
  -v "/run/user/$UID/sops-recovery:/recovery:ro" \
  -w /workspace \
  infrastruct-validate:local \
  sh -lc 'sops --decrypt secrets/local/test-secret.sops.yaml >/tmp/sops-recovery-proof.yaml, verify fake values, remove decrypted output'
rm -f "/run/user/$UID/sops-recovery/keys.txt"
```

Public recipient: restored backup recipient
`age1k6na6pw9j55xpl7yc5x9l7twgmgfzcpjy5mmqzxav8w9afv2cqaskjsk4d`.

Redacted external identity mount path: restored backup path
`/run/user/$UID/sops-recovery/keys.txt`, mounted read-only as
`/recovery/keys.txt`. Private identity contents are
`<redacted private age identity>`. The temporary restored copy was removed after
the proof.

Result: pass. The restored identity decrypted only the non-production test
secret, temporary decrypted output was removed, and the temporary restored
identity copy was removed from `/run/user/$UID/sops-recovery/`.

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

## Procedure Details: `sops edit`

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

## Procedure Details: Recipient Rotation

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

## Procedure Details: Identity Backup Recovery

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
