param([string]$InstallRoot = "$env:ProgramFiles\MartX", [string]$DataRoot = "$env:ProgramData\MartX", [switch]$Remove)
$ErrorActionPreference = 'Stop'
$nssm = Join-Path $InstallRoot 'service\nssm.exe'
$service = 'MartXPOS'
if ($Remove) { & $nssm stop $service confirm 2>$null; & $nssm remove $service confirm 2>$null; exit 0 }
New-Item -ItemType Directory -Force "$DataRoot/config", "$DataRoot/data", "$DataRoot/logs", "$DataRoot/backups" | Out-Null
& $nssm stop $service confirm 2>$null
& $nssm remove $service confirm 2>$null
& $nssm install $service (Join-Path $InstallRoot 'runtime\node.exe') (Join-Path $InstallRoot 'backend\server.js')
& $nssm set $service AppDirectory (Join-Path $InstallRoot 'backend')
& $nssm set $service AppEnvironmentExtra "NODE_ENV=production" "MARTX_DATA_ROOT=$DataRoot" "HOST=0.0.0.0"
& $nssm set $service AppStdout (Join-Path $DataRoot 'logs\service-stdout.log')
& $nssm set $service AppStderr (Join-Path $DataRoot 'logs\service-stderr.log')
& $nssm set $service Start SERVICE_AUTO_START
& $nssm set $service AppExit Default Restart
& $nssm set $service AppRestartDelay 5000
& $nssm start $service
