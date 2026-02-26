import { test, expect } from '@playwright/test';
import { Selectors } from '../selectors';

const APP_URL = process.env.BASE_URL?.replace(/\/$/, '') || 'https://ilrnafvgqa01/fv-web-app';

test.describe('Smoke @smoke', () => {
  test('S1 – Application loads and login page is visible', async ({ page }) => {
    await page.goto(APP_URL + '/');
    await expect(page).toHaveURL(/fv-web-app/);
    await expect(page.locator(Selectors.signInLegend)).toBeVisible({ timeout: 15000 });
  });
});
