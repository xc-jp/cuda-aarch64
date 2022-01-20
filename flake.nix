{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = inputs: {
    overlays = {
      cuda-aarch64 = final: prev:
        let
          cudnn-package = import ./cudnn.nix
            {
              version = "8.1.1";
              # 8.1.0 is compatible with CUDA 11.0, 11.1, and 11.2:
              # https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html#cudnn-cuda-hardware-versions
              srcName = "cudnn-11.2-linux-x64-v8.1.1.33.tgz";
              hash = "sha256-mKh4TpKGLyABjSDCgbMNSgzZUfk2lPZDPM9K6cUCumo=";
            };
        in
        {
          cudatoolkit-aarch64 = final.callPackage ./cudatoolkit.nix {
            url = "https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda_11.6.0_510.39.01_linux_sbsa.run";
            version = "11.6.0";
            sha256 = "1lnihm0257f4fgwyklaqc51g7r7mi481djw31190idsrbsgmg62q";
          };
          cudnn-aarch64 = final.callPackage cudnn-package {
            cudatoolkit = final.cudatoolkit-aarch64;
          };
        };
    };
    packages.x86_64-linux =
      let pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = "aarch64-linux";
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          inputs.self.overlays.cuda-aarch64
        ];
      };
      in
      {
        cudatoolkit = pkgs.cudatoolkit-aarch64;
        cudnn = pkgs.cudnn-aarch64;
      };
  };
}
