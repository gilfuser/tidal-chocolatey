# Chocolatey Packages for TidalCycles

This repository contains Chocolatey packages for the TidalCycles live-coding environment on Windows.

## TidalCycles Installation

### Stable Chocolatey release

The current public Chocolatey package can be installed with:

```powershell
choco install tidalcycles -y
```

This installs the version currently published in Chocolatey Community.

Chocolatey package page:

https://community.chocolatey.org/packages/TidalCycles

### Test the updated TidalCycles 1.10.3 stack

This repository also contains an updated Windows stack with:

- TidalCycles 1.10.3
- GHC 9.6.1
- Cabal 3.10.1.1
- SuperCollider 3.14.1
- sc3-plugins 3.14.0
- SuperDirt 1.7.4
- Pulsar with the `tidalcycles` package

Until these updated component packages are published in Chocolatey Community,
build them locally first.

Clone this repository and switch to the modernization branch:

```powershell
git clone https://github.com/gilfuser/tidal-chocolatey.git
cd tidal-chocolatey
```

Build all locally maintained Chocolatey packages:

```powershell
.\scripts\pack-local.ps1
```

Then install TidalCycles, using the local packages first and Chocolatey Community
for the remaining dependencies:

```powershell
choco install TidalCycles `
  --version="1.10.3" `
  --source=".\local-packages;https://community.chocolatey.org/api/v2/" `
  -y
```

The local packages include:

```text
SuperCollider 3.14.1
sc3plugins 3.14.0
superdirt 1.7.4
TidalCycles 1.10.3
```

Other dependencies such as GHC, Cabal, Git, MSYS2 and Pulsar are resolved through
Chocolatey Community.

## Starting TidalCycles

After installation:

1. Start SuperCollider.
2. Evaluate:

```supercollider
SuperDirt.start;
```

3. Start Pulsar.
4. Open a Tidal file and evaluate:

```haskell
d1 $ sound "bd sd"
```

5. Stop playback with:

```haskell
hush
```

## More information

TidalCycles:

https://tidalcycles.org/

SuperCollider:

https://supercollider.github.io/

Pulsar:

https://pulsar-edit.dev/

Chocolatey:

https://chocolatey.org/

For detailed package maintenance, build and testing instructions, see:

[tidal/maintainer-instructions.md](tidal/maintainer-instructions.md)
