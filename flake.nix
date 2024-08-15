{
  description = "garnix example server with a typescript frontend and a go backend";

  # Add your nix dependencies here.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    garnix-lib.url = "github:garnix-io/garnix-lib";
    flake-utils.url = "github:numtide/flake-utils";
    npmlock2nix-repo = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ]
      (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          # Here you can define packages that your flake outputs.
          packages = {
            # This imports `./frontend/default.nix` which defines a nix package
            # that builds the frontend bundle. This will be served as static
            # files by the server.
            frontend-bundle = pkgs.callPackage ./frontend { self = inputs.self; };
            backend = pkgs.callPackage ./backend { };
          };
          devShells.default = pkgs.mkShell
            {
              nativeBuildInputs = [ pkgs.go pkgs.gopls ];
            };
        })
    //
    {
      nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.garnix-lib.nixosModules.garnix
          {
            _module.args = { self = inputs.self; };
          }
          # This is where the server is defined.
          ./hosts/server.nix
        ];
      };
    };
}
