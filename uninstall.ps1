Write-Host "Removing Robocopy Tools context menus..."

$Paths = @(
    "HKCU:\Software\Classes\*\shell\RoboCopyCopy",
    "HKCU:\Software\Classes\Directory\shell\RoboCopyCopy",
    "HKCU:\Software\Classes\Directory\Background\shell\RoboCopyPaste"
)

foreach ($Path in $Paths) {
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Uninstall complete."
