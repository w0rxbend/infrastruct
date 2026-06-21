# Homelab Bare-Metal IaC Research and Tooling Proposal

Date: 2026-06-21

## Context

The homelab has about 20 mixed ARM machines:

- Raspberry Pi 4 and 5
- Rock64
- Raspberry Pi Zero class devices
- Current workload modes include K3s, standalone Docker, and Docker Swarm
- Current services include reverse proxies, UniFi Controller, databases, custom applications, and miscellaneous self-hosted workloads
- Storage is mixed: some machines use SSDs and some use SD cards
- Services are publicly exposed through the ISP-provided static public IP
- There is no current DNS provider dependency; access is primarily by public IP
- There is no existing preferred secrets manager
- There are currently no critical services that require high availability or formal backups

The goal is to manage provisioning, configuration, deployment, and regular maintenance from infrastructure-as-code.

## Current Decisions From Owner Input

| Question | Current Answer | IaC Consequence |
| --- | --- | --- |
| Which machines are always-on cluster nodes? | Not decided yet | Inventory must record reliability and intended role |
| SSD or SD-card storage? | Both | Inventory must record storage type; avoid stateful workloads on SD cards unless disposable |
| Critical services needing HA/backups? | None currently | Prioritize rebuildability and monitoring before backup platforms |
| DNS/domain provider? | None; access by static public IP | Do not start with External DNS, Cloudflare automation, or Pulumi DNS |
| Preferred secrets manager? | None | Start with SOPS + age |
| Exposure model? | Public internet | Track public ports and proxies explicitly; updates and firewall rules matter |
| Docker/Swarm future? | Keep Docker, Docker Swarm, and K3s | Treat all three as first-class IaC targets |

## Executive Recommendation

Use a layered model instead of trying to make one tool manage everything.

Recommended default stack:

| Layer | Recommended Tooling | Purpose |
| --- | --- | --- |
| Source of truth | Git | All desired state, review history, rollback path |
| Host inventory and configuration | Ansible | Users, SSH, packages, Docker, K3s install, maintenance, reboots |
| Kubernetes platform | K3s | Runtime for Kubernetes-shaped services |
| Kubernetes GitOps | Flux CD | Reconcile cluster apps from Git |
| Kubernetes packaging | Helm + Kustomize | Manage third-party and custom Kubernetes apps |
| Secrets | SOPS + age first; External Secrets later if needed | Encrypted secrets in Git or integration with a secret backend |
| Docker-only and Swarm workloads | Ansible-managed Compose/Stack files | First-class supported runtimes alongside K3s |
| Backups | Optional: Restic/Kopia, Velero, app-native DB backups | Add only where a service becomes worth recovering |
| Monitoring | Prometheus, Grafana, Alertmanager, node-exporter, Uptime Kuma | Health, alerting, availability checks |
| Updates | Renovate + scheduled Ansible maintenance | Dependency/image PRs and OS update orchestration |
| External/API infrastructure | Pulumi or OpenTofu only where APIs exist | Usually not needed while public access is direct by IP |

This is the pragmatic choice for a mixed ARM homelab because it keeps the operational boundary clear:

- Ansible owns machines.
- K3s, Docker Compose, and Docker Swarm are all supported workload runtimes.
- Flux owns Kubernetes application state.
- Git owns desired state.
- Monitoring validates reality; backups are optional per service.

## Key Design Principles

1. Do not manage physical machines as if they were cloud VMs.
2. Do not make Kubernetes responsible for bootstrapping the OS it depends on.
3. Do not force weak or unreliable devices into the main cluster.
4. Support Docker, Docker Swarm, and K3s explicitly, but keep their ownership boundaries clear.
5. Keep secrets encrypted before they enter Git.
6. Prefer rebuildability first because no current services are critical; add backups only for workloads that become worth preserving.
7. Use pull-based reconciliation where possible for apps, and push-based orchestration where necessary for hosts.

## Proposed Architecture

```text
Git repository
├── ansible/             # physical host desired state
├── clusters/            # Kubernetes desired state reconciled by Flux
├── docker/              # Docker Compose workloads
├── swarm/               # Docker Swarm stacks
├── secrets/             # encrypted secret policy/docs
├── pulumi/              # optional API-managed infrastructure later
└── docs/                # decisions, runbooks, inventory model
```

