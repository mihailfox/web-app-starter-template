# Template Maintenance Guide

This guide is for **maintainers of the template source repository**. If you're using this template to create a new project, see `TEMPLATE_CUSTOMIZATION.md` instead.

---

## Template Philosophy

This repository serves as a **GitHub template** for creating new web applications. It must remain:
- **Generic and reusable** across different projects
- **Free of organization-specific assumptions**
- **Easy to customize** for downstream users
- **Self-documenting** with clear examples

---

## Hygiene Rules

### ✅ Template SHOULD Contain

**Generic identifiers:**
- `web-app-starter-template` (package name, project ID)
- `Web App Starter` (display name)
- Environment variable placeholders: `VITE_APP_NAME`, `VITE_API_BASE_URL`

**Dynamic configurations:**
- `${localWorkspaceFolderBasename}` for paths
- Environment-based defaults: `import.meta.env.VITE_*`
- Localhost URLs for local development

**Example patterns:**
- Commented code with clear examples
- `src/config/example.ts` with intentional placeholders
- Documentation showing customization steps

### ❌ Template SHOULD NOT Contain

**Organization-specific:**
- Real company names: `acme-corp`, `mycompany-inc`
- Hardcoded domains: `myapp.io`, `staging.acmecorp.com`
- Deployment hosts: `vercel.com/myorg`, `app.netlify.com/myteam`

**Credentials or secrets:**
- API keys, tokens, passwords
- Personal identifiers in code/comments
- Real database connection strings

**Unfinished customization:**
- `CHANGEME` without context
- `TODO: customize` without explanation
- `PLACEHOLDER` in production code

---

## Development Workflow

### 1. Feature Development

**Branch naming:**
- `feature/auth-example` - New feature additions
- `fix/devcontainer-mount` - Bug fixes
- `docs/api-guide` - Documentation updates
- `devcontainer` - Devcontainer improvements (current branch)

**Development cycle:**
```bash
# Create feature branch
git checkout -b feature/my-enhancement

# Make changes
# ...

# Test locally
yarn check                # Full quality suite
yarn template:verify      # Hygiene check
```

### 2. Testing as Template

**Critical**: Always test the template creation flow before releasing:

```bash
# On GitHub:
# 1. Use "Use this template" button
# 2. Create test repository: `test-template-usage`

# Clone and test:
git clone <test-repo>
cd test-repo
bash scripts/setup.sh
yarn dev

# Follow customization guide
# Verify all steps in docs/TEMPLATE_CUSTOMIZATION.md

# Confirm hygiene check works
yarn template:verify  # Should pass initially
# Add a CHANGEME somewhere
yarn template:verify  # Should fail and detect it
```

### 3. Release Process

**Before merging to main:**
- [ ] All tests pass: `yarn check`
- [ ] Template hygiene passes: `yarn template:verify`
- [ ] Fresh devcontainer rebuild works
- [ ] Created test repo from template successfully
- [ ] Updated `CHANGELOG.md` with changes
- [ ] Bumped version in `package.json` (if releasing)

**Merging:**
```bash
git checkout main
git merge feature/my-enhancement
git tag -a v1.1.0 -m "Release 1.1.0: Description"
git push origin main --tags
```

---

## Hygiene Verification Explained

The `yarn template:verify` script (`scripts/verify-template.sh`) scans for patterns that indicate **unfinished customization** in downstream projects.

### Forbidden Patterns

| Pattern | Why Forbidden | Example Violation |
|---------|---------------|-------------------|
| `CHANGEME` | Explicit placeholder | `API_KEY=CHANGEME` |
| `YOUR-PROJECT-NAME` | Uncustomized name | `title: "YOUR-PROJECT-NAME"` |
| `YOUR-ORG-NAME` | Uncustomized org | `author: "YOUR-ORG-NAME"` |
| `example.com` | Generic domain | `domain: example.com` (except robots.txt) |
| `acme-corp` | Placeholder company | `organization: "acme-corp"` |
| `TODO: customize` | Unfinished work | `// TODO: customize this` |
| `FIXME: template` | Unfinished template | `/* FIXME: template needs update */` |

