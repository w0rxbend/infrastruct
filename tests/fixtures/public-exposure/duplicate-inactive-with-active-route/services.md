# Service Contract

## Service Records

### Demo Web

| Field | Value |
| --- | --- |
| Route identifier | `demo-web` |
| Service name | `Demo Web` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `edge-01` |
| Public host or port | `demo.example.invalid` |
| Protocol | `https` |
| Proxy or direct-port routing | `Caddy` |
| Internal target | `demo-web:8080` |
| Firewall intent | `allow from internet` |
| Secret dependency | `none` |
| Review notes | `Fixture route for validator tests.` |

### Demo Web Draft

| Field | Value |
| --- | --- |
| Exposure state | `planned` |
| Route identifier | `demo-web` |
| Service name | `Demo Web Draft` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `service-draft-node-01` |
| Public host or port | `none` |
| Protocol | `none` |
| Proxy or direct-port routing | `none` |
| Internal target | `demo-web-draft:8080` |
| Firewall intent | `planned rule pending` |
| Secret dependency | `none` |
| Review notes | `Draft collides with the active demo-web route identifier.` |
