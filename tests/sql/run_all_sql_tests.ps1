<#
.SYNOPSIS
    Automated SQL Server verification suite for 3M Global Analytics.
.DESCRIPTION
    Runs all 12 validation queries against database [3 _M] on local instance.
    Reconciles row counts, dimension completeness, foreign keys, and financial integrity.
#>

$ErrorActionPreference = "Stop"
$connString = "Server=.;Database=3 _M;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)

try {
    $conn.Open()
    Write-Host "Connected to SQL Server: [3 _M] on $env:COMPUTERNAME" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to connect to SQL Server database [3 _M]: $($_.Exception.Message)"
    exit 1
}

function Invoke-SqlScalar($query) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $cmd.CommandTimeout = 120
    return $cmd.ExecuteScalar()
}

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Add-TestResult($testId, $name, $expected, $actual, $passed) {
    $status = if ($passed) { "PASS" } else { "FAIL" }
    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "[$status] $testId - $name (Expected: $expected, Actual: $actual)" -ForegroundColor $color
    $results.Add([PSCustomObject]@{
        TestId   = $testId
        TestName = $name
        Expected = $expected
        Actual   = $actual
        Status   = $status
    })
}

Write-Host "`n=== EXECUTING AUTOMATED SQL VALIDATION SUITE ===" -ForegroundColor Yellow

# Test 1: Raw Row Count
$rawRows = Invoke-SqlScalar "SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m"
Add-TestResult "SQL-01" "Raw Source Rows" 3000000 $rawRows ($rawRows -eq 3000000)

# Test 2: Clean Table Row Count
$cleanRows = Invoke-SqlScalar "SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-02" "Clean Table Rows" 3000000 $cleanRows ($cleanRows -eq 3000000)

# Test 3: Fact View Row Count
$factRows = Invoke-SqlScalar "SELECT COUNT_BIG(*) FROM dbo.vw_FactSales"
Add-TestResult "SQL-03" "Fact View Rows" 3000000 $factRows ($factRows -eq 3000000)

# Test 4: Distinct Order IDs
$distinctOrders = Invoke-SqlScalar "SELECT COUNT(DISTINCT order_id) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-04" "Distinct Order IDs" 3000000 $distinctOrders ($distinctOrders -eq 3000000)

# Test 5: DimProduct Row Count
$dimProdRows = Invoke-SqlScalar "SELECT COUNT(*) FROM dbo.DimProduct"
Add-TestResult "SQL-05" "DimProduct Rows" 15 $dimProdRows ($dimProdRows -eq 15)

# Test 6: DimGeography Row Count
$dimGeoRows = Invoke-SqlScalar "SELECT COUNT(*) FROM dbo.DimGeography"
Add-TestResult "SQL-06" "DimGeography Rows" 50 $dimGeoRows ($dimGeoRows -eq 50)

# Test 7: Distinct Currencies
$currencyCount = Invoke-SqlScalar "SELECT COUNT(DISTINCT currency) FROM dbo.DimGeography"
Add-TestResult "SQL-07" "Distinct Currencies" 42 $currencyCount ($currencyCount -eq 42)

# Test 8: DimDate Calendar Days
$dimDateRows = Invoke-SqlScalar "SELECT COUNT(*) FROM dbo.DimDate"
Add-TestResult "SQL-08" "DimDate Calendar Days" 2191 $dimDateRows ($dimDateRows -eq 2191)

# Test 9: Unmapped Product Keys
$missingProdKeys = Invoke-SqlScalar "SELECT SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-09" "Unmapped Product Keys" 0 $missingProdKeys ($missingProdKeys -eq 0)

# Test 10: Unmapped Geography Keys
$missingGeoKeys = Invoke-SqlScalar "SELECT SUM(CASE WHEN GeographyKey IS NULL THEN 1 ELSE 0 END) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-10" "Unmapped Geography Keys" 0 $missingGeoKeys ($missingGeoKeys -eq 0)

# Test 11: Profit Reconciliation (tolerance 0.01)
$profitMismatches = Invoke-SqlScalar "SELECT SUM(CASE WHEN ABS(profit - (revenue - cost)) > 0.01 THEN 1 ELSE 0 END) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-11" "Profit Reconciliation Mismatches" 0 $profitMismatches ($profitMismatches -eq 0)

# Test 12: Delivery Date Semantics for Non-Delivered
$invalidDeliveries = Invoke-SqlScalar "SELECT SUM(CASE WHEN order_status != 'Delivered' AND actual_delivery_date IS NOT NULL THEN 1 ELSE 0 END) FROM dbo.world_business_data_3m_clean"
Add-TestResult "SQL-12" "Non-Delivered Actual Date Violations" 0 $invalidDeliveries ($invalidDeliveries -eq 0)

$conn.Close()

Write-Host "`n=== SQL TEST SUMMARY ===" -ForegroundColor Yellow
$results | Format-Table -AutoSize

$failedCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
if ($failedCount -eq 0) {
    Write-Host "ALL $results.Count TESTS PASSED SUCCESSFULLY!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "$failedCount TESTS FAILED!" -ForegroundColor Red
    exit 1
}
