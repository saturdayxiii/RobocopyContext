#Limitation: only works for Windows Explorer

Add-Type -AssemblyName System.Windows.Forms

$StageFile = "$env:TEMP\robocopy_staged.txt"

# Get selected items from active Explorer window

#Limitation: If multiple explorer windows/tabs open with selections, it will only stage the first opened window.

$shell   = New-Object -ComObject Shell.Application
$windows = $shell.Windows()

$NewItems = @()

# Bug: opens a shell window for every selected file, they all say the exact same thing so it must be looping everything per selection.

foreach ($window in $windows) {
    try {
        if ($window.Document -and $window.Document.SelectedItems().Count -gt 0) {
            foreach ($item in $window.Document.SelectedItems()) {
                $NewItems += $item.Path
            }
            break
        }
    }
    catch { }
}

if ($NewItems.Count -eq 0) {
    Write-Host "No files selected."
    Pause
    exit
}

# Future feature potential, except it clutters the menu> add option to add new files to current staging or begin a new staging.

# Load existing staged items (if any)
# $Existing = @()
# if (Test-Path -LiteralPath $StageFile) {
#     $Existing = Get-Content -LiteralPath $StageFile
# }

# (Merge +) clean + dedupe
# $AllItems = ($Existing + $NewItems) |
$AllItems = $NewItems |
    ForEach-Object { $_.Trim('"').Trim() } |
    Where-Object { $_ -ne "" } |
    Sort-Object -Unique

# Save clean list
$AllItems | Set-Content -LiteralPath $StageFile

Write-Host ""
Write-Host "Staged items:"
Write-Host "--------------"
$AllItems
Write-Host ""
Write-Host "Total staged: $($AllItems.Count)"
