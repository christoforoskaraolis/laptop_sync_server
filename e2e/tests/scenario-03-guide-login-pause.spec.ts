import { test } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Guide – login then pause', () => {
  test('Login then pause for guidance', async ({ page }) => {
    await loginAsAdmin(page);
    await page.locator(Selectors.globalSearch).first().click();
    await page.pause();
  });
});
