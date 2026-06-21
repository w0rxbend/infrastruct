# Service Contract

## Service Records

### Invalid State With None Public Host

| Field | Value |
| --- | --- |
| Exposure state | `deferred` |
| Route identifier | `none` |
| Service name | `invalid-state-with-none-public-host` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `example-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `invalid-state-with-none-public-host:8080` |
| Firewall intent | `none` |
| Secret dependency | `none` |
| Review notes | `Invalid state must fail even with no public host or port.` |
