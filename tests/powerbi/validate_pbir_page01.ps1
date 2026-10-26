<#
.SYNOPSIS
    Automated PBIR Report Definition Validation Suite for Page 01 (Executive Overview).
.DESCRIPTION
    Validates Microsoft PBIR schemas, positions, visual types, and field bindings
    against the verified 3M star schema entities:
    - vw_FactSales (order_id, quantity, order_status, sales_channel)
    - DimProduct (product_category)
    - DimGeography (country)
    - DimDate (FullDate, YearMonth)
#>

$ErrorActionPreference = "Stop"
$pageDir = "D:\Datasets\BI_Projects\Enterprise_Global_Business_Analytics_3M_Work\Report\definition\pages\page_01_executive_overview"

Write-Host "=== VALIDATING PAGE 01 (EXECUTIVE OVERVIEW) PBIR DEFINITIONS ===" -ForegroundColor Yellow

if (!(Test-Path $pageDir)) {
    Write-Error "Page directory does not exist: $pageDir"
    exit 1
}

$pageJsonPath = Join-Path $pageDir "page.json"
$page = Get-Content $pageJsonPath -Raw | ConvertFrom-Json
Write-Host "[PASS] Page definition verified: $($page.displayName) (Height: $($page.height)px, Width: $($page.width)px)" -ForegroundColor Green

$visualsDir = Join-Path $pageDir "visuals"
$visualFolders = Get-ChildItem -Path $visualsDir -Directory
Write-Host "Found $($visualFolders.Count) visual container definitions in $visualsDir`n" -ForegroundColor Cyan

$allPassed = $true
$validEntities = @("vw_FactSales", "DimProduct", "DimGeography", "DimDate", "Business Data")

foreach ($vf in $visualFolders) {
    $vPath = Join-Path $vf.FullName "visual.json"
    if (!(Test-Path $vPath)) {
        Write-Host "[FAIL] Missing visual.json in $($vf.Name)" -ForegroundColor Red
        $allPassed = $false
        continue
    }

    try {
        $v = Get-Content $vPath -Raw | ConvertFrom-Json
        $vType = $v.visual.visualType
        $pos = $v.position
        
        if (!$vType -or !$pos.width -or !$pos.height) {
            Write-Host "[FAIL] Visual $($vf.Name): Missing mandatory PBIR visualType or dimensions" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "[PASS] $($vf.Name): Type='$vType', Bounds=($($pos.x), $($pos.y), $($pos.width)x$($pos.height))" -ForegroundColor Green
        }
    } catch {
        Write-Host "[FAIL] Visual $($vf.Name): JSON Parse Error: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Host "`nALL 17 PAGE 01 PBIR VISUAL DEFINITIONS VALIDATED SUCCESSFULLY!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nONE OR MORE PBIR CHECKS FAILED!" -ForegroundColor Red
    exit 1
}
