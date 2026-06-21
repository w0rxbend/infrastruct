# Admin Workstation Toolchain

Date: 2026-06-21

This repository assumes a Linux admin workstation that can run Ansible,
Docker, Kubernetes, Flux, SOPS, and the local validation scripts before any
change is applied to hosts or clusters.

The repository is currently in `real-fleet` mode for inventory, but operational
use is evidence-gated. The full toolchain can validate repository contracts;
live reachability, reproduced SOPS proof, and public exposure evidence still
have to be collected before mutating hosts, deploying runtime services,
committing real encrypted non-example secrets, or changing public exposure.

The supported workstation path is Debian, Ubuntu, or a close derivative with
`apt`, `systemd`, Python 3, and a POSIX shell. Other operating systems may work,
but maintainers should verify the same command names and versions before
trusting validation output.

Repository validation is not trustworthy until the tools in this document are
installed and the verification commands pass. Missing tools can make validation
fail for workstation reasons, while old or mismatched tools can hide real
repository defects.

## Required Tools

Install and verify:

- `ansible-core`
- `ansible-lint`
- `sops`
- `age`
- `yamllint`
- Docker Engine with Docker Compose v2
- `kubectl`
- Flux CLI
- Docker or Podman for the committed validation runner
- OpenSSH client for live Ansible SSH transport

## Base Packages

```sh
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  pipx \
  python3 \
  python3-pip

pipx ensurepath
```

Open a new shell after `pipx ensurepath` if `pipx` installs commands into a path
that was not already exported.

## Python Tooling

Install Ansible, ansible-lint, and yamllint in isolated `pipx` environments so
they do not depend on system Python packages.

```sh
pipx install --include-deps ansible-core
pipx install --include-deps ansible-lint
pipx install yamllint
```

Verify:

```sh
ansible-playbook --version
ansible-inventory --version
ansible-lint --version
yamllint --version
```

## SOPS And Age

Install `age` from the workstation package manager:

```sh
sudo apt-get update
sudo apt-get install -y age
```

Install SOPS from the upstream release artifact. Keep `SOPS_VERSION` pinned in
change notes when upgrading the workstation toolchain.

```sh
SOPS_VERSION=3.11.0

case "$(uname -m)" in
  x86_64)
    SOPS_ARCH=amd64
    ;;
  aarch64|arm64)
    SOPS_ARCH=arm64
    ;;
  armv7l|armv6l)
    SOPS_ARCH=arm
    ;;
  *)
    echo "Unsupported architecture for SOPS: $(uname -m)" >&2
    exit 1
    ;;
esac

curl -fsSLO \
  "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${SOPS_ARCH}"
sudo install -m 0755 \
  "sops-v${SOPS_VERSION}.linux.${SOPS_ARCH}" \
  /usr/local/bin/sops
rm -f "sops-v${SOPS_VERSION}.linux.${SOPS_ARCH}"
```

Verify:

```sh
sops --version
age-keygen --version
```

Do not add real encrypted non-example secrets until
`docs/sops-workflow-proof.md` has `Status: reproduced` from a reviewed run of
`scripts/prove-sops-workflow`. `operator-provided` and
`not-yet-reproduced` are explicit informational states only while no real
encrypted non-example secret material is present.

## Docker And Compose

Install Docker Engine and the Compose v2 plugin from Docker's apt repository:

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin
```

Verify:

```sh
docker version
docker compose version
```

If the workstation user should run Docker without `sudo`, add the user to the
`docker` group and start a new login session:

```sh
sudo usermod -aG docker "$USER"
```

## Kubectl

Install `kubectl` from the Kubernetes apt repository. Pin
`KUBERNETES_MINOR` to the minor release used by the homelab cluster.

```sh
KUBERNETES_MINOR=v1.34

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/Release.key" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

