# SOPS Workflow Proof

Status: reproduced

## Evidence Gate 1: Encrypt/Decrypt Round Trip

Status: reproduced

Command shape: `scripts/prove-sops-workflow`
Runner image or workstation: `infrastruct-validate:local`
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: 2026-06-22
Result: reproduced pass.

## Evidence Gate 2: `sops edit`

Status: reproduced

Command shape: `sops secrets/local/test-secret.sops.yaml`
Runner image or workstation: `infrastruct-validate:local`
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: 2026-06-22
Result: reproduced pass.

## Evidence Gate 3: Recipient Rotation With `sops updatekeys`

Status: reproduced

Command shape: `sops updatekeys -y secrets/local/test-secret.sops.yaml`
Runner image or workstation: `infrastruct-validate:local`
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: 2026-06-22
Result: reproduced pass.

## Evidence Gate 4: Private Identity Backup Recovery

Status: reproduced

Command shape: `sops --decrypt secrets/local/test-secret.sops.yaml`
Runner image or workstation: `infrastruct-validate:local`
Public recipient: `age1example`
Redacted external identity mount path: `/run/user/$UID/sops-recovery/keys.txt`
Date: 2026-06-22
Result: reproduced pass.
