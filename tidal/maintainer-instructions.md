Instructions and explanation for how to make updates to the TidalCycles Chocolatey Package.

## Overview

The repository now contains the TidalCycles meta-package plus local package definitions for the Windows components that are stale in Chocolatey Community:

- `supercollider` — SuperCollider 3.14.1
- `sc3plugins` — sc3-plugins 3.14.0
- `superdirt` — SuperDirt 1.7.4
- `tidal` — TidalCycles 1.10.3 meta-package

The component packages are kept separate because Chocolatey dependencies are resolved by package ID. During local testing, all generated `.nupkg` files must therefore be available from the same local source before installing `TidalCycles`.

Chocolatey package documentation: https://docs.chocolatey.org/en-us/create/

## Package layout

```text
supercollider/
  supercollider.nuspec
  tools/
sc3plugins/
  sc3plugins.nuspec
  tools/
superdirt/
  superdirt.nuspec
  tools/
tidal/
  tidal.nuspec
  tools/
scripts/
  pack-local.ps1
```

## Build all local packages

Run PowerShell from the repository root:

```powershell
.\scripts\pack-local.ps1
```

The script creates or refreshes `local-packages` and packs all four packages into it. The repository's historical `dist` directory is deliberately left untouched.

Equivalent manual commands are:

```powershell
New-Item -ItemType Directory -Path .\local-packages -Force | Out-Null
Remove-Item .\local-packages\*.nupkg -ErrorAction SilentlyContinue

choco pack .\supercollider\supercollider.nuspec --output-directory .\local-packages
choco pack .\sc3plugins\sc3plugins.nuspec --output-directory .\local-packages
choco pack .\superdirt\superdirt.nuspec --output-directory .\local-packages
choco pack .\tidal\tidal.nuspec --output-directory .\local-packages
```

Expected local packages are:

```text
SuperCollider.3.14.1.nupkg
sc3plugins.3.14.0.nupkg
superdirt.1.7.4.nupkg
TidalCycles.1.10.3.nupkg
```

## Test the complete stack

A clean Windows VM is strongly recommended. Testing on a machine that already has old Chocolatey packages installed can hide dependency, upgrade, PATH, registry, and uninstall problems.

`choco install` expects a package ID, not a path to a `.nupkg` file. Point `--source` at the directory containing all locally built packages, then add Chocolatey Community so the remaining dependencies can be resolved.

From the repository root:

```powershell
choco install TidalCycles `
  --version="1.10.3" `
  --source=".\local-packages;https://community.chocolatey.org/api/v2/" `
  -y
```

Or use an absolute path:

```powershell
choco install TidalCycles `
  --version="1.10.3" `
  --source="C:\path\to\tidal-chocolatey\local-packages;https://community.chocolatey.org/api/v2/" `
  -y
```

The order of sources matters: the local `local-packages` source is listed first so Chocolatey can resolve the locally maintained SuperCollider, sc3-plugins and SuperDirt packages.

## What the TidalCycles package does after dependencies install

`tidal/tools/chocolateyinstall.ps1`:

1. verifies that Cabal is available;
2. runs `cabal update`;
3. runs `cabal v1-install tidal-1.10.3` and propagates failures;
4. locates Pulsar;
5. installs the Pulsar `tidalcycles` package with `ppm`, with PATH and `pulsar -p` fallbacks;
6. propagates a non-zero exit code instead of silently continuing.

## Dependency policy for 1.10.3

The package pins the components for which version drift can materially affect the Tidal/SuperDirt stack:

- GHC 9.6.1
- Cabal Chocolatey package 3.10.1.1
- SuperCollider 3.14.1
- sc3-plugins 3.14.0
- SuperDirt 1.7.4

The TidalCycles Windows documentation currently recommends GHC 9.6.1 and Cabal 3.10.1.0. Chocolatey Community does not publish a package numbered 3.10.1.0; it publishes 3.10.1.1 in that release series, so this repository pins that available Chocolatey revision.

Git, MSYS2 and Pulsar remain minimum-version dependencies and may resolve to newer approved Community packages. They should be pinned only when testing shows a compatibility reason to do so.

## Updating SuperCollider and sc3-plugins

Their Chocolatey install scripts are intentionally tied to exact upstream GitHub release tags. At install time they locate the exact expected asset and require GitHub's `sha256:` release-asset digest. If the asset name changes, the release disappears, or a valid SHA-256 digest is unavailable, installation stops rather than downloading an unverified file.

When changing either version:

1. update the package version in its `.nuspec`;
2. update `$version` and `$assetName` in its `chocolateyinstall.ps1`;
3. update dependent package version constraints;
4. pack all local packages again;
5. test on a clean Windows environment.

## Updating SuperDirt

The SuperDirt package uses SuperCollider's Quarks system. Change both the package version and the explicit Quark tag in `superdirt/tools/superdirt_install.scd`.

The PowerShell wrapper must return a failure when `sclang` returns a non-zero status so Chocolatey does not report a successful package when Quark installation failed.

## Publishing

Do not publish TidalCycles 1.10.3 or the new component packages to Chocolatey Community until the complete local stack has passed a clean-machine install test.

Before Community publication, each new package should also be reviewed against current Chocolatey moderation requirements, including verification metadata and package-specific licensing/distribution requirements.

Once local testing is complete, each component package would normally need to be published before the `TidalCycles` meta-package that depends on it.
