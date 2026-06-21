# Real-Fleet Promotion Checklist

Use this checklist when moving the repository from discovery mode to the real
20-machine desired state. Complete the steps in order. Do not treat later
validation as meaningful until the earlier source-of-truth inputs are complete.

Before real host facts, active public routes, or encrypted non-example secrets
are promoted, run the cheap repository-local rehearsal against fake
production-shaped data:

```sh
scripts/test-real-fleet-promotion-rehearsal
```

That local rehearsal is the fast dry-run gate for the
discovery-to-real-fleet transition. It does not require local
`ansible-playbook`, and it does not prove Ansible syntax or semantic role
execution. It proves the currently executable repository-local boundary
behavior without using real host facts:

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
- The fake-tool SOPS workflow contract rejects a recipient mentioned only in
  comments or unrelated prose; the contract must find exported recipients in
  actual `.sops.yaml` `creation_rules` recipient fields.

Run the runner-backed promotion rehearsal for the supported proof path that
also exercises the Ansible gates inside the pinned validation runner:

```sh
make test-real-fleet-promotion-rehearsal-runner
```

That runner-backed path uses disposable fixture repositories and must also
prove:

- `scripts/validate-ansible-syntax` passes against the complete fake
  real-fleet fixture.
- Syntax-check failures and diagnostics from `ansible-playbook` are propagated.
- The semantic `inventory_assertions` fixture harness executes instead of
  reporting skipped semantic Ansible fixtures.
- The `inventory_assertions` role accepts the promoted fake real-fleet
  inventory when executed by Ansible.

Real host facts, active public routes, and encrypted non-example secrets remain
blocked until the local rehearsal and the runner-backed promotion rehearsal
pass. SOPS fake-tool contract coverage is not real cryptographic readiness:
after the dummy recipient is replaced with real operator-controlled recipients,
`scripts/prove-sops-workflow` must still pass with the real local SOPS and age
toolchain before any non-example encrypted secret is committed.

Operational automation remains frozen while promotion is incomplete. Do not
start mutating baseline, Docker, Swarm, K3s, or Flux automation until all of
these are true in the same promotion branch:

- The production inventory contains exactly the 20 real hosts and passes the
  repository inventory contracts.
- The SOPS policy uses real operator-controlled recipients and
  `scripts/prove-sops-workflow` has passed with the matching private identity.
- Public exposure truth is complete: every active route is aligned across
  inventory, `docs/services.md`, and `docs/public-exposure.md`, or active
  exposure is explicitly denied.
- The full validation runner has passed.

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
   placement for the hosts Ansible targets. Semantic
   `inventory_assertions` behavior is authoritative only when executed by
   Ansible inside the pinned validation runner, such as through
   `make test-inventory-assertions-runner`,
   `make test-real-fleet-promotion-rehearsal-runner`, or
   `make validate-runner`.

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
   and runner-backed `inventory_assertions` execution must reject it.

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
   ambiguity. Draft route identifiers are stable promotion handles and must be
   globally unique across active, planned, and non-production public exposure
   records, even when the draft exists in only one source.

   If discovery finds no active production public exposure, keep the production
   inventory public-exposure group empty and state that no active production
   routes are declared in both `docs/public-exposure.md` and `docs/services.md`.
   Planned and non-production drafts are not substitutes for the active
   production decision.

6. Run focused pre-promotion checks before changing repository mode.

   The production inventory must reject placeholder values, the real SOPS
   workflow proof must have succeeded after real recipients were configured,
   and public exposure records must be complete before `repo-mode.yml` is
   switched to real-fleet mode. Use the focused harnesses for the promotion
   boundary being changed:

   ```sh
   scripts/test-inventory-validator
   make test-inventory-assertions-runner
   scripts/test-sops-workflow-proof
   scripts/test-public-exposure-validator
   scripts/test-real-fleet-promotion-rehearsal
   scripts/validate-ci-path-filters
   scripts/test-ci-path-filter-validator
   make test-real-fleet-promotion-rehearsal-runner
   ```

   `scripts/test-sops-workflow-proof` is fake-tool contract coverage for the
   proof script. It does not replace the real readiness command in step 2:
   after `.sops.yaml` contains only operator-controlled recipients, run
   `scripts/prove-sops-workflow` with the real SOPS and age tools and the
   matching private identity.

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

   This cheap gate includes `scripts/test-real-fleet-promotion-rehearsal`, but
   it may skip semantic Ansible fixture behavior on a workstation without
   `ansible-playbook`; it must not be treated as syntax or semantic
   `inventory_assertions` proof.

   Run the focused runner-backed promotion proof:

   ```sh
   make test-real-fleet-promotion-rehearsal-runner
   ```

   Confirm focused CI path filters still reference existing concrete files
   while allowing globbed paths:

   ```sh
   scripts/validate-ci-path-filters
   scripts/test-ci-path-filter-validator
   ```

   Confirm public exposure route-ID uniqueness and source alignment:

   ```sh
   scripts/validate-public-exposure-docs
   scripts/test-public-exposure-validator
   ```

   Confirm malformed assertion fixtures fail at the repository fixture boundary
   before role execution, then prove semantic assertion behavior in the pinned
   runner:

   ```sh
   scripts/test-inventory-assertions
   make test-inventory-assertions-runner
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
