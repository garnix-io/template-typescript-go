{ pkgs, lib, self, ... }:

# TODO: Change these variables to whatever works for you
let # This lets you log in via SSH
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzsYv/IpqFuE29NVBQrslVqvdeEdPVfQqSg1pVyTh40j2Z3UK8uK6fCSLGyQZNsqyO5B8785tqLL9MoVJMfqVPhSUiRZqXvjMFXuxCTqV5YndXc8qFNfjgPxVGWUrZQsGpFQKj8LAbSXjxdBKFZvuU9/vo9GlxBUhcKdDLax4r/OqGOBSIRb5Cgwt2i85Yi1uB5hivdTL28Csx19IlmlAxJyRRltxOetC2eD9jF3qRQQciz/CjXUSGNKcyI2PhnCpeoH9v7j2+UrTsyN0JVGfMJoOvYW97QE3vYvefK1VGWnU8BrS3ybW4c4snHDr5OzaBNfNkmw765bM89HRiTL+HBbkGx1f739UCdcZnYiUzZBKoJRw4J4XqlIyuApCRrRUOG8PBPcClh1kldMxeJxpmGmIIdvOh++kIffOkOfCnEZUVlmqwLxeeYMZTPJ13yL9bQis1vR2dqeNud25eyK1FbaMTt5GE08Zcg/j39YBLxz/0hK4uE3bQbOA+eCEgypU= shahn@lissabon";
  backendPort = "3000";
in
{
  # This sets up networking and filesystems in a way that works with garnix
  # hosting.
  garnix.server.enable = true;

  # This is so we can log in.
  #   - First we enable SSH
  services.openssh.enable = true;
  #   - Then we create a user called "me". You can change it if you like; just
  #     remember to use that user when ssh'ing into the machine.
  users.users.me = {
    # This lets NixOS know this is a "real" user rather than a system user,
    # giving you for example a home directory.
    isNormalUser = true;
    description = "me";
    extraGroups = [ "wheel" "systemd-journal" ];
    openssh.authorizedKeys.keys = [ sshKey ];
  };
  # This allows you to use `sudo` without a password when ssh'ed into the machine.
  security.sudo.wheelNeedsPassword = false;

  # This specifies what packages are available in your system. You can choose
  # from over 100,000 - search for them here:
  #   https://search.nixos.org/options?channel=24.05
  environment.systemPackages = [
    pkgs.htop
    pkgs.tree
  ];

  # Setting up a systemd unit running the go backend.
  systemd.services.backend = {
    description = "example go backend";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Environment = "PORT=" + backendPort;
      Type = "simple";
      DynamicUser = true;
      ExecStart = lib.getExe self.packages.${pkgs.system}.backend;
    };
  };

  # Configuring `nginx` to do two things:
  #
  # 1. Serve the frontend bundle on /.
  # 2. Proxy to the backend on /api.
  services.nginx =
    {
      # This switches on nginx.
      enable = true;
      # Enabling some good defaults.
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      virtualHosts."default" = {
        # Serving the frontend bundle by default.
        locations."/".root = "${self.packages.${pkgs.system}.frontend-bundle}";
        # Proxying to the backend on /api.
        locations."/api".proxyPass = "http://localhost:${backendPort}/";
      };
    };

  # We open just the http default port in the firewall. SSL termination happens
  # automatically on garnix's side.
  networking.firewall.allowedTCPPorts = [ 80 ];

  # This is currently the only allowed value.
  nixpkgs.hostPlatform = "x86_64-linux";
}
