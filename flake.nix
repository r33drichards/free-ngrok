{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-generators = {
    url = "github:nix-community/nixos-generators";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-generators, ... }:
  {
    packages.reverse-proxy = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "amazon";
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            "${modulesPath}/virtualisation/amazon-image.nix"
          ];
        })
        ./configuration.nix
        ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
      ];
    };
  }
}
