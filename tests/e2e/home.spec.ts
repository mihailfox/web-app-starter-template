import { test, expect } from "@playwright/test";

test.describe("Home Page", () => {
	test("should display the app title and welcome message", async ({ page }) => {
		// Navigate to home page
		await page.goto("/");

		// Check that the app shell header is visible
		await expect(
			page.getByRole("heading", { name: "Web App Starter" }),
		).toBeVisible();

		// Check that the welcome heading is visible
		await expect(page.getByRole("heading", { name: "Welcome" })).toBeVisible();

		// Check that the description text is present
		await expect(page.getByText(/minimal starter template/i)).toBeVisible();
	});

	test("should have correct page title", async ({ page }) => {
		await page.goto("/");

		// Check document title
		await expect(page).toHaveTitle("Web App Starter");
	});

	test("should navigate to home from any route", async ({ page }) => {
		// Go to a non-existent route first
		await page.goto("/non-existent-route");

		// Should still show the app shell (no error page configured yet)
		await expect(
			page.getByRole("heading", { name: "Web App Starter" }),
		).toBeVisible();
	});
});