sudo apt-get update
sudo apt-get install -y kubectl
```

Verify:

```sh
kubectl version --client
```

## Flux CLI

Install the Flux CLI with the upstream installer. Keep `FLUX_VERSION` pinned in
change notes when upgrading the workstation toolchain.

```sh
FLUX_VERSION=2.6.4
curl -fsSL https://fluxcd.io/install.sh | sudo FLUX_VERSION="${FLUX_VERSION}" bash
```

Verify:

```sh
flux --version
```

## Repository Validation

The primary supported gate is the full repository validation suite. After every
required tool verifies, run it from the repository root:

```sh
make validate
```

`make validate` calls `make validate-full`. The full gate includes:

- repository-local contract checks
- YAML linting with `yamllint`
- Ansible linting with `ansible-lint`
- Ansible playbook syntax checks with `ansible-playbook`
- Docker Compose and Swarm stack validation with Docker Compose v2
- SOPS policy and plaintext secret scans

The full gate is a repository trust-boundary check for the promoted
`real-fleet` scaffold. It does not prove live fleet reachability, collected
host facts, cryptographic SOPS execution, or real public exposure state.

The repository also includes a committed containerized validation runner for
machines that have Docker or Podman but do not have the full workstation
toolchain installed locally:

```sh
make validate-runner
```

`make validate-container` is an alias for the same target. The runner builds
`Containerfile`, mounts the repository read-only at `/workspace`, disables
network access for the validation container, and runs `make validate` inside
the image.

The validation runner also includes the Debian `openssh-client` package so it
can act as an Ansible SSH controller for read-only live healthcheck paths when
those paths run with network access and operator-provided authentication
material. The image must not contain private SSH keys, host-specific SSH
configuration, or private authentication material.

When reviewing changes to `ansible/roles/inventory_assertions/`, require the
runner-backed assertion fixture command before trusting the role behavior:

```sh
make test-inventory-assertions-runner
```

This target runs `scripts/test-inventory-assertions` inside the pinned
validation runner and fails if the semantic Ansible role fixture cases are
reported as skipped. A local `make validate-local-contracts` run can pass
without those semantic cases when `ansible-playbook` is missing.

When reviewing focused changes to
`ansible/inventories/homelab/group_contract.yml` or the contract-map harness,
use the explicit runner-backed convergence target:

```sh
make test-inventory-contract-maps-runner
```

That target runs `scripts/test-inventory-contract-maps` inside the pinned
validation runner with semantic Ansible fixture execution required. The cheap
local contract gate does not invoke the containerized runner implicitly.

When reviewing promotion evidence, SOPS proof status semantics, or the
non-mutating live healthcheck wrapper, use the focused local commands before
the full runner:

```sh
scripts/validate-promotion-evidence
scripts/test-promotion-evidence-validator
scripts/test-live-inventory-healthcheck
```

When reviewing changes to SOPS encrypted-file detection in
`scripts/validate-promotion-evidence`, run the focused promotion evidence
commands, the cheap local contract gate, and then the complete runner gate:

```sh
scripts/validate-promotion-evidence
scripts/test-promotion-evidence-validator
make validate-local-contracts
VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner
```

`VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner` is the cached pinned
runner path for ordinary repository changes when the image has already been
built. If the change edits `Containerfile` or validation tool pins, use
`make validate-runner-proof` instead so the image is rebuilt with
`--no-cache --pull`, versions are reported, and the complete gate runs from the
rebuilt image. These checks validate repository contracts and fixture behavior;
they do not collect live inventory reachability evidence or independently
reproduce the cryptographic SOPS workflow proof.

`scripts/test-live-inventory-healthcheck` uses fake `ansible-inventory` and
`ansible` commands from `PATH`. It proves missing-tool handling, inventory
render failure, successful ping, unreachable-host classification, module
failure classification, host limit arguments, and that the wrapper does not
pass become/escalation flags. It does not contact real hosts.

From a supported workstation with `ansible-core` installed and management
network access, collect real non-mutating reachability evidence separately:

```sh
make live-inventory-healthcheck
```

For a scoped check, keep the same wrapper path:

```sh
ANSIBLE_LIMIT=<host-or-group> make live-inventory-healthcheck
```

This command is intentionally outside `make validate` because it requires real
network access and real hosts. Record only non-secret output needed to identify
render success, unreachable hosts, and fact mismatches.

When changing `Containerfile` or validation tool pins, use the proof target
instead of the normal cached runner path:

```sh
make validate-runner-proof
```

`make validate-container-proof` is an alias for the same target. The proof
target rebuilds the validation image with `--no-cache --pull`, prints pinned
tool versions from that rebuilt image, and runs the complete validation gate
from the same image. Override the image tag when the proof should leave a named
artifact for review notes:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-$(date +%Y%m%d) \
  make validate-runner-proof
```

