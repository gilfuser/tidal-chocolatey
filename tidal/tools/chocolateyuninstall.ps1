$ErrorActionPreference = 'Stop'

$startupPath = Join-Path $env:LOCALAPPDATA 'SuperCollider\startup.scd'

$startMarker = '// BEGIN TidalCycles Chocolatey startup'
$endMarker = '// END TidalCycles Chocolatey startup'

if (Test-Path $startupPath) {
    $startupContent = [System.IO.File]::ReadAllText($startupPath)

    $pattern = '(?ms)^' +
        [regex]::Escape($startMarker) +
        '.*?^' +
        [regex]::Escape($endMarker) +
        '\s*\r?\n?'

    $newContent = [regex]::Replace($startupContent, $pattern, '')
    $newContent = $newContent.TrimEnd()

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    if ($newContent.Length -gt 0) {
        [System.IO.File]::WriteAllText(
            $startupPath,
            $newContent + [Environment]::NewLine,
            $utf8NoBom
        )
    }
    else {
        Remove-Item $startupPath -Force
    }

    Write-Host 'Removed TidalCycles-managed SuperCollider startup configuration.'
}
