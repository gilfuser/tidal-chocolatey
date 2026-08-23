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

# SuperCollider's Quarks implementation invokes git. Git writes normal clone
# progress (for example, "Cloning into ...") to stderr even when the command
# succeeds. PowerShell 7 can promote native stderr to a terminating error when
# $PSNativeCommandUseErrorActionPreference is enabled, which made Chocolatey
# abort before sclang could return its real exit code. Disable that behavior
# only for this native sclang process and validate $LASTEXITCODE ourselves.
$hadNativePreference = Test-Path variable:PSNativeCommandUseErrorActionPreference
if ($hadNativePreference) {
  $previousNativePreference = $PSNativeCommandUseErrorActionPreference
  $PSNativeCommandUseErrorActionPreference = $false
}

try {
  & $sclang $installScript
  $sclangExitCode = $LASTEXITCODE
}
finally {
  if ($hadNativePreference) {
    $PSNativeCommandUseErrorActionPreference = $previousNativePreference
  }
}

if ($sclangExitCode -ne 0) {
  throw "SuperDirt installation failed with sclang exit code $sclangExitCode."
}
