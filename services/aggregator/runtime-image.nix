{ pkgs ? import <nixpkgs> { }
, pkgsLinux ? import <nixpkgs> { system = "x86_64-linux"; }
}:

let
  vigos-aggregator = pkgs.stdenv.mkDerivation {
    # The name of the package
    name = "vigos-aggregator-1.0";
    system = "x86_64-linux";
    # Source files (you can specify the actual source location)
    src = ./.; # Point to the directory containing your Python files
    buildPhase = ''
      cd $src
      mkdir -p $out/build
      cp -r ./* $out/build
      cd $out/build
      export UV_PYTHON="${pkgs.python311}"
      uv sync --no-cache
      uv build
    '';
    dontUnpack = true;
    # Install phase: copying source files to the output directory
    installPhase = ''
      mkdir -p $out/bin
      cp $out/build/dist $out/bin
    '';

    # Specify any dependencies
    buildInputs = [ pkgs.python311 pkgs.uv ]; # Change to the Python version you want to use
  };


in
pkgs.dockerTools.buildImage {
  name = "vigos-aggregator";

  created = "now";
  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ pkgs.uv pkgs.bash pkgs.coreutils vigos-aggregator ];
    pathsToLink = [ "/bin" ];
  };


  # contents = [
  #   ./src/main.py
  #   ./uv.lock
  # ];

  # copyToRoot = pkgs.buildEnv {
  #   name = "image-root";
  #   paths = [./src]; # ./. not ./hello.sh
  # };

  # runAsRoot = ''
  #   uv sync
  # '';

  config = {
    Cmd = [ "uv run fastapi run src/main.py" ];
  };
}
