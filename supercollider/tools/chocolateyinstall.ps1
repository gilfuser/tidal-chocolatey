$ErrorActionPreference = 'Stop'

if (-not [Environment]::Is64BitOperatingSystem) {
  throw 'SuperCollider 3.14.1 package supports only 64-bit Windows.'
}

$packageName = 'supercollider'
$version = '3.14.1'
$assetName = 'SuperCollider-3.14.1_Release-x64-VS-426edf6.exe'
$releaseApi = "https://api.github.com/repos/supercollider/supercollider/releases/tags/Version-$version"

Write-Host "Resolving official SuperCollider $version release asset..."
$headers = @{ 'User-Agent' = 'tidal-chocolatey' }
$release = Invoke-RestMethod -Uri $releaseApi -Headers $headers
$asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1

if (-not $asset) {
  throw "Could not find $assetName in SuperCollider release Version-$version."
}

if (-not $asset.digest -or $asset.digest -notmatch '^sha256:([0-9a-fA-F]{64})$') {
  throw "GitHub did not provide a valid SHA-256 digest for $assetName."
}

$checksum = $Matches[1]

$packageArgs = @{
  packageName    = $packageName
  fileType       = 'EXE'
  url            = $asset.browser_download_url
  softwareName   = "SuperCollider Version $version"
  checksum       = $checksum
  checksumType   = 'sha256'
  validExitCodes = @(0, 3010, 1641)
  silentArgs     = '/S'
}

Install-ChocolateyPackage @packageArgs
