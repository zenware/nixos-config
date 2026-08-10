{
  config,
  inputs,
  options,
  pkgs,
  lib,
  homeManagerModules,
  ...
}:
let
  isDesktop = lib.attrByPath [ "zw" "desktop" "enable" ] pkgs.stdenv.isDarwin config;
in
{
  # NOTE: Some software should follow my user, rather than being deployed to a specific system.
  # not sure I've actually worked out where that delineation is best made yet.
  environment.systemPackages = [
    pkgs.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      username = "jml";
    };
    users.jml.imports = [
      homeManagerModules.jml
    ]
    ++ lib.optional isDesktop homeManagerModules.jml-desktop
    ++ lib.optional (isDesktop && pkgs.stdenv.isLinux) homeManagerModules.jml-linux-desktop
    ++ lib.optional (isDesktop && lib.hasAttrByPath [ "stylix" "enable" ] options) inputs.stylix.homeModules.stylix;
  };

  nix.settings.trusted-users = lib.mkAfter [ "jml" ];
  users.users.jml = {
    shell =
      if pkgs.stdenv.isLinux then
        pkgs.fish
      else if pkgs.stdenv.isDarwin then
        pkgs.zsh
      else
        abort "Unsupported OS";
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
