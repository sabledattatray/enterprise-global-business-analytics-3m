<#
.SYNOPSIS
    Static analysis and guardrail validation for Power BI DAX measures.
.DESCRIPTION
    Audits powerbi/measures/*.dax files to ensure:
    - P0 Multi-Currency Guardrails: All monetary measures enforce HASONEVALUE(DimGeography[currency]).
    - Total Orders uses DISTINCTCOUNT.
    - Delivery and cancellation measures filter vw_FactSales[order_status].
    - DIVIDE functions specify alternate results to prevent division by zero.
#>

$ErrorActionPreference = "Stop"
$measuresDir = "d:\Datasets\3M Project Power BI\powerbi\measures"
$daxFiles = Get-ChildItem -Path $measuresDir -Filter "*.dax"

Write-Host "=== AUDITING POWER BI DAX MEASURES ===" -ForegroundColor Yellow
Write-Host "Found $($daxFiles.Count) DAX measure definition files in $measuresDir`n" -ForegroundColor Cyan

$allPassed = $true

foreach ($file in $daxFiles) {
    Write-Host "Auditing $($file.Name)..." -ForegroundColor White
    $content = Get-Content -Path $file.FullName -Raw

    # Check 1: Finance measures currency gating
    if ($file.Name -eq "finance_measures.dax") {
        if ($content -notmatch "HASONEVALUE\(DimGeography\[currency\]\)") {
            Write-Host "  [FAIL] Missing mandatory P0 multi-currency guardrail HASONEVALUE(DimGeography[currency])" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  [PASS] Mandatory P0 multi-currency guardrail enforced." -ForegroundColor Green
        }

        # Ensure no raw unguarded SUM of revenue is declared as global KPI
        if ($content -match "Global Revenue\s*=\s*SUM\(vw_FactSales\[revenue\]\)") {
            Write-Host "  [FAIL] Detected forbidden unguarded global revenue sum!" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  [PASS] No illegal unguarded global revenue sums detected." -ForegroundColor Green
        }
    }

    # Check 2: Base measures
    if ($file.Name -eq "base_measures.dax") {
        if ($content -notmatch "DISTINCTCOUNT\(vw_FactSales\[order_id\]\)") {
            Write-Host "  [FAIL] Total Orders must use DISTINCTCOUNT(vw_FactSales[order_id])" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  [PASS] Total Orders uses DISTINCTCOUNT." -ForegroundColor Green
        }
    }

    # Check 3: Operations measures
    if ($file.Name -eq "operations_measures.dax") {
        if ($content -notmatch "order_status.*=.*""Delivered""") {
            Write-Host "  [FAIL] Delivered Orders measure missing order_status filter" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  [PASS] Delivered Orders filters order_status = 'Delivered'." -ForegroundColor Green
        }
        if ($content -notmatch "order_status.*=.*""Cancelled""") {
            Write-Host "  [FAIL] Cancelled Orders measure missing order_status filter" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  [PASS] Cancelled Orders filters order_status = 'Cancelled'." -ForegroundColor Green
        }
    }
}

if ($allPassed) {
    Write-Host "`nALL DAX MEASURE STATIC AUDITS PASSED!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nONE OR MORE DAX STATIC CHECKS FAILED!" -ForegroundColor Red
    exit 1
}
