[learning] Documentation consistency validators must parse the authoritative record formats, not just search for route identifiers, or incomplete public exposure records can still pass.
[anti-pattern] Validator aliases that drift from documentation templates create false passes; every documented field name should have a negative fixture proving the parser sees it.
[learning] Route-id alignment is weaker than source-of-truth validation; public exposure checks need canonical field comparison to catch mismatched proxy, target, firewall, and secret metadata.
[pattern] Repository mode files should be validated with both the current happy path and transition fixtures, because the risky path is switching from discovery to real-fleet mode.
[learning] Required public-exposure fields that are only checked for presence still allow source drift; every operationally meaningful required field should be included in canonical comparison or explicitly documented as source-local.
[pattern] Validator fixture suites need one complete positive real-shape case plus targeted negative drift cases, otherwise empty-state validation can pass while real records remain under-tested.
[anti-pattern] Validating enum fields only after relevance filtering lets malformed non-public records bypass contracts; validate structural fields before deciding a record is out of scope.
[learning] Planned or inactive records need an explicit alignment policy; silently skipping them from active-route comparison can make draft documentation drift invisible.
[pattern] A pinned validation runner earns trust only when the full gate and version-report path both run successfully from the same image.
[learning] Fixing first-party lint configuration can expose dependency-level warnings; warning-clean gates need a policy for toolchain warnings as well as repository rule findings.
[pattern] Small disposable-repo fixture harnesses are effective for contract validators because they test risky mode transitions without mutating the production scaffold.
[anti-pattern] Source-local draft records that skip structural validation based on relevance fields can contradict documentation and let malformed planned state accumulate.
[pattern] Third-party warning filters should be narrow wrappers around one known warning shape so validation still surfaces real tool failures and rule warnings.
[learning] Synthetic discovery inventories can make syntax validation warning-clean, but they must be tested as mode-specific scaffolding rather than treated as evidence about real fleet group membership.
[pattern] Validation-runner rebuild proof is stronger when encoded as one reviewed command that builds without cache, reports versions, and runs the full gate.
[anti-pattern] Assertion-only Ansible roles lose practical safety if they inherit play-level privilege escalation; keep preflight checks non-privileged until mutation is required.
[learning] Syntax validator fixtures that use a fake tool can prove mode selection, but they still need a failure-propagation case before they prove the wrapper's behavior under real tool errors.
[anti-pattern] Fixture assertions that match unordered tool output as an exact ordered string create flaky gates; normalize diagnostics or check set membership instead.
[learning] Removing mirrored role logic from local tests reduces drift, but it shifts behavioral confidence to the tool-backed runner; harness output must make skipped semantic coverage obvious.
[anti-pattern] Contract convergence tests that rely on source-string probes can miss semantic drift; prefer shared data or structural parsing for duplicated validation rules.
[anti-pattern] Adding a shared contract file without updating disposable fixture repos breaks wrapper tests that run validators before their primary tool behavior.
[learning] Contract fields are real API only if every consumer honors them; otherwise metadata like host_var creates a false promise of configurability.
[anti-pattern] Duplicating the same contract value in a summary map and per-rule fields creates drift risk unless one is generated from or validated against the other.
[pattern] Prefer deleting redundant contract metadata over adding validators for duplicate fields when one existing field can remain the clear source of truth.
[anti-pattern] Readiness proof scripts that downgrade required substeps to warnings create false confidence; encrypt/decrypt, rotation, and recovery need separate hard pass/fail contracts when all are release criteria.
[anti-pattern] Fake-tool workflow harnesses that only cover one failure branch can overstate readiness; cover success, prerequisite failures, and parsing boundaries separately.
[learning] Human intake placeholders like "unknown" need a promotion-time validator decision, or incomplete discovery facts can cross into production inventory as ordinary strings.
[pattern] Human intake worksheets may retain placeholders, but production inventory and runtime preflight should reject those same tokens before facts become desired state.
[anti-pattern] Text-grep policy checks can be satisfied by comments or unrelated prose; parse structured policy files when the result gates secret readiness.
[pattern] SOPS readiness checks should evaluate applicable creation_rules structurally, including key_groups, so exported recipients must match real policy data.
[anti-pattern] Promotion rehearsals create false confidence if documentation claims they exercise gates, such as syntax or runtime assertions, that the harness never runs.
[anti-pattern] Hardcoded fixture hostnames in shared harnesses break generated contract variants; derive fixture identity from the manifest or keep generator and harness contracts explicit.
[learning] A focused runner-backed proof can pass while the complete runner gate is red; promotion-specific targets complement but never replace the full validation runner.
[learning] Workflow path-filter validators are only as authoritative as the filter syntax they parse; update the guard whenever CI filter style changes.
[anti-pattern] Promoting production inventory while the human intake worksheet remains all placeholders destroys the reviewable discovery-to-desired-state audit trail.
[pattern] Real cryptographic readiness claims should be reproducible through a reviewed command with external private identities mounted read-only, not only recorded as prose.
[anti-pattern] Copying authoritative inventory into a Markdown evidence snapshot removes placeholder ambiguity but creates a new drift surface unless the snapshot is mechanically compared or explicitly archived.
[learning] Evidence validators that check documentation shape should say so plainly; they do not prove live reachability or cryptographic execution without running the underlying command.
[anti-pattern] Secret-readiness gates that scan only paths matched by current SOPS creation rules can miss encrypted files outside policy coverage; detect SOPS metadata first, then validate policy coverage.
[pattern] Fake-command healthcheck fixtures are good for wrapper safety contracts such as no-become flags and failure classification, but live reachability evidence must be collected separately.
[learning] Encrypted-file detectors need an explicit scan-scope contract; path and suffix allowlists are policy decisions that require fixtures before new secret surfaces are added.
[anti-pattern] Evidence validators that accept a reproduced status without checking required evidence fields can create false operational readiness; status labels need field-level completeness checks.
[anti-pattern] Evidence validators that reject only generic placeholders can accept project-native placeholders like not-yet-assigned; validate against the repo's actual placeholder vocabulary.
[learning] Evidence findings must agree with source-of-truth registers, not only contain acceptable prose; cross-check claims like public-route discovery against the active inventory and documentation records.
[anti-pattern] Broad findings regexes can misread negated evidence prose; phrase classifiers need explicit negative fixtures such as "no active routes were found".
[learning] Negation guards should be scoped to the finding phrase or sentence; whole-field checks avoid false positives but can reject valid evidence with unrelated "no drift" follow-up text.
[anti-pattern] Accepted evidence phrases still need local negation checks; otherwise text like "not true that zero routes were found" can satisfy a zero-route contract.
[pattern] Partial evidence records are useful when they preserve failed prerequisites and scope gaps; do not promote them to reproduced readiness until the underlying live command succeeds.
[learning] Containerized Ansible live checks need controller transport and auth paths, not just ansible-core; missing ssh or auth mounts turns reachability evidence into a toolchain prerequisite failure.
[anti-pattern] Auth mount contracts that only document "external" paths still allow repo-local secret material; enforce outside-repository paths before invoking containers.
