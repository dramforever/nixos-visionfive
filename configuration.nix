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
      # "clk_ignore_unused"
    ];

    initrd.kernelModules = [
      "dw-axi-dmac-platform"
      "dw_mmc-pltfm"
      "spi-dw-mmio"
      "ledtrig-heartbeat"
    ];

    kernelModules = [
      "spi-cadence-quadspi"
      "mtd"
      "mtdblock"
    ];
  };

  boot.extraModulePackages = [
    config.boot.kernelPackages.visionfive-kernel-modules
  ];

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
      {
        name = "spi-flash";
        dtsFile = ./dt-overlays/spi-flash.dts;
      }
      {
        name = "gpu";
        dtsFile = ./dt-overlays/gpu.dts;
      }
      {
        name = "hypervisor";
        dtsFile = ./dt-overlays/hypervisor.dts;
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

  security.sudo.wheelNeedsPassword = false;

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2X4EKIQTUUctgGnrXhHYddKzs69hXsmEK2ePBzSIwM"
    ];
    users.dram = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2X4EKIQTUUctgGnrXhHYddKzs69hXsmEK2ePBzSIwM"
      ];
    };
  };

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  environment.systemPackages = with pkgs; [
    neofetch
    binderlay
  ];

  system.stateVersion = "21.11";
}
