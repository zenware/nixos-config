{ pkgs, lib, ... }:
{
  users.users.breakglass = {
    home =
      if pkgs.stdenv.isLinux then
        lib.mkDefault "/home/breakglass"
      else if pkgs.stdenv.isDarwin then
        lib.mkDefault "/Users/breakglass"
      else
        abort "Unsupported OS";
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # NOTE: Generated with `mkpasswd`
    hashedPassword = "$y$j9T$U7phasQYqMhxY8WXoiHL51$IHHDTreR4uZrvAC1Xusjy2M0yXkU.vLy3z6zBjZCFX.";
  };
}