Runtime flow:

```text
Developer/admin changes Git
        |
        | host changes
        v
Ansible run from admin workstation or automation runner
        |
        v
Machines converge: users, SSH, packages, Docker, K3s, maintenance

Developer/admin changes Git
        |
        | Kubernetes app changes
        v
Flux running inside K3s
        |
        v
Cluster converges: Helm releases, manifests, secrets, ingress, apps

Developer/admin changes Git
        |
        | Docker Compose or Swarm changes
        v
Ansible run from admin workstation or automation runner
        |
        v
Docker hosts and Swarm managers converge: compose projects and stack deploys
```

## Layer 1: Bare-Metal Provisioning and Imaging

This layer answers: how does a machine get an OS and become reachable?

### Option A: Manual imaging plus Ansible bootstrap

Best for the current homelab.

Use Raspberry Pi Imager, prebuilt OS images, or manually prepared SD/SSD media. Then use Ansible for first convergence.

Pros:

- Simple.
- Works across Raspberry Pi and Rock64-type boards.
- Low operational overhead.
- Good enough for about 20 nodes.
- Does not require PXE complexity for devices that may not boot consistently from network.

Cons:

- Initial OS installation is not fully automated.
- Replacing many machines at once is slower.

Recommendation:

- Start here.
- Document the manual imaging steps.
- Let Ansible own everything after SSH works.

### Option B: Raspberry Pi network boot

Useful for Pi 4 and Pi 5 devices with supported bootloader/network setup.

Pros:

- Can remove SD card dependency.
- Easier reprovisioning for supported Pi models.
- Useful if many nodes share a boot/storage pattern.

Cons:

- Not uniform across all hardware.
- More moving parts: DHCP, TFTP/HTTP/NFS/iSCSI depending on design.
- Pi Zero class devices are not good candidates for the main cluster anyway.

Recommendation:

- Consider later for the stable Pi 4/5 cluster nodes.
- Do not make this a blocker for the first IaC version.

### Option C: MAAS

MAAS is designed for bare-metal machine provisioning with machine inventory, commissioning, deployment, and lifecycle management.

Pros:

- Strong bare-metal provisioning model.
- Good for datacenter-style machine pools.
- Handles discovery and lifecycle at a higher level.

Cons:

- Heavy for a 20-node ARM homelab.
- Hardware support and boot flows may be uneven across Raspberry Pi, Rock64, and Pi Zero devices.
- Adds a platform to operate before the platform being managed is stable.

Recommendation:

- Defer.
- Revisit only if the lab grows or you standardize on machines that network-boot cleanly.

### Option D: Tinkerbell

Tinkerbell is a bare-metal provisioning stack oriented around workflows, DHCP, and OS installation.

Pros:

- Cloud-native bare-metal provisioning model.
- Powerful if you want reproducible zero-touch OS installs.

Cons:

- More complex than needed initially.
- Better suited to homogeneous or datacenter-like hardware pools.
- Requires careful network boot support.

Recommendation:

- Defer.
- Not the first tool for this mixed ARM setup.

### Option E: netboot.xyz

Useful as a boot menu and installer launcher.

Pros:

- Convenient for interactive or semi-automated installs.
- Can simplify booting many installers.

Cons:

- It is not a full desired-state management system.
- Still needs host config management afterward.
- ARM board support and boot paths vary.

Recommendation:

- Optional helper, not a core IaC layer.

## Layer 2: Host Operating System Strategy

This layer answers: what OS model should the machines run?

### Option A: Debian or Ubuntu Server plus Ansible

Best default.

Pros:

- Familiar and well-supported.
- Works on Raspberry Pi and many ARM boards.
- Compatible with Docker, K3s, monitoring agents, and backup tools.
- Easy emergency debugging over SSH.

Cons:

- Mutable OS means drift is possible unless Ansible is run regularly.
- Upgrades need discipline.

Recommendation:

