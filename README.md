# Web App Starter Template

A clean React + Vite + TypeScript starter template with:

- Devcontainer-first development
- Yarn-only workflow (Corepack + locked version)
- Biome lint/format
- Vitest + Testing Library
- Playwright E2E testing
- Optional Docker Compose helpers (Verdaccio, Supabase workflow helper)

---

## Using This Template

This repository is a **GitHub template** for creating new web applications. To use it:

### 1. Create Your Project

Click the **"Use this template"** button on GitHub or:
```bash
# Using GitHub CLI
gh repo create my-awesome-app --template YOUR-ORG/web-app-starter-template --clone
```

### 2. Initial Setup

```bash
cd my-awesome-app
bash scripts/setup.sh  # Installs Yarn via Corepack
yarn dev               # Start development server
```

### 3. Customize for Your Project

**Critical**: Follow the customization checklist to make this template your own:

1. Read `docs/TEMPLATE_CUSTOMIZATION.md` (detailed step-by-step guide)
2. Update project identity (name, description, branding)
3. Configure environment variables (copy `.env.example` to `.env.local`)
4. Replace placeholder content (home page, routes, etc.)
5. Verify customization: `yarn template:verify` (should pass)

### 4. Template Hygiene

The template includes **automatic placeholder detection**:

```bash
yarn template:verify
```

This catches common mistakes:
- `CHANGEME` or `PLACEHOLDER` in code
- `YOUR-PROJECT-NAME` in configs
- Generic domains like `example.com`
- Unfinished `TODO: customize` comments

**Goal**: Ensure your project doesn't ship with generic template values.

---

## Quick Start

1. Use this repository as a template.
2. Clone your new repository.
3. Run setup:

```bash
bash scripts/setup.sh
yarn dev
```

## Scripts

- `yarn dev` - Start Vite dev server
- `yarn build` - Build production output
- `yarn preview` - Preview production build
- `yarn test` - Run unit tests
- `yarn test:e2e` - Run E2E tests (headless)
- `yarn test:e2e:ui` - Run E2E tests in UI mode
- `yarn test:e2e:debug` - Debug E2E tests
- `yarn test:e2e:codegen` - Generate E2E tests
- `yarn lint` - Run Biome checks
- `yarn format` - Format with Biome
- `yarn typecheck` - TypeScript no-emit check
- `yarn check` - Full local check (`typecheck`, `lint`, `test`, `build`)
- `yarn template:verify` - Verify template hygiene rules

## Devcontainer

See `.devcontainer/README.md` and `docs/DEVCONTAINER.md`.

## Customization

See `docs/TEMPLATE_CUSTOMIZATION.md` for the complete post-template checklist.
