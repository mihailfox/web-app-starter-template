/**
 * Example Configuration File
 *
 * This file demonstrates best practices for application configuration.
 *
 * IMPORTANT: This is an EXAMPLE file with placeholder values.
 * To use in your project:
 *   1. Copy this file to `src/config/app.ts` (or your preferred name)
 *   2. Replace all CHANGEME and placeholder values with your project-specific settings
 *   3. Update the TypeScript types to match your needs
 *   4. Delete or ignore this example file
 *
 * NOTE: This file is excluded from template hygiene checks because it's intentionally
 * an example. Your customized config files SHOULD NOT contain CHANGEME markers.
 */

// CHANGEME: Replace these with your actual environment variable names
export const config = {
  /**
   * Application identity
   */
  app: {
    // CHANGEME: Set your application name
    name: import.meta.env.VITE_APP_NAME || "YOUR-PROJECT-NAME",

    // CHANGEME: Set your application URL
    url: import.meta.env.VITE_APP_URL || "http://localhost:5173",

    // Environment (derived from mode)
    env: import.meta.env.MODE,
    isDevelopment: import.meta.env.DEV,
    isProduction: import.meta.env.PROD,
  },

  /**
   * API Configuration
   */
  api: {
    // CHANGEME: Set your API base URL
    baseUrl: import.meta.env.VITE_API_BASE_URL || "http://localhost:3000",

    // TODO: Add your API-specific configuration
    timeout: 30000, // 30 seconds
  },

  /**
   * Supabase Configuration
   * See: https://supabase.com/docs
   */
  supabase: {
    // CHANGEME: Set these from your Supabase project settings
    url: import.meta.env.VITE_SUPABASE_URL || "http://localhost:54321",
    anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY || "",
    // Note: Service role key should NEVER be exposed to the client
  },

  /**
   * Feature Flags
   */
  features: {
    // TODO: Add your feature flags here
    enableAnalytics: import.meta.env.VITE_ENABLE_ANALYTICS === "true",
    enableDebugMode: import.meta.env.VITE_DEBUG === "true" || import.meta.env.DEV,
  },

  /**
   * Third-party integrations
   */
  integrations: {
    // CHANGEME: Add your third-party service configurations
    // Example:
    // analytics: {
    //   id: import.meta.env.VITE_ANALYTICS_ID || '',
    // },
  },
} as const;

/**
 * Type-safe configuration access
 * Usage: import { config } from '@/config/app';
 */
export type Config = typeof config;

/**
 * Validate required configuration at startup
 * Call this in your app entry point (main.tsx) to fail fast on missing config
 */
export function validateConfig(): void {
  const required = [
    { key: "app.name", value: config.app.name },
    { key: "app.url", value: config.app.url },
    { key: "api.baseUrl", value: config.api.baseUrl },
  ];

  const missing = required.filter(({ value }) => !value || value.includes("CHANGEME"));

  if (missing.length > 0) {
    const keys = missing.map(({ key }) => key).join(", ");
    throw new Error(
      `Missing required configuration: ${keys}. ` +
        "Check your .env.local file and ensure all CHANGEME placeholders are replaced.",
    );
  }

  // TODO: Add validation for YOUR-PROJECT-specific required config
  if (config.app.name === "YOUR-PROJECT-NAME") {
    console.warn(
      "Warning: Application is using placeholder name. Update VITE_APP_NAME in .env.local",
    );
  }
}

/**
 * Export individual config sections for convenience
 */
export const { app, api, supabase, features, integrations } = config;
