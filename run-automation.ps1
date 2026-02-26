# Run FV Web automated regression tests (Playwright)
# Usage: .\run-automation.ps1   or   .\run-automation.ps1 -SmokeOnly   or   .\run-automation.ps1 -Headed

param(
    [switch]$SmokeOnly,
    [switch]$Headed
)

$e2ePath = Join-Path $PSScriptRoot "e2e"
if (-not (Test-Path (Join-Path $e2ePath "package.json"))) {
    Write-Error "e2e folder not found. Run from project root."
    exit 1
}

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "Node.js is required. Install from https://nodejs.org and ensure 'node' is in PATH."
    exit 1
}

Push-Location $e2ePath
try {
    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing dependencies..."
        npm install
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        Write-Host "Installing Chromium for Playwright..."
        npx playwright install chromium
    }

    $playwrightArgs = @("test")
    if ($SmokeOnly) { $playwrightArgs += "--grep", "@smoke" }
    if ($Headed)    { $playwrightArgs += "--headed", "--workers=1" }

    Write-Host "Running automated tests..."
    & npx playwright @playwrightArgs
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "Report: open e2e/playwright-report/index.html to view results."
}
exit $exitCode
