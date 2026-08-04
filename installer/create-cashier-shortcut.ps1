param(
  [Parameter(Mandatory = $true)][string]$ServerHost,
  [int]$Port = 5002,
  [string]$ShortcutName = 'MartX POS',
  [switch]$StartMenu
)

$ErrorActionPreference = 'Stop'

$launcherSource = Join-Path $PSScriptRoot 'open-app.ps1'
if (-not (Test-Path -LiteralPath $launcherSource)) {
  throw "open-app.ps1 must sit next to create-cashier-shortcut.ps1"
}

$destDir = Join-Path $env:LOCALAPPDATA 'MartX\launcher'
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$launcherDest = Join-Path $destDir 'open-app.ps1'
Copy-Item -LiteralPath $launcherSource -Destination $launcherDest -Force

$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop ($ShortcutName + '.lnk')
$shortcut = $wsh.CreateShortcut($lnkPath)
$shortcut.TargetPath = 'powershell.exe'
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$launcherDest`" -HostName $ServerHost -Port $Port"
$shortcut.WorkingDirectory = $destDir
$shortcut.WindowStyle = 7
$shortcut.Description = "MartX POS ($ServerHost`:$Port)"
$shortcut.Save()
Write-Host "Created desktop shortcut: $lnkPath"

if ($StartMenu) {
  $programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
  New-Item -ItemType Directory -Force -Path $programs | Out-Null
  $smPath = Join-Path $programs ($ShortcutName + '.lnk')
  $sm = $wsh.CreateShortcut($smPath)
  $sm.TargetPath = $shortcut.TargetPath
  $sm.Arguments = $shortcut.Arguments
  $sm.WorkingDirectory = $shortcut.WorkingDirectory
  $sm.WindowStyle = 7
  $sm.Description = $shortcut.Description
  $sm.Save()
  Write-Host "Created Start Menu shortcut: $smPath"
}
