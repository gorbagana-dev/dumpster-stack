# Dumpster Stack

Laconic stack orchestrator for the Dumpster Launchpad. Deploys the full stack in one command: Next.js frontend, Bun/Hono backend, PostgreSQL, and Redis.

## Deploy

```bash
export CERC_REPO_BASE_DIR=$(cd .. && pwd)

laconic-so --stack stack-orchestrator/stacks/dumpster build-containers
laconic-so --stack stack-orchestrator/stacks/dumpster deploy init --output spec.yml
laconic-so --stack stack-orchestrator/stacks/dumpster deploy create --spec-file spec.yml --deployment-dir dumpster-deployment
laconic-so deployment --dir dumpster-deployment start
```

Frontend at `http://localhost:3000`, API at `http://localhost:3200`.

See [stack README](stack-orchestrator/stacks/dumpster/README.md) for environment variables and configuration.
