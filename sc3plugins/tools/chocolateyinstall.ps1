$ErrorActionPreference = 'Stop'

if (-not [Environment]::Is64BitOperatingSystem) {
  throw 'sc3-plugins 3.14.0 package supports only 64-bit Windows.'
}

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

$checksum = $Matches[1]
$extensionsDir = Join-Path $env:LOCALAPPDATA 'SuperCollider\Extensions'
$pluginsDir = Join-Path $extensionsDir 'SC3plugins'
$legacyInstallDir = Join-Path $extensionsDir 'install'
$legacyPluginsDir = Join-Path $legacyInstallDir 'SC3plugins'
$extractDir = Join-Path $env:TEMP "sc3plugins-$version-extract"

New-Item -ItemType Directory -Path $extensionsDir -Force | Out-Null

# Older/local test revisions extracted the upstream archive directly into the
# Extensions directory. The current upstream Windows archive contains an
# intermediate `install` directory, which caused SuperCollider to discover the
# same classes from more than one location on repeated installs. Always extract
# to a temporary directory and copy only the actual SC3plugins directory.
if (Test-Path $pluginsDir) {
  Write-Host "Removing existing $pluginsDir"
  Remove-Item -Path $pluginsDir -Recurse -Force
}

if (Test-Path $legacyPluginsDir) {
  Write-Host "Removing legacy nested $legacyPluginsDir"
  Remove-Item -Path $legacyPluginsDir -Recurse -Force
}

if ((Test-Path $legacyInstallDir) -and -not (Get-ChildItem -Path $legacyInstallDir -Force -ErrorAction SilentlyContinue)) {
  Remove-Item -Path $legacyInstallDir -Force
}

if (Test-Path $extractDir) {
  Remove-Item -Path $extractDir -Recurse -Force
}
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

try {
  Install-ChocolateyZipPackage `
    -PackageName $packageName `
    -Url $asset.browser_download_url `
    -UnzipLocation $extractDir `
    -Checksum $checksum `
    -ChecksumType 'sha256'

  $sourcePluginsDir = Get-ChildItem -Path $extractDir -Directory -Recurse -Filter 'SC3plugins' |
    Select-Object -First 1

  if (-not $sourcePluginsDir) {
    throw "sc3-plugins archive did not contain an SC3plugins directory."
  }

  Write-Host "Installing SC3plugins from $($sourcePluginsDir.FullName) to $pluginsDir"
  Copy-Item -Path $sourcePluginsDir.FullName -Destination $pluginsDir -Recurse -Force

  if (-not (Test-Path $pluginsDir)) {
    throw "sc3-plugins copy completed without creating $pluginsDir."
  }
}
finally {
  if (Test-Path $extractDir) {
    Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
