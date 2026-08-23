$ErrorActionPreference = 'Stop'

$packageName = 'supercollider'
$softwareName = 'SuperCollider Version 3.14.1'
$installerType = 'EXE'
$silentArgs = '/S'
$validExitCodes = @(0)

[array]$keys = Get-UninstallRegistryKey -SoftwareName $softwareName

if ($keys.Count -eq 1) {
  $keys | ForEach-Object {
    $file = "$($_.UninstallString)"
    Uninstall-ChocolateyPackage -PackageName $packageName `
      -FileType $installerType `
      -SilentArgs $silentArgs `
      -ValidExitCodes $validExitCodes `
      -File $file
  }
} elseif ($keys.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} else {
  Write-Warning "$($keys.Count) matching uninstall entries found; refusing to guess."
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
}
