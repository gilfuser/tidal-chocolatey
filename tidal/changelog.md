# Change Log

## 1.9.4.1
- fixed the Pulsar package installation to use `ppm` instead of the retired Atom `apm` command
- added explicit failure handling for `cabal update`, Tidal installation, and Pulsar package installation
- added validation that Pulsar, Cabal, and Pulsar Package Manager can be found before continuing
- added fallbacks for bundled `ppm`, `ppm` on PATH, and `pulsar -p`
- updated package source and release-notes metadata to point to the maintained fork
- kept the dependency versions unchanged in this revision so installer fixes can be tested separately from the dependency modernization work

## 1.9.4
- set dependencies to exact versions with [] for ghc, cabal, msys2 in tidal.nuspec
- changed download link for pulsar installer in powershell
- changed version to 1.9.4 
- NOTE: 1.9.4 was rejected by the Moderators. The requirement is that Pulsar and SuperDirt be split out as separate packages. 

## 1.9.3
- Removed Atom, added Pulsar via download (no Pulsar package in Chocolatey yet)
- Updated tidal.nuspec with new Tidal version 
- updated chocolateyinstall.ps1 with Pulsar install, modified the install commands
- enabled Pulsar install to be non-interactive (silent) and PS to wait for completion

## 1.7.8
Updated dependencies.

## 0.9.4
Initial release.