### Allowed Patterns (Template's Own Names)

| Pattern | Why Allowed | Example Usage |
|---------|-------------|---------------|
| `web-app-starter-template` | Template's identifier | `"name": "web-app-starter-template"` |
| `Web App Starter` | Template's display name | `<h1>Web App Starter</h1>` |
| `localhost` | Local dev URLs | `VITE_APP_URL=http://localhost:5173` |

### Excluded Files

Some files **intentionally** contain forbidden patterns as examples:
- `src/config/example.ts` - Example configuration file
- `scripts/verify-template.sh` - The verification script itself

These are excluded from scanning via `--glob !` patterns.

---

## Versioning Strategy

Follow [Semantic Versioning](https://semver.org/) for template releases:

### Version Numbers

**Format**: `MAJOR.MINOR.PATCH` (e.g., `v1.2.3`)

**Increment rules:**
- **MAJOR** (v2.0.0): Breaking changes requiring downstream migration
  - Example: Changed directory structure, removed features
- **MINOR** (v1.1.0): New features, enhanced tooling (backward compatible)
  - Example: Added dark mode support, new component examples
- **PATCH** (v1.0.1): Bug fixes, documentation updates
  - Example: Fixed typo in docs, corrected config example

### Tagging Releases

```bash
# After merging to main
git checkout main
git pull origin main

# Update version
vim package.json  # Bump "version" field
git add package.json
git commit -m "chore: bump version to 1.2.0"

# Create annotated tag
git tag -a v1.2.0 -m "Release 1.2.0

- Added feature X
- Fixed bug Y
- Updated documentation Z"

# Push
git push origin main --tags
```

### Changelog Maintenance

Update `CHANGELOG.md` before each release:

```markdown
## [1.2.0] - 2026-03-15

### Added
- Dark mode toggle component
- Example form with validation

### Changed
- Updated devcontainer to Node 25

### Fixed
- TypeScript strict mode errors in tests
```

---

## CI/CD for Template

The template's CI pipeline (`.github/workflows/ci.yml`) ensures quality:

### Checks Performed

1. **TypeScript compilation**: `yarn typecheck`
2. **Linting**: `yarn lint` (Biome)
3. **Testing**: `yarn test` (Vitest)
4. **E2E Testing**: `yarn test:e2e` (Playwright)
5. **Build**: `yarn build` (Vite)
6. **Template hygiene**: `yarn template:verify`

All must pass before merge to `main`.

### Trigger Conditions

- **Pull requests** to any branch
- **Pushes** to `main` or `dev` branches

### Manual Workflows

- **Deploy Template Stub**: Placeholder for deployment
- **Lighthouse**: Manual performance audits

### Yarn 4 Caching in CI

The CI workflow uses `actions/cache@v5` to cache Yarn dependencies for faster builds.

**How it works:**
1. Corepack enables Yarn 4 before any caching operations
2. Cache directory is detected dynamically via `yarn config get cacheFolder`
3. Cache key includes OS and yarn.lock hash for precise matching
4. Partial caching via restore-keys speeds up builds when dependencies change

**Cache performance:**
- **Cache hit** (exact match): ~10-25 seconds install time
- **Cache miss** (partial restore): ~20-40 seconds install time
- **No cache** (first run): ~26-51 seconds install time

**Benefits:**
- 2-3x faster builds on cache hits
- ~50% faster with partial cache (after dependency updates)
- Automatic cache invalidation when yarn.lock changes

**Important notes:**
- `actions/cache@v5` requires GitHub Actions Runner **2.327.1+**
- Self-hosted runners must be updated to this version or later
- Cache is scoped to branch (main branch cache available to feature branches)
- Repository can have up to 10GB of caches total

**Troubleshooting:**

If caching fails, check:
1. **Runner version**: Must be `2.327.1+` for actions/cache@v5
2. **Corepack enabled**: Must run before cache operations
3. **yarn.lock committed**: Cache key depends on this file
4. **Cache size**: Ensure total caches don't exceed 10GB limit

**Manual cache management:**
```bash
# List all caches for repository
gh cache list

# Delete specific cache by ID
gh cache delete <cache-id>

# Clear all caches for a branch
gh cache delete --all --branch <branch-name>

# View cache usage
gh api repos/:owner/:repo/actions/cache/usage
```

**Cache behavior:**
- Old caches evicted when 10GB limit reached (LRU policy)
- Caches not accessed in 7 days automatically deleted
- Feature branches can restore from main branch cache
- Cross-OS caching not enabled (Linux cache only on Linux runners)

---

## E2E Testing with Playwright

The template includes **Playwright** for end-to-end testing. This section covers how to maintain and extend E2E tests.

### Architecture

**Test location**: `tests/e2e/**/*.spec.ts`
- Separate from unit tests (`src/**/*.test.tsx`)
- Uses Playwright Test framework
- Runs against dev server (auto-started by Playwright config)

**Configuration**: `playwright.config.ts`
- Single browser: Chromium (fast, easy to extend)
- Auto-starts dev server on `http://localhost:5173`
- Retries: 2 times in CI, 0 locally
- Artifacts: Screenshots/videos on failure, traces in CI
- Reporters: HTML (local), GitHub Actions + HTML (CI)

**TypeScript config**: `tsconfig.e2e.json`
- Separate from app and node configs
- Playwright types included
- Referenced in root `tsconfig.json`

### Available Scripts

```bash
yarn test:e2e           # Run E2E tests (headless)
yarn test:e2e:ui        # Run with Playwright UI (recommended for development)
yarn test:e2e:debug     # Debug mode with Playwright Inspector
yarn test:e2e:headed    # Run in headed mode (see browser)
yarn test:e2e:report    # Open last HTML report
yarn test:e2e:codegen   # Generate tests with Codegen tool
```

### Writing E2E Tests

**Example test structure**:
```typescript
// tests/e2e/feature.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test('should do something', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading')).toHaveText('Expected Text');
  });
});
```

**Best practices**:
- Use semantic selectors: `getByRole`, `getByText`, `getByLabel` (avoid CSS selectors)
- One test file per page/feature
- Use `test.describe()` to group related tests
- Keep tests independent (don't rely on test execution order)
- Use Page Object Model for complex workflows

### CI Integration

E2E tests run automatically in CI (`.github/workflows/ci.yml`):

**Steps:**
1. **Install Playwright browsers**: `yarn playwright install --with-deps chromium`
2. **Run E2E tests**: `yarn test:e2e` (headless, 2 retries)
3. **Upload artifacts**: 
   - HTML report (30-day retention)
   - Traces (7-day retention, failures only)

**Artifacts access**:
- Navigate to failed workflow run
- Click "Artifacts" section
- Download `playwright-report` or `playwright-traces`
- Open traces with `yarn test:e2e:report` or [trace.playwright.dev](https://trace.playwright.dev)

### Adding More Browsers

To test on multiple browsers, edit `playwright.config.ts`:

```typescript
export default defineConfig({
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },    // Uncomment
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },      // Uncomment
  ],
});
```

**CI update required**:
```yaml
# .github/workflows/ci.yml
- name: Install Playwright browsers
  run: yarn playwright install --with-deps  # Remove 'chromium' to install all
```

### Debugging Failed Tests

**Locally**:
```bash
# Run with UI mode (best for debugging)
yarn test:e2e:ui

# Run with inspector
yarn test:e2e:debug

# Run in headed mode
yarn test:e2e:headed
```

**In CI**:
1. Download `playwright-traces` artifact from failed run
2. Unzip and view with: `yarn test:e2e:report`
3. Or upload to [trace.playwright.dev](https://trace.playwright.dev)

### Performance Considerations

**Test speed optimizations**:
- Chromium-only by default (~2x faster than multi-browser)
- Parallel execution enabled (uses all CPU cores)
- Retries only in CI (faster local feedback)
- Screenshots/videos only on failure (saves disk space)

**Typical run times**:
- 3 example tests: ~5-10 seconds (local, headless)
- Same tests in CI: ~15-25 seconds (includes browser install, retries)

### Browser Installation

**Devcontainer**:
- Playwright browsers auto-install on first container build
- Triggered by `.devcontainer/scripts/post-create.sh`
- Uses `PLAYWRIGHT_BROWSERS_PATH` environment variable
- No manual intervention needed

**Manual installation** (if needed):
```bash
yarn playwright install --with-deps chromium
```

### Troubleshooting

**Issue**: Tests fail with "Browser not found"
**Fix**:
```bash
yarn playwright install --with-deps chromium
```

**Issue**: Dev server doesn't start in tests
**Fix**:
- Check port 5173 is available
- Verify `yarn dev` works manually
- Check `playwright.config.ts` webServer config

**Issue**: Flaky tests (intermittent failures)
**Fix**:
- Use `waitFor` assertions: `await expect(locator).toBeVisible()`
- Avoid hard waits: `page.waitForTimeout()` (use auto-waiting instead)
- Increase timeout for slow operations: `{ timeout: 10000 }`

---

## Common Maintenance Tasks

### Adding New Features

**Example: Adding a component library integration**

1. Install dependencies:
   ```bash
   yarn add @radix-ui/react-dialog
   ```

2. Add example usage:
   ```typescript
   // src/components/examples/DialogExample.tsx
   import * as Dialog from '@radix-ui/react-dialog';
   
   export function DialogExample() {
     // Example implementation
   }
   ```

3. Update documentation:
   ```markdown
   # In docs/TEMPLATE_CUSTOMIZATION.md
   ## Optional: UI Components
   - This template includes Radix UI primitives
   - See `src/components/examples/` for usage patterns
   ```

4. Test and verify:
   ```bash
   yarn check
   yarn template:verify
   ```

### Updating Dependencies

**Monthly maintenance:**
```bash
# Check for updates
yarn upgrade-interactive

# Select updates (prefer minor/patch, careful with major)
# Test after updates
yarn check

# Commit
git add yarn.lock package.json
git commit -m "chore: update dependencies"
```

**For breaking changes:**
- Update code to match new APIs
- Document migration steps in CHANGELOG
- Bump MAJOR version if downstream impact

### Refactoring Directory Structure

**If changing structure:**
1. Create migration guide in CHANGELOG
2. Update all documentation references
3. Test template creation flow
4. Bump MAJOR version
5. Consider providing migration script

---

## Troubleshooting

### "Template hygiene check failed" in CI

**Cause**: Forbidden pattern detected in code

**Fix:**
```bash
# Run locally to see violations
yarn template:verify

# Review output, fix violations
# Or add to exclusion list if intentional (example files)
```

### Devcontainer fails to build

**Cause**: Dockerfile or feature installation issues

**Debug:**
```bash
# Check logs
cat .devcontainer/logs/*.log

# Test feature installations
bash .devcontainer/scripts/test-features.sh

# Rebuild from scratch
devcontainer up --remove-existing-container
```

### Yarn version mismatch

**Cause**: Corepack not enabled

**Fix:**
```bash
corepack enable
corepack prepare yarn@4.12.0 --activate
yarn --version  # Should show 4.12.0
```

---

## Questions?

**For template maintainers:**
- See `AGENTS.md` for repository guidelines
- See `.devcontainer/README.md` for devcontainer architecture

**For template users:**
- See `docs/TEMPLATE_CUSTOMIZATION.md` for customization guide
- See `README.md` for quick start instructions
