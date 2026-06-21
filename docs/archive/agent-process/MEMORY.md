[pattern] Contract-first scaffolding is useful for a mixed-runtime homelab, but examples must be isolated or loudly marked so they cannot be mistaken for production desired state.
[anti-pattern] Placeholder inventory with example public exposure creates false source-of-truth signals when documentation says no public routes exist.
[learning] Toolchain readiness is a prerequisite for IaC confidence; Ansible and SOPS commands in docs are not actionable until the repo defines how to install and validate those tools.
[pattern] Before mutating host baseline roles, add inventory assertions and non-mutating health checks to catch wrong hosts, wrong storage class, and unsafe placement assumptions.
[learning] An intentionally empty production inventory is safer than placeholder desired state, but it needs an explicit discovery-mode or expected-host-count guard before automation depends on it.
[pattern] Validation should be warning-clean; tolerated warnings from YAML or Compose schemas become easy to ignore and hide later regressions.
[learning] Adding a Make target for a missing tool improves the contract but does not prove the gate; record tool versions only after the gate actually runs.
[anti-pattern] Ignoring agent artifacts after they are already tracked does not remove them from the operational source tree; tracked artifacts need an explicit move or index cleanup.
[learning] Documentation consistency validators must parse the authoritative record formats, not just search for route identifiers, or incomplete public exposure records can still pass.
