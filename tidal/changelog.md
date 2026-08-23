# Change Log

## 1.9.4.2
- added local Chocolatey packages for SuperCollider 3.14.1, sc3-plugins 3.14.0, and SuperDirt 1.7.4
- pinned SuperCollider, sc3-plugins, and SuperDirt so the TidalCycles package no longer resolves the stale Community packages from 2023
- pinned GHC to 9.6.1, the version currently recommended by the TidalCycles Windows documentation
- pinned Cabal to Chocolatey package 3.10.1.1, the available package revision in the recommended Cabal 3.10.1 series
- SuperCollider and sc3-plugins installers resolve assets from pinned upstream GitHub releases and require a SHA-256 release-asset digest before installation
- sc3-plugins is installed only for 64-bit Windows and replaces an existing `SC3plugins` extension directory during package upgrade
- SuperDirt is installed as Quark version `v1.7.4` and installation failures from `sclang` now propagate back to Chocolatey

This revision is intended for local testing from the repository's package source before publishing any of the new component packages to Chocolatey Community.

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
