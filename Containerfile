FROM debian:bookworm-slim

ARG ANSIBLE_CORE_VERSION=2.18.6
ARG ANSIBLE_LINT_VERSION=25.6.1
ARG YAMLLINT_VERSION=1.37.1
ARG SOPS_VERSION=3.11.0
ARG AGE_VERSION=1.2.1
ARG KUBECTL_VERSION=1.34.0
ARG FLUX_VERSION=2.6.4
ARG DOCKER_CLI_VERSION=28.2.2
ARG DOCKER_COMPOSE_VERSION=2.36.2

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/validation/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    make \
    python3 \
    python3-pip \
    python3-venv \
    tar \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/validation \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir \
    "ansible-core==${ANSIBLE_CORE_VERSION}" \
    "ansible-lint==${ANSIBLE_LINT_VERSION}" \
    "yamllint==${YAMLLINT_VERSION}"

RUN case "$(uname -m)" in \
      x86_64) sops_arch=amd64; age_arch=amd64; kubectl_arch=amd64; docker_arch=x86_64; compose_arch=x86_64 ;; \
      aarch64|arm64) sops_arch=arm64; age_arch=arm64; kubectl_arch=arm64; docker_arch=aarch64; compose_arch=aarch64 ;; \
      armv7l|armv6l) sops_arch=arm; age_arch=armv7; kubectl_arch=arm; docker_arch=armhf; compose_arch=armv7 ;; \
      *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
    esac \
  && curl -fsSL \
    "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${sops_arch}" \
    -o /usr/local/bin/sops \
  && chmod 0755 /usr/local/bin/sops \
  && curl -fsSL \
    "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-${age_arch}.tar.gz" \
    -o /tmp/age.tar.gz \
  && tar -xzf /tmp/age.tar.gz -C /tmp \
  && install -m 0755 "/tmp/age/age" /usr/local/bin/age \
  && install -m 0755 "/tmp/age/age-keygen" /usr/local/bin/age-keygen \
  && curl -fsSL \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${kubectl_arch}/kubectl" \
    -o /usr/local/bin/kubectl \
  && chmod 0755 /usr/local/bin/kubectl \
  && curl -fsSL \
    "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_${kubectl_arch}.tar.gz" \
    -o /tmp/flux.tar.gz \
  && tar -xzf /tmp/flux.tar.gz -C /usr/local/bin flux \
  && chmod 0755 /usr/local/bin/flux \
  && curl -fsSL \
    "https://download.docker.com/linux/static/stable/${docker_arch}/docker-${DOCKER_CLI_VERSION}.tgz" \
    -o /tmp/docker.tgz \
  && tar -xzf /tmp/docker.tgz -C /tmp docker/docker \
  && install -m 0755 /tmp/docker/docker /usr/local/bin/docker \
  && mkdir -p /usr/local/lib/docker/cli-plugins \
  && curl -fsSL \
    "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${compose_arch}" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose \
  && chmod 0755 /usr/local/lib/docker/cli-plugins/docker-compose \
  && rm -rf /tmp/age /tmp/age.tar.gz /tmp/flux.tar.gz /tmp/docker /tmp/docker.tgz

RUN cat >/usr/local/bin/validation-tool-versions <<'EOF' \
  && chmod 0755 /usr/local/bin/validation-tool-versions
#!/usr/bin/env bash
set -euo pipefail

export ANSIBLE_HOME=/tmp/.ansible
export XDG_CACHE_HOME=/tmp/.cache

ansible-playbook --version
(cd /tmp && ansible-lint --version)
yamllint --version
sops --disable-version-check --version
age-keygen --version
docker --version
docker compose version
kubectl version --client
flux --version
EOF

WORKDIR /workspace

CMD ["make", "validate"]
