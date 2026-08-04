param(
  [string]$Url,
  [string]$HostName,
  [int]$Port = 5002,
  [switch]$ResolveOnly
)

$ErrorActionPreference = 'Stop'

function Get-MartxAppUrl {
  param([string]$Url, [string]$HostName, [int]$Port)
  if ($Url) {
    $trimmed = $Url.Trim()
    if ($trimmed -notmatch '^https?://') { throw "Url must start with http:// or https://" }
    if (-not $trimmed.EndsWith('/')) { $trimmed = "$trimmed/" }
    return $trimmed
  }
  if (-not $HostName) { throw "HostName or Url is required" }
  return ("http://{0}:{1}/" -f $HostName.Trim(), $Port)
}

function Find-BrowserExe {
  $candidates = @(
    (Join-Path ${env:ProgramFiles} 'Google\Chrome\Application\chrome.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe'),
    (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'),
    (Join-Path ${env:ProgramFiles} 'Microsoft\Edge\Application\msedge.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'),
    (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\Application\msedge.exe')
  )
  foreach ($path in $candidates) {
    if ($path -and (Test-Path -LiteralPath $path)) {
      $name = if ($path -match 'chrome\.exe$') { 'chrome' } else { 'edge' }
      return @{ Name = $name; Exe = $path }
    }
  }
  return $null
}

$targetUrl = Get-MartxAppUrl -Url $Url -HostName $HostName -Port $Port
$browser = Find-BrowserExe

if ($browser) {
  $args = @("--app=$targetUrl")
  $payload = @{ url = $targetUrl; browser = $browser.Name; exe = $browser.Exe; args = $args }
  if ($ResolveOnly) {
    $payload | ConvertTo-Json -Compress
    exit 0
  }
  Start-Process -FilePath $browser.Exe -ArgumentList $args | Out-Null
  exit 0
}

$payload = @{ url = $targetUrl; browser = 'default'; exe = $null; args = @($targetUrl) }
if ($ResolveOnly) {
  $payload | ConvertTo-Json -Compress
  exit 0
}

Write-Warning "Chrome/Edge not found; opening default browser handler (may show tabs)."
Start-Process $targetUrl
exit 0
