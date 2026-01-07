{ pkgs, ... }: {

  packages = [ pkgs.curl ];

  languages.python = {
    enable = true;
    version = "3.11.0";
    uv.enable = true;
    uv.sync.enable = true;
  };

  env = {
    LOKI_URL = "http://localhost:3100";
  };

  enterShell = ''
    echo "👋 Welcome to the aggregator!"
    echo "🚀 Starting logging system"
    docker compose -f ../../docker-compose.yml up -d
  '';
}
