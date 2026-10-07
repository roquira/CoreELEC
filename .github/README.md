# CoreELEC (roquira)

[![Check](https://github.com/roquira/CoreELEC/actions/workflows/check.yml/badge.svg?branch=piers%2Fcustomizations&event=push)](https://github.com/roquira/CoreELEC/actions/workflows/check.yml) [![Latest release](https://img.shields.io/github/v/release/roquira/CoreELEC?include_prereleases)](https://github.com/roquira/CoreELEC/releases) [![License: GPLv2](https://img.shields.io/badge/license-GPLv2-blue)](../licenses/GPL-2.0-only.txt)

My personal [CoreELEC](https://coreelec.org) 22 build for a Xiaomi TV Box S (3rd Gen), with custom [Kodi fixes and features](https://github.com/roquira/xbmc/commits/piers/customizations).

Not affiliated with or supported by CoreELEC or Team Kodi. Report [issues here](https://github.com/roquira/CoreELEC/issues); report upstream only if they also occur on an official build.

## Installation

Download from [Releases](https://github.com/roquira/CoreELEC/releases), which lists the changes in each build. Back up Kodi userdata first: this build upgrades the video database to a schema official builds don't recognize.

- Fresh installation: write `…-Generic.img.gz` to SD or USB.
- Update: copy `….tar` to the `Update` share (`/storage/.update`) and reboot.

Set automatic updates to manual to prevent an official update replacing this build.

Install the companion skin, [Estuary (roquira)](https://github.com/roquira/skin.estuary.roquira), separately.

## Building

```sh
PROJECT=Amlogic-ce ARCH=aarch64 DEVICE=Amlogic-no make image
```

See [MAINTAINING.md](MAINTAINING.md) for releases and rebasing.

## Credits and license

Based on [CoreELEC](https://github.com/CoreELEC/CoreELEC), [LibreELEC](https://github.com/LibreELEC/LibreELEC.tv) and [Kodi](https://github.com/xbmc/xbmc).

CoreELEC is [GPLv2](../licenses/GPL-2.0-only.txt); Kodi changes are GPLv2 or later. Upstream components retain their own [licenses](../licenses).