- Use Debian or Ubuntu Server where possible.
- Use Raspberry Pi OS Lite only where board support makes it the least painful option.
- Keep the OS boring.

### Option B: NixOS

NixOS provides declarative OS configuration, reproducible system builds, and rollback.

Pros:

- Very strong desired-state model.
- Good rollback story.
- Can eliminate much host drift.

Cons:

- Higher learning curve.
- More work across mixed ARM boards.
- Some homelab software docs assume Debian-like systems.
- You still need a cluster/app deployment model.

Recommendation:

- Excellent long-term experiment for selected nodes.
- Do not make it the baseline unless you want the repo to become Nix-first.

### Option C: Talos Linux

Talos is an immutable OS specifically for Kubernetes nodes.

Pros:

- Strong Kubernetes node lifecycle model.
- Minimal mutable host surface.
- API-driven node management.
- Good fit for dedicated Kubernetes machines.

Cons:

- Not for general-purpose Docker hosts.
- Less convenient for nodes that also run miscellaneous host-level services.
- Mixed ARM board support must be checked carefully.
- Operational model is different from normal Linux SSH administration.

Recommendation:

- Strong candidate if you later want a dedicated, clean K3s-like Kubernetes appliance cluster.
- Not the first baseline for the current mixed-use homelab.

### Option D: Flatcar Container Linux

Immutable/container-focused OS.

Pros:

- Good container-host model.
- Reduced OS drift.

Cons:

- Less natural for Raspberry Pi style homelab management.
- Not as directly aligned with K3s-on-Pi patterns as Debian/Ubuntu.

Recommendation:

- Defer.

### Option E: Kairos

Kairos targets immutable edge Kubernetes systems.

Pros:

- Interesting for edge Kubernetes and immutable infrastructure.
- Can fit appliance-like cluster nodes.

Cons:

- Adds another opinionated OS lifecycle.
- Less mainstream than Debian/Ubuntu plus Ansible for homelab troubleshooting.

Recommendation:

- Research later if immutable edge nodes become a priority.

## Layer 3: Host Configuration Management

This layer answers: how do reachable machines become correctly configured?

### Option A: Ansible

Best default.

Use Ansible for:

- Inventory
- SSH hardening
- Users and authorized keys
- Sudo policy
- Package installation
- Docker installation
- K3s installation and upgrades
- System tuning
- Mounts and storage paths
- Firewall rules
- Monitoring agents
- Backup agents
- Scheduled maintenance
- Controlled reboot workflows

Pros:

- Agentless.
- Works well with small heterogeneous fleets.
- Easy to run from a laptop, CI runner, or automation host.
- Large ecosystem.
- Clear inventory/group model.

Cons:

- Push-based.
- Long playbooks can become messy if not structured.
- Needs regular runs to correct drift.

Recommendation:

- Use Ansible as the primary host-management tool.

### Option B: Salt

Pros:

- Strong remote execution and state management.
- Pull and event-driven models are possible.
- Good at managing larger fleets.

Cons:

- Requires master/minion or more infrastructure.
- More operational overhead than Ansible for 20 machines.

Recommendation:

- Consider only if you want persistent agents and event-driven host management.

### Option C: Puppet or Chef

Pros:

- Mature configuration management ecosystems.
- Strong policy-driven fleet management.

Cons:

- Heavy for this homelab.
- More moving parts and less ergonomic for ad hoc mixed ARM infrastructure.

Recommendation:

- Do not use for this project unless you already have strong experience and preference.

### Option D: Plain shell scripts

Pros:

- Fast to start.
- No framework.

Cons:

- Poor idempotency.
- Harder rollback and audit.
- Harder inventory/group handling.

Recommendation:

- Avoid except for tiny helper scripts called by Ansible.

## Layer 4: Container and Cluster Runtime

This layer answers: where should services run?

The selected model is multi-runtime by design:

- K3s for Kubernetes-native services and services that benefit from scheduling, ingress, Helm charts, and GitOps.
- Docker Compose for simple single-host services and edge nodes.
- Docker Swarm for multi-host Docker stacks where Swarm is useful or already established.

The IaC goal is not to force every workload into one runtime. The goal is to make each runtime declarative, repeatable, and documented.

