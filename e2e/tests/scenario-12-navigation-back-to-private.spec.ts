import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-5 – Back to Private Cases shows Private Cases page', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.casesMenu).click();
    await page.locator(Selectors.publicCasesMenuItem).click();
    await page.waitForTimeout(800);
    await page.locator(Selectors.backToPrivateCasesButton).click();
    await expect(page.locator(Selectors.privateCasesTitle)).toBeVisible({ timeout: 10000 });
  });
});
