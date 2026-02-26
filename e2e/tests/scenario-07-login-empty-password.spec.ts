import { test, expect } from '@playwright/test';
import { Selectors } from '../selectors';

const APP_URL = process.env.BASE_URL?.replace(/\/$/, '') || 'https://ilrnafvgqa01/fv-web-app';

test.describe('Login – P1 high @p1', () => {
  test('P1-2b – Empty password shows validation or error', async ({ page }) => {
    await page.goto(APP_URL + '/');
    await page.locator(Selectors.usernameInput).fill('admin');
    await page.locator(Selectors.signInButton).click();
    await expect(page.locator(Selectors.signInLegend)).toBeVisible({ timeout: 5000 });
    await expect(page.locator(Selectors.userMenuLabel)).not.toBeVisible();
  });
});
