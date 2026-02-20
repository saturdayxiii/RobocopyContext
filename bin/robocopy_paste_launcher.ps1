$Destination = $args[0]
$Mode        = $args[1]

# Detect Scoop location
if ($env:SCOOP -and (Test-Path -LiteralPath $env:SCOOP)) {
    $ScoopRoot = $env:SCOOP
}
else {
    $ScoopRoot = Join-Path $env:USERPROFILE "scoop"
}

$ScriptPath = Join-Path $ScoopRoot "apps\robocopycontext\current\bin\robocopy_paste_profile.ps1"

if (!(Test-Path -LiteralPath $ScriptPath)) {
    Write-Host "Robocopy Tools not found in Scoop directory."
    Write-Host "Checked:"
    Write-Host $ScriptPath
    Pause
    exit
}

& $ScriptPath $Destination $Mode
