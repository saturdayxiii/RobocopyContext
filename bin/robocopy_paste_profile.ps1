$Destination = $args[0]
$Mode        = $args[1]

$StageFile = "$env:TEMP\robocopy_staged.txt"

if (!(Test-Path -LiteralPath $StageFile)) {
    Write-Host "Nothing staged for RoboCopy."
    Pause
    exit
}

$Items = Get-Content -LiteralPath $StageFile |
    ForEach-Object { $_.Trim('"').Trim() } |
    Where-Object { $_ -ne "" }

# ---- Determine threading for Small mode ----
$ThreadArg = ""
if ($Mode -eq "Small") {

    $Cores = [Environment]::ProcessorCount

    if     ($Cores -le 4)  { $Threads = 4 }
    elseif ($Cores -le 8)  { $Threads = 8 }
    elseif ($Cores -le 16) { $Threads = 16 }
    else                   { $Threads = 32 }

    $ThreadArg = "/MT:$Threads"

    Write-Host "Small Bulk Files Mode"
    Write-Host "Detected CPU cores: $Cores"
    Write-Host "Using threads: $Threads"
}
else {
    Write-Host "Large Files AND/OR HDD Mode"
}

Write-Host ""
Write-Host "Pasting to: $Destination"
Write-Host ""

$Files   = @()
$Folders = @()
$TotalRuns = 0
$Failures  = 0

foreach ($Item in $Items) {

    if (Test-Path -LiteralPath $Item -PathType Container) {
        $Folders += $Item
    }
    elseif (Test-Path -LiteralPath $Item -PathType Leaf) {
        $Files += $Item
    }
}

Write-Host "Folders detected: $($Folders.Count)"
Write-Host "Files detected: $($Files.Count)"
Write-Host ""

# ---- HANDLE FOLDERS ----
foreach ($Folder in $Folders) {

    if (!(Test-Path -LiteralPath $Folder -PathType Container)) {
        continue
    }

    $FolderName = Split-Path $Folder -Leaf
    $DestFolder = Join-Path $Destination $FolderName

    if ($Mode -eq "Small") {
        robocopy $Folder $DestFolder /E $ThreadArg /R:2 /W:2 /TEE
	$ExitCode = $LASTEXITCODE
	$TotalRuns++

	if ($ExitCode -ge 8) {
    		$Failures++
	}
    }
    else {
        robocopy $Folder $DestFolder /E /J /R:2 /W:5 /TEE
	$ExitCode = $LASTEXITCODE
	$TotalRuns++

	if ($ExitCode -ge 8) {
    		$Failures++
	}
    }
}

# ---- HANDLE FILES ----

# Extra safety: ensure only real files remain
$Files = $Files | Where-Object {
    Test-Path -LiteralPath $_ -PathType Leaf
}

$GroupedFiles = $Files | Group-Object {
    Split-Path $_
}

foreach ($Group in $GroupedFiles) {

    $SourceDir = $Group.Name
    $FileNames = $Group.Group | ForEach-Object {
        Split-Path $_ -Leaf
    }

    if ($Mode -eq "Small") {
        robocopy $SourceDir $Destination $FileNames $ThreadArg /R:2 /W:2 /TEE
	$ExitCode = $LASTEXITCODE
	$TotalRuns++

	if ($ExitCode -ge 8) {
    		$Failures++
	}
    }
    else {
        robocopy $SourceDir $Destination $FileNames /J /R:2 /W:5 /TEE
	$ExitCode = $LASTEXITCODE
	$TotalRuns++

	if ($ExitCode -ge 8) {
    		$Failures++
	}
    }
}

Write-Host ""
Write-Host "Transfer complete."
Write-Host ""
Write-Host "==============================="
Write-Host "Summary of RoboCopy Summaries"
Write-Host "Runs executed : $TotalRuns"
Write-Host "Failures      : $Failures"

if ($Failures -eq 0) {
    Write-Host "Status        : SUCCESS"
}
else {
    Write-Host "Status        : ERRORS DETECTED"
}
Write-Host "==============================="

Pause
