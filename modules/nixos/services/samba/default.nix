{
  lib,
  inputs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.samba;
in {
  # This module requires to run the following command
  #   sudo smbpasswd -a <user>
  # on first usage to setup the samba user and password
  options.dariodots.services.samba = with types; {
    enable = mkBoolOpt false "Whether or not to enable samba.";
  };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          security = "user";
          "workgroup" = "WORKGROUP";
          "server smb encrypt" = "required";
        };
        storage = {
          path = "/home/storage";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0777";
          "directory mask" = "0777";
          "valid users" = "dario,@admin,@samba";
          "writeable" = "yes";
        };
      };
    };
  };
}
