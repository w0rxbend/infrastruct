[pattern] Contract-first scaffolding is useful for a mixed-runtime homelab, but examples must be isolated or loudly marked so they cannot be mistaken for production desired state.
[anti-pattern] Placeholder inventory with example public exposure creates false source-of-truth signals when documentation says no public routes exist.
[learning] Toolchain readiness is a prerequisite for IaC confidence; Ansible and SOPS commands in docs are not actionable until the repo defines how to install and validate those tools.
[pattern] Before mutating host baseline roles, add inventory assertions and non-mutating health checks to catch wrong hosts, wrong storage class, and unsafe placement assumptions.
