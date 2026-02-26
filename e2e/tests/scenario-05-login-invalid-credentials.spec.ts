import { test, expect } from '@playwright/test';
import { Selectors } from '../selectors';

const APP_URL = process.env.BASE_URL?.replace(/\/$/, '') || 'https://ilrnafvgqa01/fv-web-app';

test.describe('Login – P1 high @p1', () => {
  test('P1-1 – Invalid credentials show error and do not login', async ({ page }) => {
    await page.goto(APP_URL + '/');
    await page.locator(Selectors.usernameInput).fill('wronguser');
    await page.locator(Selectors.passwordInput).fill('wrongpass');
    await page.locator(Selectors.signInButton).click();
    await expect(page.locator(Selectors.signInLegend)).toBeVisible({ timeout: 10000 });
    await expect(page.locator(Selectors.userMenuLabel)).not.toBeVisible();
  });
});
