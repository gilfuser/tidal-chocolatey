$ErrorActionPreference = 'Stop'

$packageName = 'superdirt'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installScript = Join-Path $toolsDir 'superdirt_install.scd'
$successMarker = Join-Path $env:TEMP "superdirt-chocolatey-$PID.success"

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

if (Test-Path $successMarker) {
  Remove-Item $successMarker -Force
}

# The SuperCollider script writes this marker immediately after confirming that
# the SuperDirt Quark is installed, before requesting 0.exit. On Windows,
# sclang can occasionally remain alive while printing "cleaning up OSC". The
# marker lets Chocolatey distinguish that shutdown hang from an install failure.
$env:SUPERDIRT_CHOCO_SUCCESS_MARKER = $successMarker

Write-Host "Installing SuperDirt 1.7.4 with $sclang"

# Quarks invokes git internally. Git writes normal progress and warnings to
# stderr. Start-Process lets sclang inherit the console streams directly so
# Chocolatey's ErrorActionPreference=Stop does not turn normal git stderr into
# a terminating PowerShell error.
$process = Start-Process `
  -FilePath $sclang `
  -ArgumentList @("`"$installScript`"") `
  -NoNewWindow `
  -PassThru

$deadline = (Get-Date).AddMinutes(20)
$successSeenAt = $null

try {
  while (-not $process.HasExited) {
    if (Test-Path $successMarker) {
      if (-not $successSeenAt) {
        $successSeenAt = Get-Date
      }
      elseif (((Get-Date) - $successSeenAt).TotalSeconds -ge 10) {
        Write-Warning 'SuperDirt installed successfully, but sclang did not exit after 10 seconds. Stopping the hung sclang shutdown process.'
        Stop-Process -Id $process.Id -Force
        break
      }
    }

    if ((Get-Date) -ge $deadline) {
      Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
      throw 'SuperDirt installation timed out after 20 minutes.'
    }

    Start-Sleep -Milliseconds 500
    $process.Refresh()
  }

  if (Test-Path $successMarker) {
    Write-Host 'SuperDirt 1.7.4 installation confirmed.'
    return
  }

  $process.Refresh()
  if ($process.HasExited -and $process.ExitCode -ne 0) {
    throw "SuperDirt installation failed with sclang exit code $($process.ExitCode)."
  }

  throw 'sclang exited without confirming that SuperDirt 1.7.4 was installed.'
}
finally {
  Remove-Item Env:SUPERDIRT_CHOCO_SUCCESS_MARKER -ErrorAction SilentlyContinue
  Remove-Item $successMarker -Force -ErrorAction SilentlyContinue
}
