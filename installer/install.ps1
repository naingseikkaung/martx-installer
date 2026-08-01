param(
  [string]$InstallRoot = "$env:ProgramFiles\MartX",
  [string]$DataRoot = "$env:ProgramData\MartX",
  [switch]$OpenBrowser
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

  Write-InstallLog 'Installing Windows service.'
  & (Join-Path $InstallRoot 'service\install-service.ps1') `
    -InstallRoot $InstallRoot -DataRoot $DataRoot

  Write-InstallLog 'Configuring Windows Firewall.'
  try {
    & (Join-Path $InstallRoot 'firewall.ps1')
    Write-InstallLog 'Windows Firewall configured.'
  } catch {
    # Firewall policy can be restricted by endpoint security or domain policy.
    # Keep the local app usable and leave a clear warning in the install log.
    Write-InstallLog "WARNING: Windows Firewall configuration failed: $($_.Exception.Message)"
  }

  Write-InstallLog 'Waiting for backend health check.'
  if ($OpenBrowser) {
    & (Join-Path $InstallRoot 'smoke-install.ps1') -OpenBrowser
  } else {
    & (Join-Path $InstallRoot 'smoke-install.ps1')
  }

  Write-InstallLog 'Installation completed successfully.'
  exit 0
} catch {
  $message = "MartX POS installation failed: $($_.Exception.Message)`n`nSee $log for details."
  Write-InstallLog $message
  # Silent CI installs must never wait for an interactive dialog. Normal
  # client installs still get a useful UAC-era error popup.
  if ($env:MARTX_INSTALLER_TEST -ne '1') {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, 'MartX POS Installation Error', 'OK', 'Error') | Out-Null
  }
  exit 1
}
