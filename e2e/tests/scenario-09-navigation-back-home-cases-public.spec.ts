import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P0 critical @p0', () => {
  test('P0-2 – Back to Home, Cases menu, Public Cases, open case, Back to Private Cases', async ({
    page,
  }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.backToHome).click();
    await page.waitForTimeout(500);
    await page.locator(Selectors.casesMenu).click();
    await page.locator(Selectors.publicCasesMenuItem).click();
    await page.waitForTimeout(1000);
    const caseLink = page.locator(Selectors.firstCaseIdLink).first();
    if (await caseLink.isVisible().catch(() => false)) {
      await caseLink.click();
      await page.waitForTimeout(500);
    }
    await page.locator(Selectors.backToPrivateCasesButton).click();
    await expect(page.locator(Selectors.privateCasesTitle)).toBeVisible({ timeout: 10000 });
  });
});
