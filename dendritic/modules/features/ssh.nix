# ssh + 1Password agent. Unconditional (imported by the darwin hosts). The
# per-host bit — the 1Password SSH key item — is set by each host as
# `home.file.".config/1Password/ssh/agent.toml"` (see the host home files).
{...}: {
  flake.modules.homeManager."ssh" = {config, ...}: {
    programs.ssh.enable = true;
    programs.ssh.enableDefaultConfig = false;
    programs.ssh.matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "yes";
      compression = true;
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
    };

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
  };
}
