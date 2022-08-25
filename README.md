# nixos-visionfive

The NixOS configuration I run on my VisionFive board.

Requires a U-Boot installation that supports Distroboot, e.g. [NickCao/u-boot-starfive].

[NickCao/u-boot-starfive]: https://github.com/NickCao/u-boot-starfive

## Notes on some files

### `secrets.yaml`

My secret stuff. You just don't get to see them.

Currently used for:

- `networking.wireless` configuration (`wpa_supplicant`)

### `starfive-linux.nix`

Based on: https://github.com/MatthewCroughan/visionfive-nix/blob/master/kernel.nix

### `dt-overlays/jtag-pins.dts`

A device tree overlay that keeps JTAG pins available even after boot.
