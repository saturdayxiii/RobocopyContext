$ErrorActionPreference = "Stop"

Write-Host "Installing RobocopyContext menus... Window will close when finished. Please be patient."
Write-Host "Working on task 1 of 6"

# Resolve app root correctly (works under Scoop)
$AppRoot = $PSScriptRoot
$BinPath = Join-Path $AppRoot "bin"

$CopyScript    = Join-Path $BinPath "robocopy_copy.ps1"
$PasteLauncher = Join-Path $BinPath "robocopy_paste_launcher.ps1"

if (!(Test-Path $CopyScript))    { throw "Copy script missing at $CopyScript" }
if (!(Test-Path $PasteLauncher)) { throw "Paste launcher missing at $PasteLauncher" }

# Use absolute PowerShell path (prevents “no associated app”)
$PowerShellExe = "$($PSHOME)\powershell.exe"

# =====================================================
# 1️ STAGE (files + folders)
# =====================================================
Write-Host "Working on task 2 of 6... refreshing context handles in classes* makes this one take forever..."
$PowerShellExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

$StageLocations = @(
    "HKCU:\Software\Classes\*\shell\RoboCopyStage",
    "HKCU:\Software\Classes\Directory\shell\RoboCopyStage"
)

foreach ($Base in $StageLocations) {

    New-Item -Path $Base -Force | Out-Null
    Set-ItemProperty -Path $Base -Name "MUIVerb" -Value "Stage with Robocopy"
    Set-ItemProperty -Path $Base -Name "Icon" -Value "imageres.dll,-5302"
    Set-ItemProperty -Path $Base -Name "MultiSelectModel" -Value "Player"

    $Cmd = Join-Path $Base "command"
    New-Item -Path $Cmd -Force | Out-Null

    $CommandString = "`"$PowerShellExe`" -NoProfile -ExecutionPolicy Bypass -File `"$CopyScript`" `"%*`""
    Set-ItemProperty -Path $Cmd -Name "(default)" -Value $CommandString
}

# =====================================================
# 2️ PASTE (background cascading submenu)
# =====================================================
Write-Host "Working on task 3 of 6"
$PasteBase = "HKCU:\Software\Classes\Directory\Background\shell\RoboCopyPaste"

New-Item -Path $PasteBase -Force | Out-Null
Set-ItemProperty -Path $PasteBase -Name "MUIVerb" -Value "Robocopy Paste"
Set-ItemProperty -Path $PasteBase -Name "Icon" -Value "imageres.dll,-5302"
Set-ItemProperty -Path $PasteBase -Name "SubCommands" -Value ""

# ----- Large -----
Write-Host "Working on task 4 of 6"
$LargeKey = Join-Path $PasteBase "shell\Large"
New-Item -Path $LargeKey -Force | Out-Null
Set-ItemProperty -Path $LargeKey -Name "MUIVerb" -Value "Paste (Large Files / USB)"

$LargeCmd = Join-Path $LargeKey "command"
New-Item -Path $LargeCmd -Force | Out-Null

$LargeCommand = "`"$PowerShellExe`" -NoProfile -ExecutionPolicy Bypass -File `"$PasteLauncher`" `"%V`" Large"
Set-ItemProperty -Path $LargeCmd -Name "(default)" -Value $LargeCommand

# ----- Small -----
Write-Host "Working on task 5 of 6"
$SmallKey = Join-Path $PasteBase "shell\Small"
New-Item -Path $SmallKey -Force | Out-Null
Set-ItemProperty -Path $SmallKey -Name "MUIVerb" -Value "Paste (Small Files)"

$SmallCmd = Join-Path $SmallKey "command"
New-Item -Path $SmallCmd -Force | Out-Null

$SmallCommand = "`"$PowerShellExe`" -NoProfile -ExecutionPolicy Bypass -File `"$PasteLauncher`" `"%V`" Small"
Set-ItemProperty -Path $SmallCmd -Name "(default)" -Value $SmallCommand

Write-Host "RobocopyContext installed successfully."
