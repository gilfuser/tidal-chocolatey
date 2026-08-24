$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $repoRoot 'local-packages'

if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
  throw 'choco.exe was not found on PATH.'
}

$requiredSubmodules = @(
  'components\sc-chocolatey',
  'components\superdirt-chocolatey'
)

foreach ($relativePath in $requiredSubmodules) {
  $path = Join-Path $repoRoot $relativePath
  if (-not (Test-Path $path)) {
    throw "Submodule not initialized: $relativePath. Run: git submodule update --init --recursive"
  }
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
Get-ChildItem -Path $outputDir -Filter '*.nupkg' -ErrorAction SilentlyContinue |
  Remove-Item -Force

$packages = @(
  'components\sc-chocolatey\supercollider\supercollider-chocolatey.nuspec',
  'components\sc-chocolatey\sc3-plugins\sc3-plugins.nuspec',
  'components\superdirt-chocolatey\superdirt\superdirt.nuspec',
  'tidal\tidal.nuspec'
)

foreach ($relativePath in $packages) {
  $nuspec = Join-Path $repoRoot $relativePath
  if (-not (Test-Path $nuspec)) {
    throw "Package definition not found: $nuspec"
  }

  Write-Host "Packing $relativePath"
  & choco.exe pack $nuspec --output-directory $outputDir
  if ($LASTEXITCODE -ne 0) {
    throw "choco pack failed for $relativePath with exit code $LASTEXITCODE."
  }
}

Write-Host ''
Write-Host "Packages created in $outputDir`:"
Get-ChildItem -Path $outputDir -Filter '*.nupkg' |
  Sort-Object Name |
  ForEach-Object { Write-Host "  $($_.Name)" }
