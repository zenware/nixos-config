{ config, ... }:
{
  # GPU Things
  # NOTE: The following command can be helpful when diagnosing GPU issues:
  # `nix shell nixpkgs#vulkan-tools -c vulkaninfo --summary`
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  # NOTE: This acceptLicense thing was necessary for nvidia packages to begin
  # working, and it seems undocumented in the usual places.
  # I found it on a forum thread, and then inside the nixpkgs repo.
  # https://discourse.nixos.org/t/nvidia-settings-and-nvidia-offload-not-found/37187/23
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/generic.nix#L65
  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {
    # TODO: Consider legacy drivers.
    # https://discourse.nixos.org/t/cant-use-nvidia-offload-mode/27791/8
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    # Open Source Drivers: https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    open = false;
    nvidiaSettings = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };
}
