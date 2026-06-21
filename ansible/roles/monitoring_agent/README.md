# monitoring_agent Role

## Responsibility

Own host-level monitoring agent installation and configuration once the monitoring stack is selected. This may include node metrics, log forwarding, blackbox probes, or lightweight health reporting.

## Current State

This role is intentionally non-mutating. It does not install agents, create credentials, open ports, or configure remote endpoints.

## Exceptions

Declare host-specific monitoring exceptions in inventory host vars or future `host_vars/`. Monitoring tokens, scrape credentials, and webhook URLs must be SOPS-encrypted.

## Verification

Run:

```sh
ansible-playbook -i ansible/inventories/homelab/hosts.yml ansible/playbooks/baseline.yml --tags monitoring --check
```

## Rollback

Future monitoring agent changes should be reversible by removing or disabling the agent through Ansible and cleaning up any related firewall rule or secret reference.

