$ErrorActionPreference = 'Stop'

$packageName = 'sc3plugins'
$version = '3.14.0'
$assetName = 'sc3-plugins-3.14.0-Windows-64bit.zip'
$releaseApi = "https://api.github.com/repos/supercollider/sc3-plugins/releases/tags/Version-$version"
$headers = @{ 'User-Agent' = 'tidal-chocolatey' }

Write-Host "Resolving official sc3-plugins $version release asset..."
$release = Invoke-RestMethod -Uri $releaseApi -Headers $headers
$asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1

if (-not $asset) {
  throw "Could not find $assetName in sc3-plugins release Version-$version."
}

if (-not $asset.digest -or $asset.digest -notmatch '^sha256:([0-9a-fA-F]{64})$') {
  throw "GitHub did not provide a valid SHA-256 digest for $assetName."
}

$checksum64 = $Matches[1]
$extensionsDir = Join-Path $env:LOCALAPPDATA 'SuperCollider\Extensions'
$pluginsDir = Join-Path $extensionsDir 'SC3plugins'

if (-not (Test-Path $extensionsDir)) {
  New-Item -ItemType Directory -Path $extensionsDir -Force | Out-Null
}

if (Test-Path $pluginsDir) {
  Write-Host "Removing existing SC3plugins directory before installing $version..."
  Remove-Item -Path $pluginsDir -Recurse -Force
}

Install-ChocolateyZipPackage `
  -PackageName $packageName `
  -Url64bit $asset.browser_download_url `
  -UnzipLocation $extensionsDir `
  -Checksum64 $checksum64 `
  -ChecksumType64 'sha256'

if (-not (Test-Path $pluginsDir)) {
  throw "sc3-plugins archive was extracted, but $pluginsDir was not created."
}
