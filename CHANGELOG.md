# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Template maintenance guide (`docs/TEMPLATE_MAINTENANCE.md`)
- Example configuration file with placeholders (`src/config/example.ts`)
- Yarn 4 caching documentation in template maintenance guide

### Changed
- Updated template hygiene verification to use placeholder-focused patterns
- Enhanced documentation for both template maintainers and downstream users
- Improved `docs/TEMPLATE_CUSTOMIZATION.md` with hygiene verification step
- Upgraded CI workflow to use `actions/cache@v5` for Yarn dependencies

### Fixed
- CI workflow Yarn version mismatch by enabling Corepack before cache operations
- Cache detection now properly uses Yarn 4's cache directory
- Removed built-in setup-node cache in favor of manual Yarn 4 caching

## [0.1.0] - 2026-02-20

### Added
- Initial template with React 18 + Vite 7 + TypeScript 5
- Devcontainer setup with Node 24, Docker, GitHub CLI
- Biome for linting and formatting
- Vitest + Testing Library for unit tests
- Yarn 4 (Berry) via Corepack for package management
- Supabase local development setup (Postgres 17, Auth, Storage, Realtime)
- Verdaccio optional service for private npm registry
- GitHub Actions CI pipeline (typecheck, lint, test, build)
- Template hygiene verification script
- Comprehensive documentation (README, AGENTS, DEVCONTAINER, CUSTOMIZATION)
- Dynamic workspace mounting (supports both bind mounts and container volumes)
- Auto-start for Supabase and optional Verdaccio services
- Path aliases (`@/*` for `src/*`)
- Strict TypeScript configuration with project references
- Example component structure (App, AppShell, HomePage)
- Lighthouse workflow for performance auditing

### Infrastructure
- Custom devcontainer features: CLI tools, Supabase CLI, UV
- Devcontainer lifecycle scripts (onCreate, postCreate, postStart, updateContent)
- Docker Compose with optional service profiles
- Port forwarding for all development services (Vite, Supabase, Verdaccio)

[Unreleased]: https://github.com/YOUR-ORG/web-app-starter-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/YOUR-ORG/web-app-starter-template/releases/tag/v0.1.0
