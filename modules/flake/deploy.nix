# deploy-rs configuration for the NixOS hosts, reproducing the root flake's
# `deploy = lib.mkDeploy { … }`. Reuses the repo's mkDeploy helper (copied to
# ../../lib/deploy). Only one module sets `flake.deploy`, so no mergeable option
# declaration is needed. Overrides for hosts not yet migrated are ignored
# (mkDeploy only iterates self.nixosConfigurations).
{ inputs, ... }:
let
  mkDeploy =
    (import ../../lib/deploy {
      lib = inputs.nixpkgs.lib;
      inherit inputs;
      namespace = "my";
    }).mkDeploy;
in
{
  flake.deploy = mkDeploy {
    self = inputs.self;
    overrides = {
      saturn = {
        remoteBuild = true;
        interactiveSudo = false;
        sshUser = "root";
        sshOpts = [
          "-p"
          "2222"
        ];
        profiles.system.user = "root";
      };
      osaka = {
        remoteBuild = true;
        interactiveSudo = false;
        sshUser = "root";
        profiles.system.user = "root";
      };
    };
  };
}
