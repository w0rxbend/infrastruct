# Admin Workstation Toolchain

Date: 2026-06-21

This repository assumes a Linux admin workstation that can run Ansible,
Docker, Kubernetes, Flux, SOPS, and the local validation scripts before any
change is applied to hosts or clusters.

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

Do not add real encrypted production secrets while `.sops.yaml` still contains
the documented dummy age recipient.

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
YAML linting because broken repository YAML is a local contract defect. It is
useful while editing inventory, documentation contracts, SOPS policy guardrails,
or obvious secret-scan rules, but it is not a substitute for `make validate`
before applying infrastructure changes.

Toolchain-dependent targets report missing prerequisites as `MISSING TOOL` so
maintainers can distinguish workstation setup problems from repository defects.

## Validation Runner Pin Refresh

Use this procedure when changing `Containerfile`, changing any validation
tool version pin, or proving that the pinned runner still builds from a clean
base image. This is a release and maintenance check for the validation runner,
not a replacement for the normal pre-merge gate.

1. Edit the relevant `ARG ..._VERSION` pins in `Containerfile`.

2. Build a fresh validation image without relying on a cached local image:

   ```sh
   VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-$(date +%Y%m%d)
   docker build --no-cache --pull \
     -f Containerfile \
     -t "${VALIDATION_RUNNER_IMAGE}" \
     .
   ```

   If the workstation uses Podman, run the same build with `podman`:

   ```sh
   VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-$(date +%Y%m%d)
   podman build --no-cache --pull \
     -f Containerfile \
     -t "${VALIDATION_RUNNER_IMAGE}" \
     .
   ```

3. Print the pinned tool versions from that exact image:

   ```sh
   VALIDATION_RUNNER_SKIP_BUILD=1 \
   VALIDATION_RUNNER_IMAGE="${VALIDATION_RUNNER_IMAGE}" \
     scripts/validate-runner --versions
   ```

4. Run the complete validation gate from the same image:

   ```sh
   VALIDATION_RUNNER_SKIP_BUILD=1 \
   VALIDATION_RUNNER_IMAGE="${VALIDATION_RUNNER_IMAGE}" \
     scripts/validate-runner
   ```

5. Record the observed versions and the successful gate command in review
   notes. Use the actual command output, not the intended `Containerfile`
   values. A minimal review note is:

   ```text
   Validation runner refresh:
   - Build: docker build --no-cache --pull -f Containerfile -t infrastruct-validate:pin-refresh-YYYYMMDD .
   - Versions: ansible-core X.Y.Z, ansible-lint X.Y.Z, yamllint X.Y.Z,
     SOPS X.Y.Z, age X.Y.Z, Docker CLI X.Y.Z, Docker Compose X.Y.Z,
     kubectl X.Y.Z, Flux X.Y.Z
   - Gate: VALIDATION_RUNNER_SKIP_BUILD=1 VALIDATION_RUNNER_IMAGE=infrastruct-validate:pin-refresh-YYYYMMDD scripts/validate-runner
   ```

If the no-cache build fails, treat it as a runner toolchain defect before
trusting any cached image. If the build succeeds but the complete gate fails,
treat the failure as a repository or toolchain compatibility defect and keep
the old pins until the failure is understood.

## Upgrade Policy

Upgrade workstation tools deliberately:

- Keep Ansible, ansible-lint, and yamllint isolated through `pipx`.
- Keep SOPS, kubectl, and Flux version variables pinned when changing them.
- Re-run every verification command after an upgrade.
- Run `make validate` before applying host, cluster, Compose, Swarm, or secret
  changes.
