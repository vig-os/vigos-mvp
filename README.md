# Logging Setup

## Start Up Logging System

```bash
docker compose up -d
```

### Components

| Name    | Endpoint                           | Function                     | Documentation                            |
| ------- | ---------------------------------- | ---------------------------- | ---------------------------------------- |
| Traefik | http://localhost/traefik/dashboard | Reverse Proxy                | https://traefik.io                       |
| Grafana | http://localhost/grafana           | Log and Metric Visualization | https://grafana.com/docs/grafana/latest/ |
| Loki    | http://localhost:3100              | Log Server                   | https://grafana.com/docs/loki/latest/    |
| Alloy   | http://localhost:12345             | Log Collector                | https://grafana.com/docs/alloy/latest/   |

## Reproducible Development Environment Devenv

Setup the local development environment using [Devenv](https://devenv.sh)

```bash
vigos-mvp
├── docker-compose.yml           # Docker entrypoint for all services
├── README.md
├── services                     # Folder containing all implemented services
│   └── aggregator
│       ├── devenv.lock
│       ├── devenv.nix           # Devenv config for single service
│       ├── devenv.yaml
│       ├── pyproject.toml
│       ├── README.md
│       ├── runtime-image.nix    # Nix config to build a production container image
│       ├── src
│       └── uv.lock              # uv.lock for this specific project
├── shared
│   └── devenv.nix               # Shared configuration
│   └── devenv.yaml              # Shared configuration
```

### Build Dev Container

```bash
cd shared
devenv container build shell
```

### Starting a services in dev mode

```bash
cd services/aggregator
devenv shell
uv run fastapi dev src/main.py
```
