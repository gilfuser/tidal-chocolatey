# Chocolatey Packages for TidalCycles

This repository hosts the Chocolatey packaging used by the TidalCycles Windows installer.

## TidalCycles installation

For the public Chocolatey package:

```powershell
choco install tidalcycles
```

## Temporary component-fork integration

While the SuperCollider, sc3-plugins and SuperDirt package updates are waiting for their upstream PRs to be merged and published on Chocolatey Community, the `integrate/component-forks-submodules` branch uses the tested package forks as Git submodules.

Clone it with submodules:

```powershell
git clone --branch integrate/component-forks-submodules --recurse-submodules https://github.com/gilfuser/tidal-chocolatey.git
cd tidal-chocolatey
```

If the repository was cloned without `--recurse-submodules`:

```powershell
git submodule update --init --recursive
```

Build the local package source:

```powershell
.\scripts\pack-local.ps1
```

This creates local packages for SuperCollider 3.14.1, sc3-plugins 3.14.0, SuperDirt 1.7.4 and TidalCycles 1.10.3 under `local-packages`.

Install the local TidalCycles package with the public Chocolatey feed as fallback for the remaining dependencies:

```powershell
choco install TidalCycles `
  --version="1.10.3" `
  --source=".\local-packages;https://community.chocolatey.org/api/v2/" `
  -y
```

The submodules are temporary. Once the component PRs are merged and their updated packages are available on Chocolatey Community, the TidalCycles package can return to depending only on the public component packages.

## After installation

Start SuperCollider and evaluate:

```supercollider
SuperDirt.start;
```

Then start Pulsar and evaluate Tidal code, for example:

```haskell
d1 $ sound "bd sn"
```

## Repository contents

- `tidal/`: TidalCycles Chocolatey package
- `components/sc-chocolatey/`: temporary submodule containing the SuperCollider and sc3-plugins package updates
- `components/superdirt-chocolatey/`: temporary submodule containing the SuperDirt package update
- `scripts/pack-local.ps1`: builds the complete local Chocolatey source
- `tidal/maintainer-instructions.md`: package maintenance notes