The validation image pins the toolchain through `Containerfile` build
arguments:

| Tool | Default version |
| --- | --- |
| ansible-core | 2.18.6 |
| ansible-lint | 25.6.1 |
| yamllint | 1.37.1 |
| SOPS | 3.11.0 |
| age | 1.2.1 |
| kubectl | 1.34.0 |
| Flux CLI | 2.6.4 |
| Docker CLI | 28.2.2 |
| Docker Compose | 2.36.2 |

The image also installs OS package dependencies that are not pinned by build
argument, including `openssh-client` for Ansible SSH transport. The version
report prints `ssh -V` so a no-cache runner proof records the exact SSH client
version supplied by the rebuilt Debian base image.

Override these only as an intentional toolchain upgrade, for example:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:ansible-2.18.7 \
  docker build \
    --build-arg ANSIBLE_CORE_VERSION=2.18.7 \
    -f Containerfile \
    -t infrastruct-validate:ansible-2.18.7 \
    .

VALIDATION_RUNNER_IMAGE=infrastruct-validate:ansible-2.18.7 \
VALIDATION_RUNNER_SKIP_BUILD=1 \
  scripts/validate-runner
```

Capture the versions from the same image used for validation:

```sh
scripts/validate-runner --versions
```

If the image has already been built and should be reused:

```sh
VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner --versions
VALIDATION_RUNNER_SKIP_BUILD=1 scripts/validate-runner
```

If validation fails before all tool verification commands pass, fix the
workstation toolchain first. If validation fails after the toolchain is verified,
treat the failure as a repository defect unless the output clearly identifies an
external dependency such as an unreachable Docker daemon or Kubernetes cluster.

For fast checks on a machine that has `yamllint` but does not have Ansible,
ansible-lint, SOPS, age, Flux, Docker Compose, or live host access, run:

```sh
make validate-local-contracts
```

That target runs repository-contract validators that do not invoke Ansible,
ansible-lint, Docker Compose, kubectl, Flux, or live host access. It includes
YAML linting because broken repository YAML is a local contract defect. It also
runs the inventory contract map convergence harness so
`scripts/validate-inventory` and
`ansible/roles/inventory_assertions/tasks/main.yml` cannot drift silently on
runtime, architecture, storage, Raspberry Pi Zero hardware, or public exposure
grouping rules. That harness is local-only in this target: when
`ansible-playbook` is unavailable, it reports semantic
`inventory_assertions` probes as skipped instead of starting the validation
runner. It also runs the promotion evidence validator fixtures and the
live-healthcheck fixture harness, but only with fake Ansible commands. It is
useful while editing inventory, documentation contracts, SOPS policy
guardrails, or obvious secret-scan rules, but it is not a substitute for
`make validate` before applying infrastructure changes.

`make validate-local-contracts` may skip semantic `inventory_assertions` role
fixture execution when `ansible-playbook` is unavailable. In that mode it still
checks the static privilege boundary and fixture manifest renderability, then
prints each semantic role fixture as skipped with the missing-tool reason. Use
the runner-backed assertion target above, or the full runner gate, before
trusting changes to assertion-role behavior.

Toolchain-dependent targets report missing prerequisites as `MISSING TOOL` so
maintainers can distinguish workstation setup problems from repository defects.

## Validation Runner Pin Refresh

Use this command when changing `Containerfile`, changing any validation tool
version pin, or proving that the pinned runner still builds from a clean base
image:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-$(date +%Y%m%d) \
  make validate-runner-proof
```

This is a release and maintenance check for the validation runner, not a
replacement for the normal pre-merge gate on unrelated changes. It fails if the
no-cache image build fails, if the version report fails, or if the complete
validation gate fails. `VALIDATION_RUNNER_ENGINE=docker` or
`VALIDATION_RUNNER_ENGINE=podman` can be set when the workstation has both
engines installed and a specific engine is required.