### Runtime A: K3s

Best Kubernetes platform.

Use for:

- Reverse proxies and ingress
- Cert-manager
- DNS-related services where appropriate
- Custom applications
- Most databases if storage/backups are designed carefully
- Observability stack
- Controllers and scheduled jobs

Pros:

- Lightweight Kubernetes distribution.
- Good ARM and edge adoption.
- Strong ecosystem.
- GitOps-friendly.
- Better long-term platform than manually managed Docker hosts.

Cons:

- Kubernetes complexity is real.
- Storage and backups must be designed intentionally.
- Very weak nodes should not be part of the main cluster.

Recommendation:

- Make K3s the default target for Kubernetes-shaped services.
- Keep the main cluster to reliable Pi 4/5 and equivalent nodes with adequate storage.
- Manage K3s installation, node labels, taints, and upgrades with Ansible.
- Manage K3s applications with Flux.

### Runtime B: Docker Compose

Use for:

- Simple standalone services
- Edge nodes
- Pi Zero class devices
- Services that are easier to run on one known host than in Kubernetes
- Hardware-bound services

Pros:

- Simple.
- Good for one-machine services.
- Easy to understand.

Cons:

- No real cluster scheduler.
- Multi-host operations are manual unless wrapped by Ansible.

Recommendation:

- Keep Compose as a first-class supported mode.
- Store Compose files in Git and deploy with Ansible.
- Use labels or inventory vars to map a Compose service to exactly one host.

### Runtime C: Docker Swarm

Use where Docker-native multi-host scheduling is desired without Kubernetes.

Pros:

- Simpler than Kubernetes.
- Native Docker stack model.
- Good enough for some multi-node services.

Cons:

- Smaller ecosystem than Kubernetes.
- GitOps and app ecosystem are weaker.
- Running Swarm and K3s together increases operational surface area, so repo organization must be strict.

Recommendation:

- Keep Swarm as a supported runtime.
- Store stack files in Git under `swarm/stacks/`.
- Deploy stack changes through Ansible from a Swarm manager.
- Track Swarm manager and worker membership in Ansible inventory.
- Do not duplicate the same service across Swarm and K3s unless it is a deliberate migration or experiment.

### Option D: k0s

Pros:

- Lightweight Kubernetes distribution.
- Clean packaging and lifecycle story.

Cons:

- Switching from K3s needs a reason.
- K3s is already running and is widely used in homelabs.

Recommendation:

- Do not switch unless K3s has a concrete pain point.

### Option E: MicroK8s

Pros:

- Convenient Kubernetes distribution.
- Good for edge and developer scenarios.

Cons:

- Snap-based management may not be ideal for all homelab nodes.
- K3s is already a better fit for lightweight ARM clusters in many self-hosted patterns.

Recommendation:

- Do not switch.

## Layer 5: Kubernetes App Delivery

This layer answers: how does the K3s cluster receive app changes?

### Option A: Flux CD

Best default.

Use for:

- Kustomizations
- Helm releases
- Encrypted secrets with SOPS
- Cluster add-ons
- Application deployment
- Image automation later if desired

Pros:

- Pull-based GitOps.
- Works well in small clusters.
- Strong SOPS integration.
- Good fit for repository-first operations.

Cons:

- Debugging reconciliation requires learning Flux resources.
- Less visual than Argo CD by default.

Recommendation:

- Use Flux CD.

### Option B: Argo CD

Pros:

- Strong UI.
- Excellent application visibility.
- Very popular.

Cons:

- Heavier than Flux for a small homelab.
- Secrets story usually needs additional decisions.

Recommendation:

- Good alternative if you value a UI heavily.
- Otherwise use Flux.

### Helm and Kustomize

Use both:

- Helm for packaged third-party apps.
- Kustomize for environment overlays and plain manifests.

Recommendation:

- Do not choose only one.
- Use HelmRelease objects through Flux for third-party charts.
- Use Kustomize for repo organization and small custom resources.

## Layer 6: Reverse Proxy and Ingress

Existing tools include nginx, Caddy, and Traefik.

Recommended stance:

