{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
    in
    {
      nixosModules.default =
        { config, ... }:
        {
          options.nixpkgs = lib.mkOption {
            description = "A submodule that validates nixpkgs.hostPlatform but accepts anything else.";
            type = lib.types.submodule {
              freeformType = lib.types.attrsOf lib.types.deferredModule;

              options.nixpkgs.hostPlatform = lib.mkOption {
                type = lib.types.either lib.types.str lib.types.attrs;
                description = "The target platform system string or attribute set.";
                example = "x86_64-linux";
              };
            };

            config.nixpkgs.pkgs = lib.mkForce (
              import inputs.nixpkgs (
                {
                  system = config.nixpkgs.hostPlatform;
                }
                // (removeAttrs config.nixpkgs [
                  "hostPlatform"
                  "pkgs"
                ])
              )
            );
          };
        };
    };
}
