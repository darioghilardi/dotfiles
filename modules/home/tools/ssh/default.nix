{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.tools.ssh;
  user = config.dariodots.user;
in {
  options.dariodots.tools.ssh = with types; {
    enable = mkBoolOpt false "Whether or not to enable ssh.";
    use1Password = mkBoolOpt false "Configure the 1password agent.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh.enable = true;
    }

    (mkIf cfg.use1Password {
      # The IdentityAgent config works only for the ssh command, not for
      # ssh-copy-id or ssh-add
      programs.ssh.extraConfig = ''
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        IdentitiesOnly no
      '';

      # Symlink agent.sock to a human path (and without spaces)
      home.file.".1Password/agent.sock" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };

      # Required to find the 1password identities when using commands
      # like ssh-copy-id or ssh-add
      programs.fish.interactiveShellInit = ''
        set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
      '';

      # Generate ssh agent config for 1Password
      home.file.".config/1Password/ssh/agent.toml".text = ''
        [[ssh-keys]]
        item = "DarioBook SSH Key"
        vault = "Private"
      '';
    })
  ]);
}