- Public exposure is through a static ISP-provided public IP.
- Standardize inside Kubernetes on one ingress controller.
- Keep one edge entrypoint pattern for traffic entering the homelab.
- Avoid running nginx, Caddy, and Traefik in overlapping roles unless each has a documented reason.

Options:

| Tool | Best Use | Recommendation |
| --- | --- | --- |
| Traefik | K3s default-ish ecosystem, dynamic routing, ingress | Good default if already present |
| nginx ingress | Common Kubernetes ingress, predictable | Good alternative |
| Caddy | Simple automatic TLS, reverse proxy, edge services | Good for standalone Docker or edge proxy |

Recommendation:

- If K3s already uses Traefik and it works, standardize on Traefik for cluster ingress.
- Use Caddy only for standalone Docker edge cases or a deliberate external gateway.
- Use nginx only where it has a specific role, such as a known legacy config or TCP/HTTP behavior that is already working.
- Avoid managing the same public route in multiple proxies.
- Because services are public, prioritize firewall rules, explicit allowlists where possible, TLS where hostnames exist, and regular update automation.

## Layer 7: Secrets Management

There is no current preferred secrets manager. The first requirement is therefore simple: do not commit plaintext credentials.

### Option A: SOPS + age

Best first choice.

Pros:

- Encrypted secrets can live in Git.
- Works with Flux.
- Simple enough for a homelab.
- No always-on secret service required.

Cons:

- Key management is your responsibility.
- Secret rotation process must be documented.

Recommendation:

- Start with SOPS + age.
- Use it for Ansible vars, Kubernetes secrets, and any Docker/Swarm environment files that must live in Git.

### Option B: External Secrets Operator

Use when secrets are stored in an external backend such as Vault, 1Password, cloud secret managers, or similar.

Pros:

- Kubernetes pulls secrets from a source of truth.
- Better for larger or shared environments.

Cons:

- Requires operating or depending on another secret backend.

Recommendation:

- Add later if you already use 1Password, Vault, or another backend as the canonical source.

### Option C: HashiCorp Vault

Pros:

- Very powerful.
- Dynamic secrets, policies, audit, leasing.

Cons:

- Operationally heavy.
- Vault itself must be highly available and backed up.

Recommendation:

- Avoid as a first step unless you specifically want to run Vault as a project.

## Layer 8: Persistent Storage

This is one of the highest-risk areas in a Raspberry Pi homelab.

Important assumptions:

- The fleet has both SSD-backed and SD-card-backed machines.
- SD cards are not reliable storage for databases.
- USB SSDs are better for stateful services.
- Distributed storage on low-power ARM nodes can work, but should be treated carefully.

### Option A: Local persistent volumes

Pros:

- Simple.
- Fast.
- Easy to reason about per node.

Cons:

- Pods become tied to nodes.
- Node failure requires restore or manual intervention.

Recommendation:

- Best starting point for small stateful workloads.
- Use on SSD-backed nodes for services with meaningful state.
- Use SD-card-backed nodes for stateless, cache, test, or easily rebuilt services.

### Option B: Longhorn

Pros:

- Kubernetes-native distributed block storage.
- UI and recurring backup support.
- Popular in homelabs.

Cons:

- Needs reliable disks and network.
- Can be heavy on small ARM nodes.
- Operational complexity increases.

Recommendation:

- Candidate for Pi 4/5 nodes with SSDs.
- Do not deploy on weak nodes or SD-card-backed storage.

### Option C: Rook/Ceph

Pros:

- Powerful distributed storage.
- Mature storage system.

Cons:

- Heavy.
- Operationally complex.
- Often too much for a small ARM homelab unless storage is a major focus.

Recommendation:

- Avoid initially.

### Option D: OpenEBS

Pros:

- Kubernetes storage options including local PV patterns.
- Can be lighter than Ceph depending on mode.

Cons:

- Still needs storage design and operational knowledge.

Recommendation:

- Consider local-path/local PV style first.
- Revisit if local PV management becomes painful.

### Option E: NAS-backed storage

Examples: NFS from a NAS, TrueNAS, or a dedicated storage host.

Pros:

