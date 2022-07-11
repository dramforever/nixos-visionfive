# nixos-visionfive

The NixOS configuration I run on my VisionFive board.

Requires a U-Boot installation that supports Distroboot, e.g. [NickCao/u-boot-starfive].

[NickCao/u-boot-starfive]: https://github.com/NickCao/u-boot-starfive

## Notes on some files

### `starfive-linux.nix`

Based on: https://github.com/MatthewCroughan/visionfive-nix/blob/master/kernel.nix

### `dt-overlays/jtag-pins.dts`

A device tree overlay that keeps JTAG pins available even after boot.

### `modules/device-tree.nix`

Modified version of `nixos/modules/hardware/device-tree.nix` from Nixpkgs.

See: https://github.com/NixOS/nixpkgs/pull/181063
