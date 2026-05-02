{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";

      #default user
      myUserName = "user17";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; 
      };
    in
    {
      nixosConfigurations.my-pc = nixpkgs.lib.nixosSystem {
        inherit system;
        
        specialArgs = { inherit inputs myUserName; };

        modules = [
          ./configuration.nix 

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { 
              inherit inputs myUserName; 
              unstable = pkgs-unstable; 
            };
            
            home-manager.users.${myUserName} = import ./home.nix;
          }
        ];
      };
    };
}
