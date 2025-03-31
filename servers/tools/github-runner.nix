{
  config,
  ...
}:
let
  ghRunnerToken = config.sops.secrets."github-runner-token".path;
in
{
  services = {
    github-runners = {
      nixos = {
        enable = true;
        name = "nixos";
        tokenFile = "${ghRunnerToken}";
        url = "https://github.com/aufomm";
        user = "gh-runner";
        group = "gh-runner";
      };
    };
  };

  users.users.gh-runner = {
    isSystemUser = true;
    group = "gh-runner";
    description = "Github Runner service user";
  };

  users.groups.gh-runner = { };

  sops.secrets."github-runner-token" = {
    sopsFile = ./secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.gh-runner.name;
    group = config.users.users.gh-runner.group;
  };
}
