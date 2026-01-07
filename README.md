
# Logging Setup

## Start up

```bash
docker compose up -d
```

## Components

| Name    | Endpoint                   | Function                     | Documentation                            |
|---------|----------------------------|------------------------------|------------------------------------------|
| Traefik | http://localhost/dashboard | Reverse Proxy                | https://traefik.io                       |
| Grafana | http://localhost/grafana   | Log and Metric Visualization | https://grafana.com/docs/grafana/latest/ |
| Loki    | http://localhost/loki      | Log Server                   | https://grafana.com/docs/loki/latest/    |
| Alloy   | http://localhost:12345     | Log Collector                | https://grafana.com/docs/alloy/latest/   |

