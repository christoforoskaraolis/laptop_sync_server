import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-12 – Back from case detail to list', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.casesMenu).click();
    await page.locator(Selectors.publicCasesMenuItem).click();
    await page.waitForTimeout(1000);
    const caseLink = page.locator(Selectors.firstCaseIdLink).first();
    await expect(caseLink).toBeVisible({ timeout: 10000 });
    await caseLink.click();
    await expect(page.locator(Selectors.backToPrivateCasesButton)).toBeVisible({ timeout: 8000 });
    await page.locator(Selectors.backToPrivateCasesButton).click();
    await expect(page.locator(Selectors.privateCasesTitle)).toBeVisible({ timeout: 10000 });
  });
});
