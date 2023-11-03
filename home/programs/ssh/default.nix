{
  config,
  pkgs,
  ...
}: {
  programs.ssh.enable = true;

  programs.ssh.extraConfig = ''
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';
}
