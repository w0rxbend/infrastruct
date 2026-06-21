# Real-Fleet Promotion Checklist

Use this checklist when moving the repository from discovery mode to the real
20-machine desired state. Complete the steps in order. Do not treat later
validation as meaningful until the earlier source-of-truth inputs are complete.

## Promotion Order

1. Complete `docs/fleet-discovery-intake.md` for every real host.

   Record hostname, management IP, architecture, hardware model, storage type,
   runtime roles, reliability notes, placement notes, and public exposure
   metadata. Do not record passwords, private keys, API tokens, recovery
   phrases, or plaintext service credentials in the intake.

2. Replace the dummy SOPS age recipient in `.sops.yaml`.

   Use only operator-controlled age recipients. After the policy is updated,
   export the matching public recipient and prove the workflow:

   ```sh
   export SOPS_AGE_RECIPIENTS='<operator-age-public-recipient>'
   scripts/prove-sops-workflow
   ```

   Do not commit real encrypted secret material as part of this readiness
   proof. The proof must pass SOPS encrypt, decrypt, and `updatekeys` against
   temporary non-production material before any real secret is added to the
   repository.

3. Treat the successful SOPS proof as the gate for non-example encrypted
   secrets.

   Do not commit any non-example encrypted secret until the dummy recipient has
   been replaced and `scripts/prove-sops-workflow` has succeeded with an
   operator-controlled recipient and matching private identity. If the proof
   fails at encrypt, decrypt, or `updatekeys`, stop secret promotion and fix the
   SOPS policy, recipient, or local identity before staging encrypted material.

4. Populate `ansible/inventories/homelab/hosts.yml` with all real hosts.

   Promote confirmed intake facts into the production inventory. Keep group
   membership aligned with
   `ansible/inventories/homelab/group_contract.yml`, including runtime role
   groups, architecture groups, storage groups, Raspberry Pi Zero placement,
   and public exposure membership.

   `scripts/validate-inventory` is the schema authority for
   `group_contract.yml` and the production inventory contract. It must accept
   the shared contract before direct Ansible role execution is treated as
   meaningful. The `inventory_assertions` role is a runtime preflight that
   consumes the validated contract and checks rendered host facts and group
   placement for the hosts Ansible targets.

   Production host facts must not use obvious placeholder management addresses
   or RFC 5737 documentation IPv4 ranges. Those management-address checks exist
   in both `scripts/validate-inventory` and the `inventory_assertions`
   preflight role, so they are enforced by repository-local validation and by
   direct baseline preflight execution.

5. Switch `repo-mode.yml` to real-fleet mode with the exact host count.

   The committed file must declare:

   ```yaml
   ---
   mode: real-fleet
   expected_host_count: 20
   ```

   Do not use real-fleet mode for a partial inventory.

6. Add or explicitly deny active public exposure records.

   If discovery finds active production public routes, represent every route in
   all required sources:

   - `ansible/inventories/homelab/hosts.yml`
   - `docs/public-exposure.md`
   - `docs/services.md`

   If discovery finds no active production public exposure, keep the production
   inventory public-exposure group empty and state that no active production
   routes are declared in both `docs/public-exposure.md` and `docs/services.md`.
   Planned and non-production drafts are not substitutes for the active
   production decision.

7. Run the supported validation gates.

   Start with the fast local contract gate:

   ```sh
   make validate-local-contracts
   ```

   Then run the complete gate on a supported workstation:

   ```sh
   make validate
   ```

   If the full workstation toolchain is not installed locally, use the pinned
   validation runner:

   ```sh
   make validate-runner
   ```

   For focused changes to inventory assertion behavior or the shared group
   contract, also run the relevant runner-backed target:

   ```sh
   make test-inventory-assertions-runner
   make test-inventory-contract-maps-runner
   ```

## Rollback

Return to discovery mode only before any real desired state has been trusted or
applied. A rollback is appropriate while the promotion branch is still
pre-operational, before the inventory has driven host changes, before public
routes have been applied, and before real encrypted secrets are relied on.

To roll back during that pre-operational window:

1. Remove real hosts from `ansible/inventories/homelab/hosts.yml` so the
   production inventory returns to the intentional empty discovery state.
2. Set `repo-mode.yml` back to:

   ```yaml
   ---
   mode: discovery
   expected_host_count: 0
   ```

3. Remove active production public exposure records or mark them as untrusted
   drafts before any route is applied.
4. Keep real SOPS recipients if they are operator-controlled; do not restore the
   dummy recipient as a rollback shortcut.
5. Run `make validate-local-contracts` before continuing discovery work.

After real desired state has been used to manage hosts, public routes, or
secrets, do not use discovery-mode rollback as an operational recovery path.
Instead, make an explicit Git change that removes or corrects the trusted
desired state and run the complete validation gate again.
