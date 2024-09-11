{
  config,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  disko.devices = {
    disk = {
      disk1 = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [];
                settings = {
                  allowDiscards = true;
                };
                passwordFile = "/tmp/disk.key";
                additionalKeyFiles = [];
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
    # zpool = {
    #   storage = {
    #     type = "zpool";
    #     rootFsOptions = {
    #       canmount = "off";
    #     };

    #     datasets = {
    #       root = {
    #         type = "zfs_fs";
    #         mountpoint = "/storage";
    #         options.mountpoint = "legacy";
    #       };
    #     };
    #   };
    # };
  };
}
