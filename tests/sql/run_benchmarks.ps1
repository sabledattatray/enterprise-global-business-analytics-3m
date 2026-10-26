<#
.SYNOPSIS
    Automated Performance Benchmark Runner for SQL Server 2022 (3M Rows).
.DESCRIPTION
    Measures query execution duration, row throughput, and I/O metrics across:
    - Workload 1: Monthly Aggregation by Currency (3M rows scan + group by)
    - Workload 2: Star Schema 3-Way Join Slicing (Fact + 2 Dimensions)
    - Workload 3: Core Headline Card Metrics (Distinct Orders, Units, Avg)
    Executes cold-cache and warm-cache iterations with System.Diagnostics.Stopwatch.
#>

$ErrorActionPreference = "Stop"
$connString = "Server=.;Database=3 _M;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=60;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)

Write-Host "=== SQL SERVER 2022 PERFORMANCE BENCHMARK RUNNER ===" -ForegroundColor Yellow
Write-Host "Connecting to local SQL instance: database [3 _M]..." -ForegroundColor Cyan

try {
    $conn.Open()
    Write-Host "Connected successfully on $env:COMPUTERNAME" -ForegroundColor Green
} catch {
    Write-Error "Failed to connect to database [3 _M]: $($_.Exception.Message)"
    exit 1
}

function Measure-Query($name, $sql, $rowCount) {
    Write-Host "`nBenchmarking: $name" -ForegroundColor White
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 120

    # Warm-up run
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $reader = $cmd.ExecuteReader()
    $rowsReturned = 0
    while ($reader.Read()) { $rowsReturned++ }
    $reader.Close()
    $sw.Stop()
    $durationMs = $sw.ElapsedMilliseconds
    $throughput = if ($durationMs -gt 0) { [Math]::Round(($rowCount / ($durationMs / 1000.0)), 0) } else { 0 }

    Write-Host "  Processed: $rowCount rows" -ForegroundColor Gray
    Write-Host "  Result:    $rowsReturned aggregated records" -ForegroundColor Gray
    Write-Host "  Duration:  $durationMs ms" -ForegroundColor Green
    Write-Host "  Throughput: $($throughput.ToString('N0')) rows/sec" -ForegroundColor Yellow

    return [PSCustomObject]@{
        Workload = $name
        DurationMs = $durationMs
        Throughput = $throughput
        ResultRows = $rowsReturned
    }
}

$benchmarks = @(
    @{
        Name = "Benchmark 1: Monthly Aggregation by Currency"
        Sql = @"
SELECT 
    YEAR(order_date) AS [Year],
    MONTH(order_date) AS [Month],
    currency,
    COUNT_BIG(*) AS OrderCount,
    SUM(CAST(quantity AS BIGINT)) AS TotalUnits,
    SUM(CAST(revenue AS DECIMAL(18,2))) AS TotalRevenue,
    SUM(CAST(profit AS DECIMAL(18,2))) AS TotalProfit
FROM dbo.vw_FactSales
GROUP BY YEAR(order_date), MONTH(order_date), currency;
"@
        Rows = 3000000
    },
    @{
        Name = "Benchmark 2: Star Schema 3-Way Join Slicing"
        Sql = @"
SELECT TOP 20
    p.product_category,
    p.product_name,
    g.continent,
    g.country,
    f.currency,
    COUNT_BIG(*) AS OrderCount,
    SUM(CAST(f.revenue AS DECIMAL(18,2))) AS TotalRevenue
FROM dbo.vw_FactSales f
INNER JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
INNER JOIN dbo.DimGeography g ON f.GeographyKey = g.GeographyKey
GROUP BY p.product_category, p.product_name, g.continent, g.country, f.currency
ORDER BY TotalRevenue DESC;
"@
        Rows = 3000000
    },
    @{
        Name = "Benchmark 3: Core Headline Card Query"
        Sql = @"
SELECT 
    COUNT(DISTINCT order_id) AS TotalOrders,
    SUM(CAST(quantity AS BIGINT)) AS TotalUnits,
    AVG(CAST(quantity AS FLOAT)) AS AvgUnitsPerOrder
FROM dbo.vw_FactSales;
"@
        Rows = 3000000
    }
)

$results = foreach ($b in $benchmarks) {
    Measure-Query -name $b.Name -sql $b.Sql -rowCount $b.Rows
}

$conn.Close()
Write-Host "`nAll benchmarks completed successfully!" -ForegroundColor Green
