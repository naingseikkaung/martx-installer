param([int]$Port = 5002, [int]$TimeoutSeconds = 90, [switch]$OpenBrowser)
$ErrorActionPreference = 'Stop'
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$health = "http://127.0.0.1:$Port/health"
$body = $null
do {
  try {
    $response = Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 5
    $body = $response.Content | ConvertFrom-Json
    if ($response.StatusCode -eq 200 -and $body.status -eq 'ok') { break }
  } catch { Start-Sleep -Seconds 2 }
  Start-Sleep -Seconds 2
} while ((Get-Date) -lt $deadline)

if (-not $body -or $body.status -ne 'ok') { throw "MartXPOS did not become healthy at $health. Check %ProgramData%\MartX\logs." }
Write-Host "MartXPOS health check passed."
if ($OpenBrowser) {
  $launcher = Join-Path $PSScriptRoot 'open-app.ps1'
  if (-not (Test-Path -LiteralPath $launcher)) {
    throw "Missing open-app.ps1 next to smoke-install.ps1"
  }
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $launcher -HostName 127.0.0.1 -Port $Port
}
