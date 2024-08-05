# utils.ps1
function Get-LastCommitDate {
    param ($directory)
    Set-Location $directory
    if (Test-Path ".git") {
        $gitLog = git log -1 --format=%cd --date=iso
        if ($gitLog) {
            try {
                return [DateTime]::Parse($gitLog)
            } catch {
                Write-Host "Warning: Could not parse last commit date. $($_.Exception.Message)" -ForegroundColor Magenta
            }
        } else {
            Write-Host "Warning: Could not retrieve last commit date." -ForegroundColor Magenta
        }
    } else {
        Write-Host "Warning: No .git directory found." -ForegroundColor Magenta
    }
    return $null
}

function Calculate-Deduction {
    param ($lastCommitDate, $lateStartDate, $zeroScoreDeadline)
    if ($lastCommitDate -ge $lateStartDate) {
        $hoursLate = [math]::Floor(($lastCommitDate - $lateStartDate).TotalHours) + 1
        $deduction = [math]::Min($hoursLate, 15)
        Write-Host "Submission is $hoursLate hours late. Deducting $deduction points." -ForegroundColor Yellow
        return $deduction
    }
    if ($lastCommitDate -gt $zeroScoreDeadline) {
        Write-Host "Submission is after the zero score deadline." -ForegroundColor Red
        return 100  # Effectively setting score to 0
    }
    return 0
}