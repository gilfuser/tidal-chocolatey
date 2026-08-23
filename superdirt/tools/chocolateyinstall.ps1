$ErrorActionPreference = 'Stop'

$packageName = 'superdirt'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installScript = Join-Path $toolsDir 'superdirt_install.scd'

function Find-Sclang {
  $command = Get-Command sclang.exe -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }

  $candidates = @()
  if ($env:ProgramFiles) {
    $candidates += Join-Path $env:ProgramFiles 'SuperCollider-*\sclang.exe'
  }
  if (${env:ProgramFiles(x86)}) {
    $candidates += Join-Path ${env:ProgramFiles(x86)} 'SuperCollider-*\sclang.exe'
  }

  foreach ($pattern in $candidates) {
    $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue |
      Sort-Object FullName -Descending |
      Select-Object -First 1
    if ($found) { return $found.FullName }
  }

  throw 'sclang.exe was not found. SuperCollider must be installed before SuperDirt.'
}

$sclang = Find-Sclang
$gitDirs = @(
  'C:\Program Files\Git\cmd',
  'C:\Program Files (x86)\Git\cmd'
)
foreach ($gitDir in $gitDirs) {
  if (Test-Path $gitDir) {
    $env:Path = "$gitDir;$env:Path"
    break
  }
}

Write-Host "Installing SuperDirt 1.7.4 with $sclang"

# Quarks invokes git internally. Git writes normal progress and warnings to
# stderr, including successful clone progress and configuration deprecation
# hints. Windows PowerShell 5.1 can convert native stderr into NativeCommandError
# records; with Chocolatey's ErrorActionPreference=Stop this aborts the package
# even when git/sclang are succeeding. Start-Process lets sclang inherit the
# console streams directly, bypassing PowerShell's native stderr conversion.
# We determine success exclusively from sclang's process exit code.
$process = Start-Process `
  -FilePath $sclang `
  -ArgumentList @("`"$installScript`"") `
  -NoNewWindow `
  -Wait `
  -PassThru

if ($process.ExitCode -ne 0) {
  throw "SuperDirt installation failed with sclang exit code $($process.ExitCode)."
}
