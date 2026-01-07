{ pkgs, ... }: {
  packages = [
    pkgs.git
    pkgs.curl
  ];

  services.postgres = {
    enable = true;
    initialDatabases = [
      { name = "myapp"; }
    ];
  };

  git-hooks.hooks = {
    prettier.enable = true;
    nixpkgs-fmt.enable = true;
    black.enable = true;
    ruff.enable = true;
    mypy.enable = false;
  };
}
