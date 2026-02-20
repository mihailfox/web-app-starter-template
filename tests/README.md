# Testing Guide

This template includes two types of tests:

## Unit Tests (Vitest)

Located in `src/` alongside components.

**Run unit tests:**
```bash
yarn test           # Run once
yarn test:watch     # Watch mode
```

**Writing unit tests:**
- Use Testing Library for React components
- Test user interactions and component behavior
- Mock external dependencies
- Keep tests close to implementation (`ComponentName.test.tsx`)

**Example:**
```typescript
import { render, screen } from '@testing-library/react';
import { MyComponent } from './MyComponent';

test('renders correctly', () => {
  render(<MyComponent />);
  expect(screen.getByText('Hello')).toBeInTheDocument();
});
```

## E2E Tests (Playwright)

Located in `tests/e2e/`.

**Run E2E tests:**
```bash
yarn test:e2e              # Run all E2E tests
yarn test:e2e:ui           # Interactive UI mode
yarn test:e2e:debug        # Debug with Playwright Inspector
yarn test:e2e:headed       # Run in headed mode (see browser)
yarn test:e2e:report       # View HTML report
yarn test:e2e:codegen      # Generate tests by recording actions
```

**Writing E2E tests:**
- Test complete user workflows
- Use semantic locators (getByRole, getByText)
- Group related tests in describe blocks
- Keep tests independent (no shared state)

**Example:**
```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password');
    await page.getByRole('button', { name: 'Login' }).click();
    await expect(page).toHaveURL('/dashboard');
  });
});
```

## Test Strategy

**Use unit tests for:**
- Component logic and rendering
- Utility functions
- State management
- Fast feedback during development

**Use E2E tests for:**
- Critical user journeys
- Multi-page workflows
- Integration between components
- Real browser behavior

## CI/CD

Both unit and E2E tests run in CI on every push and PR.

**View test results:**
- Unit tests: Show in CI logs
- E2E tests: HTML report uploaded as artifact
- E2E failures: Traces uploaded for debugging

**Download traces:**
1. Go to failed CI run
2. Download `playwright-traces` artifact
3. Visit https://trace.playwright.dev/
4. Drag and drop trace file

## Best Practices

1. **Keep tests independent**: Each test should work in isolation
2. **Use page objects**: Extract common page interactions
3. **Avoid waits**: Use auto-waiting features
4. **Test user behavior**: Focus on what users do, not implementation
5. **Run locally**: Always run tests before pushing

## Resources

- [Playwright Docs](https://playwright.dev/)
- [Testing Library Docs](https://testing-library.com/)
- [Vitest Docs](https://vitest.dev/)
