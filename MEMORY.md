[pattern] Contract-first scaffolding is useful for a mixed-runtime homelab, but examples must be isolated or loudly marked so they cannot be mistaken for production desired state.
[anti-pattern] Placeholder inventory with example public exposure creates false source-of-truth signals when documentation says no public routes exist.
[learning] Toolchain readiness is a prerequisite for IaC confidence; Ansible and SOPS commands in docs are not actionable until the repo defines how to install and validate those tools.
[pattern] Before mutating host baseline roles, add inventory assertions and non-mutating health checks to catch wrong hosts, wrong storage class, and unsafe placement assumptions.
[learning] An intentionally empty production inventory is safer than placeholder desired state, but it needs an explicit discovery-mode or expected-host-count guard before automation depends on it.
[pattern] Validation should be warning-clean; tolerated warnings from YAML or Compose schemas become easy to ignore and hide later regressions.
