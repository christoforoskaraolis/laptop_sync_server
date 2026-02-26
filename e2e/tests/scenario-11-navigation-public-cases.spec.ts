import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-4 – Cases menu – Public Cases loads', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.casesMenu).click();
    await page.locator(Selectors.publicCasesMenuItem).click();
    await expect(
      page.locator(Selectors.backToPrivateCasesButton).or(page.locator('[data-field="CASE_ID"]'))
    ).toBeVisible({ timeout: 10000 });
  });
});
