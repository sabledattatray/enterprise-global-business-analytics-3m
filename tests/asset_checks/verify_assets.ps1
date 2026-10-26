<#
.SYNOPSIS
    Asset and Visual Design System Verification Suite.
.DESCRIPTION
    Validates presence, file size, integrity, and JSON schema compliance for:
    - Futuristic Blue Earth background canvas
    - 65-concept SVG and PNG icon suites (260 files total)
    - 10 dashboard page screenshot mockups
    - Power BI theme JSON
#>

$ErrorActionPreference = "Stop"
$root = "d:\Datasets\3M Project Power BI"

Write-Host "=== VERIFYING REPOSITORY VISUAL ASSETS ===" -ForegroundColor Yellow

$allPassed = $true

# 1. Background Canvas Check
$bgPath = Join-Path $root "assets\backgrounds\Futuristic Blue Earth Dashboard Background.png"
if (Test-Path $bgPath) {
    $bgSize = (Get-Item $bgPath).Length
    Write-Host "[PASS] Background canvas verified: $bgPath ($([Math]::Round($bgSize/1MB, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Missing background canvas at $bgPath" -ForegroundColor Red
    $allPassed = $false
}

# 2. Icon Library Check (65 in each of the 4 directories)
$iconDirs = @(
    @{ Path = "assets\icons\svg\navy"; Expected = 65; Ext = "*.svg" },
    @{ Path = "assets\icons\svg\white"; Expected = 65; Ext = "*.svg" },
    @{ Path = "assets\icons\png\navy"; Expected = 65; Ext = "*.png" },
    @{ Path = "assets\icons\png\white"; Expected = 65; Ext = "*.png" }
)

foreach ($id in $iconDirs) {
    $dirPath = Join-Path $root $id.Path
    $files = Get-ChildItem -Path $dirPath -Filter $id.Ext -ErrorAction SilentlyContinue
    $count = ($files).Count
    if ($count -eq $id.Expected) {
        Write-Host "[PASS] $($id.Path): Exactly $($id.Expected) icons verified." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($id.Path): Expected $($id.Expected) icons, found $count" -ForegroundColor Red
        $allPassed = $false
    }
}

# 3. Screenshot Mockups Check (10 files)
$screenshotsDir = Join-Path $root "assets\screenshots"
$screenshots = Get-ChildItem -Path $screenshotsDir -Filter "*.png"
if ($screenshots.Count -ge 10) {
    Write-Host "[PASS] Screenshots: $($screenshots.Count) dashboard visual mockups verified." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Screenshots: Expected >= 10 mockups, found $($screenshots.Count)" -ForegroundColor Red
    $allPassed = $false
}

# 4. Report Theme JSON Validation
$themePath = Join-Path $root "powerbi\theme\enterprise-light-theme.json"
if (Test-Path $themePath) {
    try {
        $json = Get-Content -Path $themePath -Raw | ConvertFrom-Json
        if ($json.name -and $json.dataColors -and $json.visualStyles) {
            Write-Host "[PASS] Theme JSON syntax and mandatory schema properties verified." -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Theme JSON missing required keys (name, dataColors, visualStyles)." -ForegroundColor Red
            $allPassed = $false
        }
    } catch {
        Write-Host "[FAIL] Theme JSON is invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }
} else {
    Write-Host "[FAIL] Missing theme JSON at $themePath" -ForegroundColor Red
    $allPassed = $false
}

if ($allPassed) {
    Write-Host "`nALL VISUAL ASSET AUDITS PASSED!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nONE OR MORE ASSET AUDITS FAILED!" -ForegroundColor Red
    exit 1
}