- Centralized data management.
- Often easier backups.
- Keeps weak compute nodes stateless.

Cons:

- NAS becomes critical infrastructure.
- Network dependency.
- Some databases dislike network filesystems unless configured carefully.

Recommendation:

- Good for media, configs, and many app volumes.
- Use app-native database backup for databases instead of trusting only filesystem snapshots.

## Layer 9: Backups and Recovery

There are currently no critical services requiring formal backups. The recommended first posture is rebuildability:

- All service definitions live in Git.
- Host baseline is recreated by Ansible.
- K3s apps are recreated by Flux.
- Docker and Swarm apps are recreated by Ansible.
- Persistent data is treated as disposable unless a service is later marked important.

Backups should still be designed by workload type when a service becomes worth preserving.

### Files and volumes

Recommended tools:

- Restic
- Kopia

Use for:

- Host config snapshots
- Docker volumes
- App data directories
- Kubernetes PV backups when filesystem-level backup makes sense

### Kubernetes objects

Recommended tool:

- Velero

Use for:

- Kubernetes manifests and cluster resource backup
- Namespace-level restore workflows

Important caveat:

- Backing up Kubernetes objects is not the same as backing up application data.

### Databases

Use app-native backups:

- PostgreSQL: pg_dump, pg_basebackup, or a Kubernetes operator with backup support
- MariaDB/MySQL: mariabackup, mysqldump, or operator-native backup
- SQLite: application-aware copy or backup API when available

Recommendation:

- Do not deploy a full backup platform first.
- Add backup only for services whose data you would actually miss.
- For non-critical databases, document that data is disposable.
- If a service becomes important, add a short restore runbook and a `restore-tested` date.

## Layer 10: Monitoring and Alerting

Recommended stack:

- Prometheus for metrics
- Grafana for dashboards
- Alertmanager for alerts
- node-exporter for host metrics
- kube-state-metrics for Kubernetes object state
- blackbox-exporter or Uptime Kuma for external availability checks
- smartctl-exporter or equivalent for disk health where supported

Minimum alerts:

- Node down
- Disk almost full
- Memory pressure
- High temperature or throttling on Raspberry Pis
- K3s node not ready
- Certificate expiring, where TLS/domain names are used
- Flux reconciliation failing
- Longhorn/storage degraded if distributed storage is used
- Public service not responding

Recommendation:

- Use Prometheus/Grafana for deep metrics.
- Use Uptime Kuma for simple human-friendly service checks.

## Layer 11: Updates and Maintenance

Recommended maintenance flow:

1. Renovate opens PRs for container images, Helm charts, GitHub Actions, and possibly Ansible collections.
2. Review and merge low-risk updates.
3. Flux reconciles Kubernetes changes.
4. Ansible deploys Docker Compose and Swarm stack changes.
5. Ansible runs scheduled host maintenance.
6. Reboots happen in controlled groups.
7. Monitoring confirms health.

Ansible playbooks to create:

- `bootstrap.yml`
- `baseline.yml`
- `docker.yml`
- `k3s.yml`
- `compose.yml`
- `swarm.yml`
- `maintenance.yml`
- `reboot.yml`
- `healthcheck.yml`

Maintenance policy:

- Weekly: package cache update, security updates, public exposure review for changed services.
- Biweekly or monthly: full OS updates and reboots.
- Monthly: review services that have become worth backing up.
- Quarterly: review inventory, unused services, exposed ports, and secrets.

## Layer 12: DNS, Network, and External Infrastructure

Use Pulumi or OpenTofu only for resources with APIs.

Current network assumption:

- Public ingress uses a static public IP from the ISP.
- There is no DNS provider in the current operating model.
- Services are public rather than VPN-only.

Good candidates:

- Cloudflare DNS, only if domains are added later
- Public DNS records, only if domains are added later
- Tailscale ACLs or devices if provider support fits
- GitHub repository settings
- Object storage buckets for backups, only if backups become needed
- Cloud firewall rules
- Uptime provider monitors

Poor candidates:

- Installing packages on Pis
- Managing random files under `/etc`
- Rebooting nodes
- Deploying Docker Compose directly

Recommendation:

