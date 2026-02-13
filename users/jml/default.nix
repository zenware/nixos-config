{ pkgs, lib, ... }:
{
  # NOTE: Some software should follow my user, rather than being deployed to a specific system.
  # not sure I've actually worked out where that delineation is best made yet.
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.telegram-desktop
    pkgs.libsecret # Used for secrets daemon /w keepassxc
  ];
  nix.settings.trusted-users = lib.mkAfter [ "jml" ];
  users.users.jml = {
    shell = pkgs.fish;
    home =
      if pkgs.stdenv.isLinux then
        lib.mkDefault "/home/jml"
      else if pkgs.stdenv.isDarwin then
        lib.mkDefault "/Users/jml"
      else
        abort "Unsupported OS";
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "samba"
    ];
    initialHashedPassword = "$y$j9T$R9y36VAOEudqmyVVgyYLD1$xQktVMaRP9qiARiJ6KATvyH6VAL1IKSJoPAo7k4YNZ.";
  };
}
