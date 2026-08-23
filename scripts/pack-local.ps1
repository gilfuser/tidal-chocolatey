$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $repoRoot 'dist'

if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
  throw 'choco.exe was not found on PATH.'
}

New-Item -ItemType Directory -Path $dist -Force | Out-Null
Get-ChildItem -Path $dist -Filter '*.nupkg' -ErrorAction SilentlyContinue |
  Remove-Item -Force

$packages = @(
  'supercollider\supercollider.nuspec',
  'sc3plugins\sc3plugins.nuspec',
  'superdirt\superdirt.nuspec',
  'tidal\tidal.nuspec'
)

foreach ($relativePath in $packages) {
  $nuspec = Join-Path $repoRoot $relativePath
  if (-not (Test-Path $nuspec)) {
    throw "Package definition not found: $nuspec"
  }

  Write-Host "Packing $relativePath"
  & choco.exe pack $nuspec --output-directory $dist
  if ($LASTEXITCODE -ne 0) {
    throw "choco pack failed for $relativePath with exit code $LASTEXITCODE."
  }
}

Write-Host ''
Write-Host 'Packages created:'
Get-ChildItem -Path $dist -Filter '*.nupkg' |
  Sort-Object Name |
  ForEach-Object { Write-Host "  $($_.Name)" }
