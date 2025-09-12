{ config, ... }: {
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
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };
}
