# config.ps1
$parentDir = (Get-Location).Path
$deadline = [DateTime]::ParseExact("21/05/2024 23:59", "dd/MM/yyyy HH:mm", $null)
$lateStartDate = $deadline.Date.AddDays(1)
$zeroScoreDeadline = [DateTime]::ParseExact("23/06/2024 23:59", "dd/MM/yyyy HH:mm", $null)