import { Page } from '@playwright/test';
import { Selectors } from './selectors';

const appUrl = (process.env.BASE_URL || 'https://ilrnafvgqa01/fv-web-app/').replace(/\/$/, '');
// Login: always use username admin and password admin4
const username = 'admin';
const password = 'admin4';

/**
 * Log in to FV with configured credentials. Navigates to app URL then signs in.
 */
export async function loginAsAdmin(page: Page): Promise<void> {
  await page.goto(appUrl + '/');
  await page.locator(Selectors.signInLegend).waitFor({ state: 'visible', timeout: 15000 });
  await page.locator(Selectors.usernameInput).fill(username);
  await page.locator(Selectors.passwordInput).fill(password);
  await page.locator(Selectors.signInButton).click();
  await page.locator(Selectors.userMenuLabel).waitFor({ state: 'visible', timeout: 30000 });
}

/**
 * Check if the current page shows the Sign In screen.
 */
export async function isLoginPage(page: Page): Promise<boolean> {
  return page.locator(Selectors.signInLegend).isVisible().catch(() => false);
}

/**
 * Check if user is logged in (user menu visible).
 */
export async function isLoggedIn(page: Page): Promise<boolean> {
  return page.locator(Selectors.userMenuLabel).isVisible().catch(() => false);
}
