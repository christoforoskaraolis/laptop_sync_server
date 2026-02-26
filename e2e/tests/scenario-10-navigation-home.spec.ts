import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-3 – Home navigation from inner screen', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.backToHome).click();
    await expect(page.locator(Selectors.signInLegend)).not.toBeVisible();
  });
});
