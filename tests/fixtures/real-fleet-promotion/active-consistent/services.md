# Service Contract

## Service Records

### Demo Web

| Field | Value |
| --- | --- |
| Exposure state | `active` |
| Route identifier | `demo-web` |
| Service name | `Demo Web` |
| Runtime | `Docker Compose` |
| Host or cluster placement | `lab-node-01` |
| Public host or port | `demo.example.invalid` |
| Protocol | `https` |
| Proxy or direct-port routing | `Caddy` |
| Internal target | `demo-web:8080` |
| Firewall intent | `allow from internet` |
| Secret dependency | `none` |
| Review notes | `Fake active exposure for promotion rehearsal.` |
