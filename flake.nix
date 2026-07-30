{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		
		noctalia = {
			url = "github:noctalia-dev/noctalia";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		zen-browser = {
			url = "github:youwen5/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
		nixosConfigurations.nixos-test = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [ 
				./configuration.nix
				home-manager.nixosModules.default
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.maxfh = ./home.nix;
					};
				}
 			];
		};
	};
}
