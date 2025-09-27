{
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
  nix-update-script,
}:
let
  short_hash = "47a2106";
  package_hash = "sha256-r7nqPsFXLhTg0gctNc8dYLv5L02J3YWw6AOfqHTsXIw=";
  latest_version = "1.51.1";
in
buildGoModule rec {
  pname = "deck";
  version = "${latest_version}";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "${package_hash}";
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  flags = [
    "-trimpath"
  ];

  doCheck = false;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "sha256-5JSMw73Vo59OMpkQcakYodd9HySmPPaJIi3x85npd6Y=";

  proxyVendor = true;

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = {
    description = "A configuration management and drift detection tool for Kong";
    homepage = "https://github.com/Kong/deck";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ liyangau ];
  };
}
