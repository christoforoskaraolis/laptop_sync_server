import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Login – P1 high @p1', () => {
  test('P1-7 – Page refresh after login keeps session or shows re-login', async ({ page }) => {
    await loginAsAdmin(page);
    await page.reload();
    const stillLoggedIn = await page.locator(Selectors.userMenuLabel).isVisible().catch(() => false);
    const backToLogin = await page.locator(Selectors.signInLegend).isVisible().catch(() => false);
    expect(stillLoggedIn || backToLogin).toBeTruthy();
  });
});
