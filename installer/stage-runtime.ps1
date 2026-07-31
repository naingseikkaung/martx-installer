param(
  [Parameter(Mandatory = $true)][string]$SourceRoot,
  [Parameter(Mandatory = $true)][string]$StageRoot
)
$ErrorActionPreference = 'Stop'

$srcDist = Join-Path $SourceRoot 'frontend\dist'
if (-not (Test-Path -Path $srcDist)) {
  Write-Host "Frontend build output not found. Running the frontend build from $SourceRoot."
  Push-Location $SourceRoot
  npm run build --prefix frontend
  Pop-Location
}
if (-not (Test-Path -Path $srcDist)) {
  Write-Error "Frontend build output not found at $srcDist after the build."
  exit 1
}

New-Item -ItemType Directory -Force "$StageRoot/backend", "$StageRoot/frontend/dist" | Out-Null
Copy-Item "$SourceRoot/backend/*.js" "$StageRoot/backend" -Force
Copy-Item "$SourceRoot/backend/src" "$StageRoot/backend" -Recurse -Force
Copy-Item "$SourceRoot/backend/package.json", "$SourceRoot/backend/package-lock.json" "$StageRoot/backend" -Force
Copy-Item "$srcDist\*" "$StageRoot/frontend/dist" -Recurse -Force

Push-Location "$StageRoot/backend"
# sqlite3 is a native dependency. Keep install scripts enabled so npm can
# download/build node_sqlite3.node for the Node ABI used by this installer.
npm ci --omit=dev
Pop-Location

node "$PSScriptRoot/verify-package.js" $StageRoot
