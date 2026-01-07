# Data Aggregator

## Endpoints

- `/`: prints welcome message
- `/logs`: collects logs from Loki of the last 15 minutes and returns them in Json format

## Development Environment

Starting the development environment with

```bash
devenv shell
uv run fastapi dev src/main.py
```

`deven.nix` defines the python version, enables uv, starts the monitoring system and sets the Loki Url as an environment variable.

## Building Runtime Image

Docker images can be generated using Nix by running

```bash
nix-build runtime-image.nix
```

The idea was to use the same definition of dependencies used in uv for development and in production.
However, it does not seem to be possible to download the required dependencies in that build step (by design).
There is a project [uv2nix](https://github.com/pyproject-nix/uv2nix) that supposedly solved that.
