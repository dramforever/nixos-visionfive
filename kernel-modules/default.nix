{ stdenv, lib, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  name = "visionfive-kernel-modules";

  src = ./.;

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  CROSS_COMPILE = stdenv.cc.targetPrefix;
  ARCH = stdenv.hostPlatform.linuxArch;

  makeFlags = [
    "-C${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
    "M=$(PWD)"
  ];

  installTargets = "modules_install";
}
