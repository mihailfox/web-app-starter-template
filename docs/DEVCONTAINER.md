# Devcontainer Guide

## Included
- Node 24 (custom Dockerfile)
- Corepack + Yarn package manager workflow
- Docker CLI access inside container
- GitHub CLI
- Optional Verdaccio service
- Optional Supabase workflow helper service

## Lifecycle Scripts
- `on-create.sh`: base tool bootstrap
- `update-content.sh`: dependency install (`yarn install --immutable`)
- `post-create.sh`: registry wiring + optional Playwright browser install

## Optional Services

```bash
scripts/devcontainer/optional-services.sh up verdaccio
scripts/devcontainer/optional-services.sh up supabase
scripts/devcontainer/optional-services.sh status
scripts/devcontainer/optional-services.sh down all
```

## Troubleshooting
- If dependencies fail, verify `package.json#packageManager` is `yarn@<version>`, then run `corepack enable`.
- If Verdaccio is down, scripts automatically fall back to npmjs.
- If Docker commands fail, ensure Docker socket sharing is enabled.
