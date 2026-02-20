Write-Host "Removing RobocopyContext menus. Window will close when complete..."

$Keys = @(
    "HKCU:\Software\Classes\*\shell\RoboCopyStage",
    "HKCU:\Software\Classes\Directory\shell\RoboCopyStage",
    "HKCU:\Software\Classes\Directory\Background\shell\RoboCopyPaste"
)

foreach ($Key in $Keys) {
    Remove-Item -Path $Key -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "Removed 1 of 3."
}

Write-Host "RobocopyContext removed."
