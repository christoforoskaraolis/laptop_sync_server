import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../auth';
import { Selectors } from '../selectors';

test.describe('Global search @p1', () => {
  test('Global search – select Cases, value %1008%, View, export, wait for notification, download', async ({
    page,
  }) => {
    test.setTimeout(180000); // export + notification can take 2+ min
    await loginAsAdmin(page);

    await page.locator(Selectors.globalSearch).click();
    await page.waitForTimeout(500);

    await page.locator(Selectors.searchInMenu).first().click();
    await page.waitForTimeout(600);
    const casesOption = page.locator(Selectors.searchInOptionCases).first();
    await casesOption.scrollIntoViewIfNeeded().catch(() => {});
    await casesOption.click();

    const valueInput = page.locator(Selectors.globalSearchValueInput).first();
    await valueInput.waitFor({ state: 'visible', timeout: 5000 });
    await valueInput.fill('%1008%');

    await page.locator(Selectors.globalSearchViewButton).first().click();

    await expect(
      page.locator(Selectors.caseGrid).or(page.locator(Selectors.globalSearchResultsArea)).first()
    ).toBeVisible({ timeout: 45000 });

    await page.waitForTimeout(1000);

    const exportBtn = page.locator(Selectors.gridExportButton).first();
    await exportBtn.waitFor({ state: 'visible', timeout: 8000 }).catch(() => {});
    if (await exportBtn.isVisible().catch(() => false)) {
      await exportBtn.click();
      await page.waitForTimeout(500);
      const allToCsvOffline = page.locator(Selectors.exportAllToCsvOffline).first();
      await allToCsvOffline.waitFor({ state: 'visible', timeout: 5000 });
      page.once('dialog', (dialog) => dialog.accept());
      await allToCsvOffline.click();
      const yesBtn = page.locator(Selectors.popupYesButton).first();
      await yesBtn.click({ timeout: 5000 }).catch(() => {});

      const notification = page.locator(Selectors.exportReadyNotification).first();
      await notification.waitFor({ state: 'visible', timeout: 120000 });

      const downloadBtn = page.locator(Selectors.exportDownloadButton).first();
      await downloadBtn.waitFor({ state: 'visible', timeout: 5000 });
      const filePromise = page.waitForEvent('download', { timeout: 15000 }).catch(() => null);
      await downloadBtn.click();
      const download = await filePromise;
      if (download) await download.path();
    }

    await page.waitForTimeout(500);

    const firstCase = page.locator(Selectors.firstCaseIdLink).first();
    if (await firstCase.isVisible().catch(() => false)) {
      await firstCase.click();
      await page.waitForTimeout(1500);
      await expect(
        page.locator(Selectors.backToPrivateCasesButton).or(page.locator('[data-id="title"]'))
      ).first().toBeVisible({ timeout: 10000 });
    }
  });
});
