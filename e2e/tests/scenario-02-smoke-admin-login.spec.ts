import { test, expect } from '@playwright/test';
import { Selectors } from '../selectors';

const APP_URL = process.env.BASE_URL?.replace(/\/$/, '') || 'https://ilrnafvgqa01/fv-web-app';

test.describe('Smoke @smoke', () => {
  test('S2 – User opens app, signs in with admin/admin4, and is logged in', async ({ page }) => {
    await page.goto(APP_URL + '/');
    await expect(page.locator(Selectors.signInLegend)).toBeVisible({ timeout: 15000 });
    await page.locator(Selectors.usernameInput).fill('admin');
    await page.locator(Selectors.passwordInput).fill('admin4');
    await page.locator(Selectors.signInButton).click();
    await expect(page.locator(Selectors.userMenuLabel)).toBeVisible({ timeout: 15000 });
    await expect(page.locator(Selectors.userMenuLabel)).toContainText('admin');
  });
});
