# SOPS Workflow Proof

Status: operator-provided

## Evidence Gate 1: Encrypt/Decrypt Round Trip

Status: operator-provided

Command shape: `scripts/prove-sops-workflow`
Runner image or workstation: `infrastruct-validate:local`
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: operator-provided
Result: operator-provided pass.

## Evidence Gate 2: `sops edit`

Status: not-yet-reproduced

Command shape: `sops secrets/local/test-secret.sops.yaml`
Runner image or workstation: not recorded
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: not recorded
Result: not reproduced.

## Evidence Gate 3: Recipient Rotation With `sops updatekeys`

Status: not-yet-reproduced

Command shape: `sops updatekeys -y secrets/local/test-secret.sops.yaml`
Runner image or workstation: not recorded
Public recipient: `age1example`
Redacted external identity mount path: `/agekeys/keys.txt`
Date: not recorded
Result: not reproduced.

## Evidence Gate 4: Private Identity Backup Recovery

Status: not-yet-reproduced

Command shape: `sops --decrypt secrets/local/test-secret.sops.yaml`
Runner image or workstation: not recorded
Public recipient: `age1example`
Redacted external identity mount path: `/run/user/$UID/sops-recovery/keys.txt`
Date: not recorded
Result: not reproduced.
