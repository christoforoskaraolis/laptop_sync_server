import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Login – P0 critical @p0', () => {
  test('P0-1 – Admin login end-to-end', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page.locator(Selectors.userMenuLabel)).toContainText('admin');
  });
});
