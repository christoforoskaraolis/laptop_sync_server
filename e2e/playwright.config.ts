import { defineConfig, devices } from '@playwright/test';
import path from 'path';
import { config as loadEnv } from 'dotenv';

// Load .env from e2e folder or project root
loadEnv({ path: path.join(__dirname, '.env') });
loadEnv({ path: path.join(__dirname, '..', '.env') });

const baseURL = (process.env.BASE_URL || 'https://ilrnafvgqa01/fv-web-app/').replace(/\/$/, '');

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'playwright-report/results.json' }],
  ],
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    // Uncomment to run on more browsers:
    // { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    // { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  timeout: 60_000,
});
