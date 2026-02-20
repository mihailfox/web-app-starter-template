import path from "node:path";
import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    globals: true,
    exclude: [
      "**/node_modules/**",
      "**/dist/**",
      "**/playwright-report/**",
      "**/test-results/**",
      "**/.{idea,git,cache,output,temp}/**",
      "tests/e2e/**", // Exclude E2E tests (run separately with Playwright)
    ],
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
});