Record the observed versions and the successful gate command in review notes.
Use the actual command output, not the intended `Containerfile` values. A
minimal review note is:

```text
Validation runner refresh:
- Command: VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-YYYYMMDD make validate-runner-proof
- Versions: ansible-core X.Y.Z, ansible-lint X.Y.Z, yamllint X.Y.Z,
  SOPS X.Y.Z, age X.Y.Z, OpenSSH X.Y, Docker CLI X.Y.Z, Docker Compose X.Y.Z,
  kubectl X.Y.Z, Flux X.Y.Z
- Gate: complete validation gate passed from infrastruct-validate:pin-refresh-YYYYMMDD
```

If the no-cache build fails, treat it as a runner toolchain defect before
trusting any cached image. If the build succeeds but the complete gate fails,
treat the failure as a repository or toolchain compatibility defect and keep
the old pins until the failure is understood.

### Last Proven No-Cache Rebuild

Date: 2026-06-21

The committed `Containerfile` was rebuilt from a pulled base image without
cache and the rebuilt image was used for both the version report and the
complete validation gate. No tool pins were changed.

The workstation's `docker` command was backed by Podman and printed this host
wrapper line before container output:

```text
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
```

Commands run:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-20260621; docker build --no-cache --pull -f Containerfile -t "${VALIDATION_RUNNER_IMAGE}" .
VALIDATION_RUNNER_SKIP_BUILD=1 VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-20260621 scripts/validate-runner --versions
VALIDATION_RUNNER_SKIP_BUILD=1 VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-20260621 scripts/validate-runner
```

Observed versions from the rebuilt image:

| Tool | Observed version |
| --- | --- |
| ansible-core | 2.18.6 |
| ansible-lint | 25.6.1 |
| yamllint | 1.37.1 |
| SOPS | 3.11.0 |
| age | 1.2.1 |
| Docker CLI | 28.2.2 |
| Docker Compose | 2.36.2 |
| kubectl | 1.34.0 |
| Flux CLI | 2.6.4 |

Result: the no-cache build passed, the version-report path passed, and the
complete validation gate passed from image
`infrastruct-validate:pin-refresh-20260621`.

### SSH Transport No-Cache Rebuild

Date: 2026-06-22

Reason: `Containerfile` now installs `openssh-client` so the pinned validation
runner can provide Ansible SSH transport for runner-backed live healthchecks.

The committed `Containerfile` was rebuilt from a pulled base image without
cache and the rebuilt image was used for both the version report and the
complete validation gate.

The workstation's `docker` command was backed by Podman and printed this host
wrapper line before container output:

```text
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
```

Command run:

```sh
VALIDATION_RUNNER_IMAGE=infrastruct-validate:ssh-client-20260622 \
  make validate-runner-proof
```

Rebuilt image:
`infrastruct-validate:ssh-client-20260622`
(`bc4a8ebca17fc73e3c67f9c75845dc823149540a144fd1556ea74ffd9b0fbb8c`).

Observed versions from the rebuilt image:

| Tool | Observed version |
| --- | --- |
| ansible-core | 2.18.6 |
| ansible-lint | 25.6.1 |
| yamllint | 1.37.1 |
| SOPS | 3.11.0 |
| age | 1.2.1 |
| OpenSSH client | OpenSSH_9.2p1 Debian-2+deb12u10, OpenSSL 3.0.20 7 Apr 2026 |
| Docker CLI | 28.2.2 |
| Docker Compose | 2.36.2 |
| kubectl | 1.34.0 |
| Flux CLI | 2.6.4 |

Result: the no-cache build passed, the version-report path passed, and the
complete validation gate passed from image
`infrastruct-validate:ssh-client-20260622`.

## Upgrade Policy

Upgrade workstation tools deliberately:

- Keep Ansible, ansible-lint, and yamllint isolated through `pipx`.
- Keep SOPS, kubectl, and Flux version variables pinned when changing them.
- Re-run every verification command after an upgrade.
- Run `make validate` before applying host, cluster, Compose, Swarm, or secret
  changes.
