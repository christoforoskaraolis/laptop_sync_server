import { test, expect } from '@playwright/test';
import { Selectors } from '../selectors';

const APP_URL = process.env.BASE_URL?.replace(/\/$/, '') || 'https://ilrnafvgqa01/fv-web-app';

test.describe('Login – P1 high @p1', () => {
  test('P1-2 – Empty username shows validation or error', async ({ page }) => {
    await page.goto(APP_URL + '/');
    await page.locator(Selectors.passwordInput).fill('admin4');
    await page.locator(Selectors.signInButton).click();
    await expect(page.locator(Selectors.signInLegend)).toBeVisible({ timeout: 5000 });
    await expect(page.locator(Selectors.userMenuLabel)).not.toBeVisible();
  });
});
