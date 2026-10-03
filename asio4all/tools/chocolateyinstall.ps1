$ErrorActionPreference = 'Stop'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'EXE'
    url            = 'https://asio4all.org/downloads/ASIO4ALL_2_22.exe'
    softwareName   = 'ASIO4ALL*'
    checksum       = '0D4F0C63BF5DF077E4C74F18372F72B8E875A9ABEA499FEA78AAA9F56022AC7E'
    checksumType   = 'sha256'
    silentArgs     = '/S'
    validExitCodes = @(0)
}

Install-ChocolateyPackage @packageArgs