- Do not start with Pulumi/OpenTofu.
- Add it only when external API-managed resources become real enough to justify another tool.
- For now, model public exposure in Ansible inventory and service documentation: public port, internal host, runtime, proxy, and firewall intent.

## Tool Decision Matrix

| Need | Best Fit | Alternative | Avoid Initially |
| --- | --- | --- | --- |
| Host inventory | Ansible | NetBox later | Spreadsheet-only inventory |
| Host config | Ansible | Salt, NixOS | Shell-only automation |
| OS provisioning | Manual image + Ansible | MAAS, Tinkerbell | Full PXE platform from day one |
| Kubernetes runtime | K3s | k0s | Switching without a concrete pain point |
| Single-host containers | Docker Compose via Ansible | systemd services | Manual `docker run` |
| Multi-host Docker | Docker Swarm via Ansible | K3s | Untracked stack deploys |
| Kubernetes GitOps | Flux | Argo CD | Manual `kubectl apply` |
| Kubernetes packaging | Helm + Kustomize | Jsonnet/CUE later | Raw copied manifests everywhere |
| Secrets | SOPS + age | External Secrets Operator | Plaintext secrets |
| Distributed storage | Local PV first, maybe Longhorn | OpenEBS | Ceph first |
| File backups if needed | Restic or Kopia | BorgBackup | Ad hoc tarballs only |
| K8s backups if needed | Velero | Storage-native snapshots | Assuming Git backs up data |
| Metrics | Prometheus + Grafana | Netdata | No alerting |
| Uptime checks | Uptime Kuma | blackbox-exporter | Manual checking |
| Updates | Renovate + Ansible | Dependabot for limited scopes | Random manual upgrades |
| API infra if needed | Pulumi/OpenTofu later | Terraform/OpenTofu | Using Pulumi for host config |

## Recommended Implementation Phases

### Phase 1: Repository and inventory foundation

Create:

```text
ansible/inventories/homelab/hosts.yml
ansible/inventories/homelab/group_vars/
ansible/playbooks/bootstrap.yml
ansible/playbooks/baseline.yml
ansible/playbooks/maintenance.yml
docs/hosts.md
docs/services.md
```

Inventory grouping:

- `k3s_servers`
- `k3s_agents`
- `docker_hosts`
- `swarm_managers`
- `swarm_workers`
- `edge_nodes`
- `arm64`
- `armv7`
- `pi_zero`
- `ssd_storage`
- `sdcard_storage`

First target:

- Every host reachable by SSH.
- Every host has a known role.
- Every host has baseline users, packages, time sync, and monitoring.

### Phase 2: Stabilize the main K3s cluster

Create:

```text
ansible/playbooks/k3s.yml
ansible/playbooks/compose.yml
ansible/playbooks/swarm.yml
clusters/homelab/flux-system/
clusters/homelab/infrastructure/
clusters/homelab/apps/
docker/compose/
swarm/stacks/
```

Decide:

- Which 3 or 5 machines are reliable K3s server candidates.
- Which machines are agents.
- Which machines are Docker-only hosts.
- Which machines are Swarm managers and workers.
- Which storage nodes have SSDs versus SD cards.
- Which public ports are intentionally exposed.

### Phase 3: GitOps core services

Deploy by Flux:

- Ingress controller
- cert-manager
- SOPS secret integration
- Monitoring stack
- Storage class for SSD-backed nodes if needed

### Phase 4: Application catalog and runtime placement

Classify every service:

| Class | Target |
| --- | --- |
| Kubernetes-shaped service | K3s |
| Simple single-node | Docker Compose via Ansible |
| Multi-host Docker service | Docker Swarm via Ansible |
| Hardware-specific | Dedicated host via Ansible |
| Experimental | Separate namespace or edge node |

For each service document:

- Owner
- URL
- Runtime
- Data location
- Secret source
- Backup policy: none, optional, or required
- Restore steps only when backup policy is required
- Exposure: public port, proxy, and internal target

### Phase 5: Maintenance automation

Create:

