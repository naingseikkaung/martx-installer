param(
  [string]$InstallRoot = "$env:ProgramFiles\MartX",
  [string]$DataRoot = "$env:ProgramData\MartX"
)

$ErrorActionPreference = 'Stop'
$log = Join-Path $DataRoot 'logs\install.log'
New-Item -ItemType Directory -Force (Split-Path $log) | Out-Null

function Write-InstallLog([string]$Message) {
  $line = "$(Get-Date -Format s) $Message"
  Add-Content -Path $log -Value $line
  Write-Host $line
}

try {
  Write-InstallLog "Installing MartX POS from $InstallRoot"

  & (Join-Path $InstallRoot 'service\install-service.ps1') `
    -InstallRoot $InstallRoot -DataRoot $DataRoot
  if ($LASTEXITCODE -ne 0) { throw "Windows service installation failed (exit code $LASTEXITCODE)." }

  & (Join-Path $InstallRoot 'firewall.ps1')
  if ($LASTEXITCODE -ne 0) { throw "Windows Firewall configuration failed (exit code $LASTEXITCODE)." }

  & (Join-Path $InstallRoot 'smoke-install.ps1') -OpenBrowser
  if ($LASTEXITCODE -ne 0) { throw "MartX POS did not become healthy." }

  Write-InstallLog 'Installation completed successfully.'
  exit 0
} catch {
  $message = "MartX POS installation failed: $($_.Exception.Message)`n`nSee $log for details."
  Write-InstallLog $message
  Add-Type -AssemblyName PresentationFramework
  [System.Windows.MessageBox]::Show($message, 'MartX POS Installation Error', 'OK', 'Error') | Out-Null
  exit 1
}
