import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-11 – Private Cases menu item loads list', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.casesMenu).click();
    await page.locator(Selectors.privateCasesMenuItem).click();
    await expect(page.locator(Selectors.privateCasesTitle)).toBeVisible({ timeout: 10000 });
  });
});
