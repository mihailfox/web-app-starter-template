# Template Customization Checklist

Use this checklist right after creating a new repository from this template.

## 0. Template Hygiene Verification (Do This First!)

Before starting development, verify the template was cloned cleanly:

```bash
# Run template hygiene check
yarn template:verify
```

**Expected result**: Should **PASS** with message "Template hygiene check passed."

**If it fails:**
- Review the listed violations carefully
- These are placeholder patterns you should customize (e.g., `CHANGEME`, `YOUR-PROJECT-NAME`)
- Fix each violation by replacing with your project-specific values
- Re-run `yarn template:verify` until it passes

**Note**: Some files like `src/config/example.ts` are intentionally excluded and contain placeholders as examples. You should:
1. Copy `example.ts` to a new file (e.g., `config.ts`)
2. Customize the new file for your project
3. Delete or ignore the example file

**Why this matters:**
- Ensures you don't ship placeholder values to production
- Catches common customization mistakes early
- Validates your project is properly configured

Once hygiene check passes, proceed with the sections below.

## 1. Project Identity
- Update `package.json` name and version.
- Update `README.md` with project purpose and architecture.
- Replace default app title/text in `src/`.

## 2. Environment
- Copy `.env.example` to `.env.local`.
- Set app URL and backend URL variables.
- Add any project-specific keys only in local/secret stores.

## 3. Application Skeleton
- Add real routes in `src/App.tsx`.
- Replace sample `HomePage` with product pages.
- Add domain modules under `src/features` as needed.

## 4. Tooling and Quality
- Keep `package.json#packageManager` pinned to Yarn (`yarn@<version>`).
- Run `bash scripts/setup.sh` after cloning to provision the exact Yarn version.
- Run `yarn check`.
- Expand tests beyond the starter smoke test:
  - Unit tests in `src/**/*.test.tsx` (Vitest + Testing Library)
  - E2E tests in `tests/e2e/**/*.spec.ts` (Playwright)
  - See `tests/README.md` for testing guide
- Tune Biome rules for your team if needed.

## 5. CI/CD
- Adjust `.github/workflows/ci.yml` for your needs.
- Replace `deploy-template.yml` with your actual deploy workflow.
- Configure required repository secrets.

## 6. Devcontainer
- Rebuild container after major dependency changes.
- Enable optional services only when needed:
  - `scripts/devcontainer/optional-services.sh up verdaccio`
  - `scripts/devcontainer/optional-services.sh up supabase`
