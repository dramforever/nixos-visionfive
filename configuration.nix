{ config, pkgs, lib, modulesPath, ... }:

{
  disabledModules = [ "hardware/device-tree.nix" ];
  imports = [ ./modules/device-tree.nix ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "/var/lib/age-key.txt";
      sshKeyPaths = [ ];
    };

    gnupg.sshKeyPaths = [ ];

    secrets = {
      wpa_supplicant = {};
    };
  };

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_starfive;

    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
      "earlycon=sbi"
      # https://github.com/starfive-tech/linux/issues/14
      "stmmac.chain_mode=1"
    ];

    initrd.kernelModules = [ "dw-axi-dmac-platform" "dw_mmc-pltfm" "spi-dw-mmio" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/misaki-nixos";
    fsType = "ext4";
  };

  hardware.deviceTree = {
    name = "starfive/jh7100-starfive-visionfive-v1.dtb";
    filter = baseNameOf config.hardware.deviceTree.name;
    overlays = [
      {
        name = "jtag-pins";
        dtsFile = ./dt-overlays/jtag-pins.dts;
      }
    ];
  };

  hardware.enableRedistributableFirmware = true;

  hardware.firmware = [
    (pkgs.runCommand "visionfive-brcmfmac-fix" {} ''
      mkdir -p $out/lib/firmware/brcm
      cp ${pkgs.linux-firmware}/lib/firmware/brcm/brcmfmac43430-sdio.AP6212.txt \
          $out/lib/firmware/brcm/brcmfmac43430-sdio.starfive,visionfive-v1.txt
    '')
  ];

  systemd.services."serial-getty@hvc0".enable = false;

  networking.hostName = "misaki";

  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets.wpa_supplicant.path;
    extraConfig = ''
      @EXTRA_CONFIG@
    '';
  };

  security.polkit.enable = false;
  services.udisks2.enable = false;

  services = {
    getty.autologinUser = "root";
    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2X4EKIQTUUctgGnrXhHYddKzs69hXsmEK2ePBzSIwM"
    ];
  };

  environment.systemPackages = with pkgs; [ neofetch ];

  system.stateVersion = "21.11";
}
