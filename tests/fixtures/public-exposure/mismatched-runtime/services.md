# Service Contract

## Service Records

### Demo Web

| Field | Value |
| --- | --- |
| Route identifier | `demo-web` |
| Service name | `Demo Web` |
| Runtime | `K3s` |
| Host or cluster placement | `edge-01` |
| Public host or port | `demo.example.invalid` |
| Protocol | `https` |
| Proxy or direct-port routing | `Caddy` |
| Internal target | `demo-web:8080` |
| Firewall intent | `allow from internet` |
| Secret dependency | `none` |
| Review notes | `Fixture route for validator tests.` |
