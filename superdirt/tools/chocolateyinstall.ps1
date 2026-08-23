$ErrorActionPreference = 'Stop'

$packageName = 'superdirt'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installScript = Join-Path $toolsDir 'superdirt_install.scd'

function Find-Sclang {
  $command = Get-Command sclang.exe -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }

  $candidates = @(
    (Join-Path $env:ProgramFiles 'SuperCollider-*\sclang.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'SuperCollider-*\sclang.exe')
  )

  foreach ($pattern in $candidates) {
    if (-not $pattern) { continue }
    $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue |
      Sort-Object FullName -Descending |
      Select-Object -First 1
    if ($found) { return $found.FullName }
  }

  throw 'sclang.exe was not found. SuperCollider must be installed before SuperDirt.'
}

$sclang = Find-Sclang
$gitDir = 'C:\Program Files\Git\cmd'
if (Test-Path $gitDir) {
  $env:Path = "$gitDir;$env:Path"
}

Write-Host "Installing SuperDirt 1.7.4 with $sclang"
& $sclang $installScript

if ($LASTEXITCODE -ne 0) {
  throw "SuperDirt installation failed with sclang exit code $LASTEXITCODE."
}
