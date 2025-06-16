{ pkgs, lib, ... }:
{
  programs.fish.enable = true;
  users.users.jml = {
    shell = pkgs.fish;
    home =
      if pkgs.stdenv.isLinux then
        lib.mkDefault "/home/jml"
      else if pkgs.stdenv.isDarwin then
        lib.mkDefault "/Users/jml"
      else
        abort "Unsupported OS";
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "samba" ];
    initialHashedPassword = "$y$j9T$R9y36VAOEudqmyVVgyYLD1$xQktVMaRP9qiARiJ6KATvyH6VAL1IKSJoPAo7k4YNZ.";
  };
}
