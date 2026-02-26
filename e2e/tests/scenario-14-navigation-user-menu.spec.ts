import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Navigation – P1 high @p1', () => {
  test('P1-8 – User menu opens and shows username', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.userMenuLabel).click();
    await page.waitForTimeout(400);
    await expect(page.locator(Selectors.userMenuLabel)).toContainText('admin');
  });
});
