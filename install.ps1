$ErrorActionPreference = "Stop"

Write-Host "Installing RobocopyContext menus..."

$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinPath = Join-Path $AppRoot "bin"

$CopyScript     = Join-Path $BinPath "robocopy_copy.ps1"
$PasteLauncher  = Join-Path $BinPath "robocopy_paste_launcher.ps1"

if (!(Test-Path $CopyScript))    { throw "Copy script missing." }
if (!(Test-Path $PasteLauncher)) { throw "Paste launcher missing." }

# =============================
# 1 STAGE (File/Folder menu)
# =============================

$StageBase = "HKCU:\Software\Classes\*\shell\RoboCopyCopy"
New-Item -Path $StageBase -Force | Out-Null
Set-ItemProperty -Path $StageBase -Name "(default)" -Value "RobocopyCopy"
Set-ItemProperty -Path $StageBase -Name "Icon" -Value "imageres.dll,-5302"

$StageCmd = "$StageBase\command"
New-Item -Path $StageCmd -Force | Out-Null

$StageCommandString = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$CopyScript`""
Set-ItemProperty -Path $StageCmd -Name "(default)" -Value $StageCommandString

# Also register for directories specifically (ensures folder support)
$DirStageBase = "HKCU:\Software\Classes\Directory\shell\RoboCopyCopy"
Copy-Item -Path $StageBase -Destination $DirStageBase -Recurse -Force

# =============================
# 2 PASTE (Background menu)
# =============================

$PasteBase = "HKCU:\Software\Classes\Directory\Background\shell\RoboCopyPaste"
New-Item -Path $PasteBase -Force | Out-Null
Set-ItemProperty -Path $PasteBase -Name "(default)" -Value "Robocopy Paste"
Set-ItemProperty -Path $PasteBase -Name "Icon" -Value "imageres.dll,-5302"

# --- Large Mode ---
$LargeKey = "$PasteBase\shell\Large"
New-Item -Path $LargeKey -Force | Out-Null
Set-ItemProperty -Path $LargeKey -Name "(default)" -Value "Paste (Large Files XOR USB)"

$LargeCmd = "$LargeKey\command"
New-Item -Path $LargeCmd -Force | Out-Null

$LargeCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$PasteLauncher`" `"%V`" Large"
Set-ItemProperty -Path $LargeCmd -Name "(default)" -Value $LargeCommand

# --- Small Mode ---
$SmallKey = "$PasteBase\shell\Small"
New-Item -Path $SmallKey -Force | Out-Null
Set-ItemProperty -Path $SmallKey -Name "(default)" -Value "Paste (Small Files)"

$SmallCmd = "$SmallKey\command"
New-Item -Path $SmallCmd -Force | Out-Null

$SmallCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$PasteLauncher`" `"%V`" Small"
Set-ItemProperty -Path $SmallCmd -Name "(default)" -Value $SmallCommand

Write-Host "Robocopy Tools installed successfully."