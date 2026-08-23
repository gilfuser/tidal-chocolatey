$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$uninstallScript = Join-Path $toolsDir 'superdirt_uninstall.scd'

$command = Get-Command sclang.exe -ErrorAction SilentlyContinue
if (-not $command) {
  Write-Warning 'sclang.exe was not found; SuperDirt may already have been removed with SuperCollider.'
  return
}

& $command.Source $uninstallScript
if ($LASTEXITCODE -ne 0) {
  throw "SuperDirt uninstall failed with sclang exit code $LASTEXITCODE."
}
