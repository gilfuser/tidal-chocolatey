$ErrorActionPreference = 'Stop'

$packageName = 'tidalcycles'
$tidalVersion = '1.10.3'

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    & $Command @Arguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "$Description failed with exit code $exitCode."
    }
}

# Locate Pulsar after Chocolatey has installed the dependency.
$pulsarPath = Get-AppInstallLocation Pulsar
if (-not $pulsarPath) {
    throw 'Pulsar installation was not found. The TidalCycles editor package cannot be installed.'
}

$machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath;$pulsarPath"

# Install the Tidal Haskell library. Keep the Chocolatey package version and
# the installed Hackage package version aligned for reproducible installs.
# The official Windows documentation still recommends the v1-install command
# for the Chocolatey installation path.
if (-not (Get-Command cabal -ErrorAction SilentlyContinue)) {
    throw 'cabal was not found on PATH after installing the Chocolatey dependencies.'
}

Write-Host "Installing Tidal Haskell library $tidalVersion. This may take time."
Invoke-NativeCommand -Command 'cabal' -Arguments @('update') -Description 'cabal update'
Invoke-NativeCommand -Command 'cabal' -Arguments @('v1-install', "tidal-$tidalVersion") -Description "Tidal $tidalVersion Haskell library installation"

# Install the TidalCycles package for Pulsar. Pulsar uses ppm (Pulsar Package
# Manager), not Atom's retired apm command. Prefer the ppm bundled with the
# detected Pulsar installation, then fall back to ppm/pulsar available on PATH.
$ppmCandidates = @(
    (Join-Path $pulsarPath 'Resources\app\ppm\bin\ppm.cmd'),
    (Join-Path $pulsarPath 'Resources\app\ppm\bin\ppm')
)

$ppmPath = $ppmCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

Write-Host 'Installing the TidalCycles package for Pulsar.'
Write-Host "Pulsar path: $pulsarPath"

if ($ppmPath) {
    Invoke-NativeCommand -Command $ppmPath -Arguments @('install', 'tidalcycles') -Description 'Pulsar TidalCycles package installation'
}
else {
    $ppmCommand = Get-Command ppm.cmd -ErrorAction SilentlyContinue
    if (-not $ppmCommand) {
        $ppmCommand = Get-Command ppm -ErrorAction SilentlyContinue
    }

    if ($ppmCommand) {
        Invoke-NativeCommand -Command $ppmCommand.Source -Arguments @('install', 'tidalcycles') -Description 'Pulsar TidalCycles package installation'
    }
    else {
        $pulsarCommand = Get-Command pulsar.cmd -ErrorAction SilentlyContinue
        if (-not $pulsarCommand) {
            $pulsarCommand = Get-Command pulsar -ErrorAction SilentlyContinue
        }

        if ($pulsarCommand) {
            Invoke-NativeCommand -Command $pulsarCommand.Source -Arguments @('-p', 'install', 'tidalcycles') -Description 'Pulsar TidalCycles package installation'
        }
        else {
            throw 'Pulsar Package Manager (ppm) was not found. Install the TidalCycles package from Pulsar Package Manager and retry.'
        }
    }
}

Write-Host ''
Write-Host "TidalCycles $tidalVersion installation steps completed successfully."
Write-Host 'Review the Start Tidal documentation to configure SuperDirt and start Tidal:'
Write-Host 'https://tidalcycles.org/docs/getting-started/tidal_start/'
