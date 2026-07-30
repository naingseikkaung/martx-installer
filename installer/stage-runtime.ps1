param(
  [Parameter(Mandatory = $true)][string]$SourceRoot,
  [Parameter(Mandatory = $true)][string]$StageRoot
)
$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force "$StageRoot/backend", "$StageRoot/frontend/dist" | Out-Null
Copy-Item "$SourceRoot/backend/*.js" "$StageRoot/backend" -Force
Copy-Item "$SourceRoot/backend/src" "$StageRoot/backend" -Recurse -Force
Copy-Item "$SourceRoot/backend/package.json", "$SourceRoot/backend/package-lock.json" "$StageRoot/backend" -Force
Copy-Item "$SourceRoot/frontend/dist/*" "$StageRoot/frontend/dist" -Recurse -Force

Push-Location "$StageRoot/backend"
npm ci --omit=dev --ignore-scripts
Pop-Location

node "$PSScriptRoot/verify-package.js" $StageRoot
