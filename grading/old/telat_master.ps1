$parentDir = (Get-Location).Path

$csvFile = Join-Path $parentDir "deadline_check.csv"

"Directory,Last Commit Date,Hours Late,Deduction" | Set-Content -Path $csvFile

# CHANGE THE DEADLINE HERE
$deadline = [DateTime]::ParseExact("21/05/2024 23:59", "dd/MM/yyyy HH:mm", $null)
$lateStartDate = $deadline.Date.AddDays(1)

# Additional deadline for automatic zero score
$zeroScoreDeadline = [DateTime]::ParseExact("23/06/2024 23:59", "dd/MM/yyyy HH:mm", $null)

Set-Location -Path $parentDir

Get-ChildItem -Directory | ForEach-Object {
    Write-Host "Processing $($_.Name)" -ForegroundColor Cyan
    Set-Location $_.FullName

    $lastCommitDate = $null
    $deduction = 0
    $hoursLate = 0
    if (Test-Path ".git") {
        $gitLog = git log -1 --format=%cd --date=iso
        if ($gitLog) {
            try {
                $lastCommitDate = [DateTime]::Parse($gitLog)
                if ($lastCommitDate -ge $lateStartDate) {
                    $hoursLate = [math]::Floor(($lastCommitDate - $lateStartDate).TotalHours) + 1
                    $deduction = [math]::Min($hoursLate, 15)
                    Write-Host "Submission is $hoursLate hours late. Deducting $deduction points." -ForegroundColor Yellow
                }

                # Check if the last commit date is after the zeroScoreDeadline
                if ($lastCommitDate -gt $zeroScoreDeadline) {
                    Write-Host "Submission is after the zero score deadline." -ForegroundColor Red
                }
            } catch {
                Write-Host "Warning: Could not parse last commit date. $($_.Exception.Message)" -ForegroundColor Magenta
            }
        } else {
            Write-Host "Warning: Could not retrieve last commit date." -ForegroundColor Magenta
        }
    } else {
        Write-Host "Warning: No .git directory found." -ForegroundColor Magenta
    }

    "$($_.Name),$lastCommitDate,$hoursLate,$deduction" | Add-Content -Path $csvFile

    Write-Host "------------------------" -ForegroundColor DarkGray

    Set-Location $parentDir
}

Write-Host "Processing complete." -ForegroundColor Cyan
Write-Host "Deadline check results saved to: $csvFile" -ForegroundColor Green
