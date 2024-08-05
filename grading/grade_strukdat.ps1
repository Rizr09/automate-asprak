# grade.ps1
. .\config.ps1
. .\utils.ps1

$csvFile = Join-Path $parentDir "grades.csv"
$manualCheckFile = Join-Path $parentDir "ManualCheckNeededList.csv"

"Directory,Score,Original Score,Deduction,Last Commit Date" | Set-Content -Path $csvFile
"Directory" | Set-Content -Path $manualCheckFile

Set-Location -Path $parentDir
Get-ChildItem -Directory | ForEach-Object {
    Write-Host "Processing $($_.Name)" -ForegroundColor Cyan
    Set-Location $_.FullName

    $output = & make test 2>&1

    $score = 0
    $needsManualCheck = $false
    if ($output -notmatch "error") {
        if ($output -match "All tests passed") {
            $score = 100
            Write-Host "All tests passed" -ForegroundColor Green
        } else {
            $assertionPattern = "assertions:\s*(\d+)\s*\|\s*(\d+)\s*passed\s*\|\s*(\d+)\s*failed"
            $assertionMatch = $output | Select-String -Pattern $assertionPattern
            
            if ($assertionMatch) {
                Write-Host "Assertion match found: $($assertionMatch.Matches[0].Groups[0].Value)" -ForegroundColor Yellow
                $total = [int]$assertionMatch.Matches[0].Groups[1].Value
                $passed = [int]$assertionMatch.Matches[0].Groups[2].Value
                if ($total -ne 0) {
                    $score = ($passed / $total) * 100
                    if ($score -ge 60) {
                        Write-Host "Score: $score" -ForegroundColor Green
                    } else {
                        Write-Host "Score: $score" -ForegroundColor Red
                    }
                } else {
                    Write-Host "Warning: Total assertions is zero." -ForegroundColor Magenta
                    $needsManualCheck = $true
                }
            } else {
                Write-Host "No matching pattern found in output. Manual check needed!" -ForegroundColor Red
                $needsManualCheck = $true
            }
        }
    } else {
        Write-Host "Error detected in make test output." -ForegroundColor Red
        $needsManualCheck = $true
    }

    $lastCommitDate = Get-LastCommitDate $_.FullName
    $deduction = Calculate-Deduction $lastCommitDate $lateStartDate $zeroScoreDeadline

    $originalScore = $score
    $score = [math]::Max(0, $score - $deduction)

    "$($_.Name),$score,$originalScore,$deduction,$lastCommitDate" | Add-Content -Path $csvFile

    if ($needsManualCheck) {
        $_.Name | Add-Content -Path $manualCheckFile
    }

    if ($score -ge 60) {
        Write-Host "Final Score: $score" -ForegroundColor Green
    } else {
        Write-Host "Final Score: $score" -ForegroundColor Red
    }
    Write-Host "------------------------" -ForegroundColor DarkGray

    Set-Location $parentDir
}

Write-Host "Processing complete." -ForegroundColor Cyan
Write-Host "Grades saved to: $csvFile" -ForegroundColor Green
Write-Host "Manual check list saved to: $manualCheckFile" -ForegroundColor Green

Write-Host "Running clean.sh..." -ForegroundColor Yellow
if (Test-Path "$parentDir\clean.sh") {
    Set-Location $parentDir
    bash clean.sh
    if ($LASTEXITCODE -eq 0) {
        Write-Host "clean.sh executed successfully." -ForegroundColor Green
    } else {
        Write-Host "Error: clean.sh failed with exit code $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "Error: clean.sh not found in $parentDir" -ForegroundColor Red
}

Write-Host "Script execution completed." -ForegroundColor Cyan