{
  lib,
  pkgs,
  ...
}: {
  programs.ssh.enable = true;

  programs.ssh.extraConfig = ''
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    IdentitiesOnly no
  '';

  # Generate ssh agent config for 1Password
  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "DarioBook SSH Key"
    vault = "Private"
  '';
}
