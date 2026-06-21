# SOPS Workflow Proof

Status: not yet reproduced in this fixture environment.

The private age identity material is mounted read-only from outside the
repository.

```sh
podman run --rm \
  -v "$PWD:/workspace:ro" \
  -v "$HOME/.config/sops/age:/agekeys:ro" \
  -e SOPS_AGE_KEY_FILE=/agekeys/keys.txt \
  -w /workspace \
  infrastruct-validate:local \
  scripts/prove-sops-workflow
```
