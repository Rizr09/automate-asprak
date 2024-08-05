# telat.ps1
. .\config.ps1
. .\utils.ps1

$csvFile = Join-Path $parentDir "deadline_check.csv"
"Directory,Last Commit Date,Hours Late,Deduction" | Set-Content -Path $csvFile

Set-Location -Path $parentDir

Get-ChildItem -Directory | ForEach-Object {
    Write-Host "Processing $($_.Name)" -ForegroundColor Cyan
    $lastCommitDate = Get-LastCommitDate $_.FullName
    $deduction = Calculate-Deduction $lastCommitDate $lateStartDate $zeroScoreDeadline
    $hoursLate = if ($deduction -gt 0 -and $deduction -lt 100) { $deduction } else { 0 }
    "$($_.Name),$lastCommitDate,$hoursLate,$deduction" | Add-Content -Path $csvFile
    Write-Host "------------------------" -ForegroundColor DarkGray
}

Write-Host "Processing complete." -ForegroundColor Cyan
Write-Host "Deadline check results saved to: $csvFile" -ForegroundColor Green