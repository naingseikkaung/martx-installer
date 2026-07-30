param([int]$Port = 5002, [int]$TimeoutSeconds = 90, [switch]$OpenBrowser)
$ErrorActionPreference = 'Stop'
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$health = "http://127.0.0.1:$Port/health"
$body = $null
do { try { $response = Invoke-WebRequest $health -UseBasicParsing -TimeoutSec 5; $body = $response.Content | ConvertFrom-Json; if ($response.StatusCode -eq 200 -and $body.status -eq 'ok') { break } } catch { Start-Sleep 2 }; Start-Sleep 2 } while ((Get-Date) -lt $deadline)
if (-not $body -or $body.status -ne 'ok') { throw "MartXPOS did not become healthy at $health. Check %ProgramData%\MartX\logs." }
if ($OpenBrowser) { $chrome = Join-Path ${env:ProgramFiles} 'Google\Chrome\Application\chrome.exe'; if (Test-Path $chrome) { Start-Process $chrome "http://127.0.0.1:$Port/" } else { Start-Process "http://127.0.0.1:$Port/" } }
