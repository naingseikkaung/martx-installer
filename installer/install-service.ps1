param([string]$InstallRoot = "$env:ProgramFiles\MartX", [string]$DataRoot = "$env:ProgramData\MartX", [switch]$Remove)
$ErrorActionPreference = 'Stop'
$nssm = Join-Path $InstallRoot 'service\nssm.exe'
$service = 'MartXPOS'
$existing = Get-Service -Name $service -ErrorAction SilentlyContinue

function Remove-ExistingService {
  $current = Get-Service -Name $service -ErrorAction SilentlyContinue
  if (-not $current) { return }

  # NSSM writes "The service has not been started" to stderr when the
  # service is already stopped/paused. That is safe during reinstall.
  try {
    $ErrorActionPreference = 'Continue'
    & $nssm stop $service confirm 2>$null | Out-Null
  } finally {
    $ErrorActionPreference = 'Stop'
  }

  & $nssm remove $service confirm 2>$null | Out-Null
  Start-Sleep -Milliseconds 500
  if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
    throw "Could not remove existing Windows service $service."
  }
}

if ($Remove) {
  Remove-ExistingService
  exit 0
}
New-Item -ItemType Directory -Force "$DataRoot/config", "$DataRoot/data", "$DataRoot/logs", "$DataRoot/backups" | Out-Null
if ($existing) { Remove-ExistingService }
$nodePath = Join-Path $InstallRoot 'runtime\node.exe'
& $nssm install $service $nodePath
& $nssm set $service AppDirectory (Join-Path $InstallRoot 'backend')
# Keep the entrypoint relative to AppDirectory. This avoids breaking when the
# install path contains spaces, such as C:\Program Files\MartX.
& $nssm set $service AppParameters 'server.js'
& $nssm set $service AppEnvironmentExtra "NODE_ENV=production" "MARTX_DATA_ROOT=$DataRoot" "HOST=0.0.0.0"
& $nssm set $service AppStdout (Join-Path $DataRoot 'logs\service-stdout.log')
& $nssm set $service AppStderr (Join-Path $DataRoot 'logs\service-stderr.log')
& $nssm set $service Start SERVICE_AUTO_START
& $nssm set $service AppExit Default Restart
& $nssm set $service AppRestartDelay 5000
& $nssm start $service