```text
ansible/playbooks/update-os.yml
ansible/playbooks/reboot-k3s.yml
ansible/playbooks/deploy-compose.yml
ansible/playbooks/deploy-swarm.yml
renovate.json
docs/maintenance.md
docs/public-exposure.md
```

Add process:

- Review Renovate PRs weekly.
- Run maintenance playbook on a schedule.
- Deploy Compose and Swarm changes through Ansible.
- Reboot in groups.
- Confirm Flux and monitoring health.
- Review public exposure and secrets.

## Proposed Final Tool Stack

Start with:

- Debian/Ubuntu/Raspberry Pi OS Lite as host OS
- Ansible
- K3s
- Flux CD
- Helm
- Kustomize
- SOPS + age
- Prometheus/Grafana/Alertmanager
- Uptime Kuma
- Renovate

Add later when justified:

- External Secrets Operator
- Longhorn
- Restic or Kopia
- Velero
- Pulumi or OpenTofu
- NetBox
- MAAS, Tinkerbell, or Pi network boot
- Talos or NixOS for dedicated experiments

Avoid as first-line choices:

- Puppet/Chef
- Full MAAS/Tinkerbell provisioning before inventory is clean
- Ceph/Rook on small ARM nodes
- Vault unless secret management itself is a goal
- Untracked manual Docker, Swarm, or Kubernetes changes outside Git

## Immediate Next Actions

1. Build the Ansible inventory and host taxonomy.
2. Decide which machines are trusted cluster nodes.
3. Mark each host as SSD-backed or SD-card-backed.
4. Create baseline Ansible playbooks.
5. Add Docker Compose and Swarm deployment playbooks.
6. Bootstrap Flux into the current K3s cluster.
7. Move one low-risk K3s service into GitOps as a pattern.
8. Move one Docker Compose service into Ansible-managed deployment as a pattern.
9. Move one Swarm stack into Ansible-managed deployment as a pattern.
10. Add SOPS + age before committing real secrets.
11. Document public exposure for each service.

## Primary Sources

- Ansible documentation: https://docs.ansible.com/projects/ansible/latest/index.html
- Ansible inventory guide: https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html
- Salt documentation: https://docs.saltproject.io/
- NixOS manual: https://nixos.org/manual/nixos/stable/
- Puppet documentation: https://www.puppet.com/docs/puppet/
- MAAS documentation: https://maas.io/docs
- Tinkerbell documentation: https://tinkerbell.org/docs/
- netboot.xyz documentation: https://netboot.xyz/docs/
- Raspberry Pi network boot docs: https://www.raspberrypi.com/documentation/computers/remote-access.html
- Talos Linux documentation: https://www.talos.dev/
- Flatcar documentation: https://www.flatcar.org/docs/latest/
- Kairos documentation: https://kairos.io/docs/
- K3s documentation: https://docs.k3s.io/
- k0s documentation: https://docs.k0sproject.io/
- MicroK8s documentation: https://microk8s.io/docs
- Docker Swarm stack deploy docs: https://docs.docker.com/engine/swarm/stack-deploy/
- Flux documentation: https://fluxcd.io/flux/
- Argo CD documentation: https://argo-cd.readthedocs.io/
- Helm documentation: https://helm.sh/docs/
- Kustomize documentation: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
- SOPS documentation: https://getsops.io/docs/
- Flux SOPS guide: https://fluxcd.io/flux/guides/mozilla-sops/
- External Secrets Operator: https://external-secrets.io/
- HashiCorp Vault documentation: https://developer.hashicorp.com/vault/docs
- Longhorn documentation: https://longhorn.io/docs/
- Rook documentation: https://rook.io/docs/rook/latest-release/
- OpenEBS documentation: https://openebs.io/docs/
- Velero documentation: https://velero.io/docs/
- Restic documentation: https://restic.readthedocs.io/
- Kopia documentation: https://kopia.io/docs/
- Prometheus documentation: https://prometheus.io/docs/
- Grafana documentation: https://grafana.com/docs/
- kube-prometheus-stack chart: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
- Uptime Kuma: https://github.com/louislam/uptime-kuma
- Renovate documentation: https://docs.renovatebot.com/
- Pulumi ESC documentation: https://www.pulumi.com/docs/esc/
