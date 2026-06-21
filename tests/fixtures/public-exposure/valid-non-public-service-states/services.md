# Service Contract

## Service Records

### Active Non-Public Service

| Field | Value |
| --- | --- |
| Exposure state | `active` |
| Route identifier | `none` |
| Service name | `active-non-public-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `active-non-public-service:8080` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `Active service with no production public route declared.` |

### Production Non-Public Service

| Field | Value |
| --- | --- |
| Exposure state | `production` |
| Route identifier | `none` |
| Service name | `production-non-public-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `production-non-public-service:8080` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `Production service with no production public route declared.` |

### Planned Non-Public Service

| Field | Value |
| --- | --- |
| Exposure state | `planned` |
| Route identifier | `none` |
| Service name | `planned-non-public-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `planned-non-public-service:8080` |
| Firewall intent | `planned` |
| Secret dependency | `none` |
| Review notes | `Planned service with no production public route declared.` |

### Non-Production Non-Public Service

| Field | Value |
| --- | --- |
| Exposure state | `non-production` |
| Route identifier | `none` |
| Service name | `non-production-non-public-service` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `non-production-non-public-service:8080` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `Non-production service with no production public route declared.` |
