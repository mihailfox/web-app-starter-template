# Repository Guidelines - Web App Starter Template

## Overview
This repository is a generic engineering starter template for modern web applications.

## Core Stack
- React + Vite + TypeScript
- Biome for linting/formatting
- Vitest + Testing Library for tests
- Devcontainer-based local development

## Directory Conventions
- `src/` application code
- `.devcontainer/` development container template
- `scripts/` automation and utility scripts
- `.github/workflows/` generic CI/CD workflow stubs
- `docs/` template and onboarding documentation

## Coding Standards
- Use TypeScript for source files.
- Keep imports ordered: external packages, aliases, relative.
- Prefer small, composable components and hooks.
- Keep tests adjacent to source or in clear test entrypoints.

## Development Commands
- `yarn dev`
- `yarn test`
- `yarn lint`
- `yarn build`
- `yarn check`

## Template Safety
Do not introduce hardcoded organization-specific names, domains, or deployment hosts.
Use `yarn template:verify` before merging.

## CI Policy
Keep CI generic and provider-agnostic by default.
Deployment workflows must remain template stubs unless intentionally specialized by downstream consumers.
