$ErrorActionPreference = 'Stop'

$pluginsDir = Join-Path $env:LOCALAPPDATA 'SuperCollider\Extensions\SC3plugins'

if (Test-Path $pluginsDir) {
  Write-Host "Removing $pluginsDir"
  Remove-Item -Path $pluginsDir -Recurse -Force
}
