# Real-Fleet Promotion Checklist

Use this checklist when moving the repository from discovery mode to the real
20-machine desired state. Complete the steps in order. Do not treat later
validation as meaningful until the earlier source-of-truth inputs are complete.

Before real host facts, active public routes, or encrypted non-example secrets
are promoted, run the repository-local rehearsal against fake
production-shaped data:

```sh
scripts/test-real-fleet-promotion-rehearsal
```

That rehearsal is the dry-run gate for the discovery-to-real-fleet transition.
It must prove the expected boundary behavior without using real host facts:

- Discovery mode with an empty production inventory still passes the current
  discovery contracts.
- Real-fleet mode with an incomplete fake inventory fails the expected host
  count or required-host checks.
- Real-fleet mode with a complete small fake inventory passes inventory
  validation.
- An active public exposure record introduced only in inventory fails until the
  matching records exist in `docs/services.md` and `docs/public-exposure.md`.
- The same active public exposure passes only when inventory, service docs, and
  public exposure docs agree.
- A SOPS recipient mentioned only in comments or unrelated prose does not
  satisfy readiness; the proof must find exported recipients in actual
  `.sops.yaml` `creation_rules` recipient fields.

Real host facts, active public routes, and encrypted non-example secrets remain
blocked until this rehearsal passes and SOPS recipients are structurally
verified by the workflow proof.

## Promotion Order

1. Complete `docs/fleet-discovery-intake.md` for every real host.

   Record hostname, management IP, architecture, hardware model, storage type,
   runtime roles, reliability notes, placement notes, and public exposure
   metadata. Do not record passwords, private keys, API tokens, recovery
   phrases, or plaintext service credentials in the intake.

2. Replace the dummy SOPS age recipient in `.sops.yaml`.

   Use only real operator-controlled age recipients. After the policy is
   updated, make sure the matching private identity is available locally,
   export the matching public recipient, and prove the workflow:

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

   Production host facts must also be complete real values, not intake
   placeholders. Do not promote `unknown`, `tbd`, `todo`, `pending`, `unset`,
   or similar placeholder strings into required host fields, runtime role
   values, storage or architecture fields, hardware model, reliability notes,
   placement notes, or active public exposure metadata. The intake worksheet may
   contain placeholder text while discovery is incomplete; production inventory
   and direct `inventory_assertions` execution must reject it.

5. Add complete public exposure records or explicitly deny active exposure.

   Every promoted active production public route must be represented in all
   required sources:

   - `ansible/inventories/homelab/hosts.yml`
   - `docs/public-exposure.md`
   - `docs/services.md`

   Active route records must align across those sources for route identifier,
   runtime, proxy owner, public host or port, protocol, target host or cluster,
   target, firewall intent, secret dependency, and review notes.

   Planned and non-production draft records may keep `Public host or port:
   none`, but they must still keep the complete public exposure field structure.
   Each draft needs a stable non-placeholder route identifier and a meaningful
   target host or cluster so it can be reviewed and later promoted without
   ambiguity.

   If discovery finds no active production public exposure, keep the production
   inventory public-exposure group empty and state that no active production
   routes are declared in both `docs/public-exposure.md` and `docs/services.md`.
   Planned and non-production drafts are not substitutes for the active
   production decision.

6. Run focused pre-promotion checks before changing repository mode.

   The production inventory must reject placeholder values, the SOPS workflow
   proof must have succeeded after real recipients were configured, and public
   exposure records must be complete before `repo-mode.yml` is switched to
   real-fleet mode. Use the focused harnesses for the promotion boundary being
   changed:

   ```sh
   scripts/test-inventory-validator
   make test-inventory-assertions-runner
   scripts/test-sops-workflow-proof
   scripts/test-public-exposure-validator
   scripts/test-real-fleet-promotion-rehearsal
   ```

7. Switch `repo-mode.yml` to real-fleet mode with the exact host count.

   The committed file must declare:

   ```yaml
   ---
   mode: real-fleet
   expected_host_count: 20
   ```

   Do not use real-fleet mode for a partial inventory.

8. Run the supported validation gates.

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
