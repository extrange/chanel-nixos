# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, self, hostname, ... }:

{

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # TEMPORARY WORKAROUND
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # GPU
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_SG.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  # Core system
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  zramSwap.enable = true;
  
  # Virtualization
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # virtualisation.spiceUSBRedirection.enable = true;
  ## Install necessary packages
  environment.systemPackages = with pkgs; [
    virtiofsd
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    gnome.adwaita-icon-theme
  ];
  ## Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  ## Enable dconf (System Management Tool)
  programs.dconf.enable = true;
  services.spice-vdagentd.enable = true;

  # Increase sudo timeout
  security.sudo.extraConfig = "Defaults timestamp_timeout=30";

  # Network
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Printing
  services.printing.enable = true;

  # Display
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Display: enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "chanel";
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users = {
    users.chanel = {
      isNormalUser = true;
      description = "chanel";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    };
  };

  # Fix login keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Remove some gnome packages I don't use
  environment.gnome.excludePackages = with pkgs.gnome; [
    epiphany # browser, use firefox instead
    geary # mail reader
    gnome-shell-extensions # This seems to remove default gnome extensions I don't use
    pkgs.gnome-tour
    totem # video player, use vlc instead
  ];

  services = {

    tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # allow using exit node
    };

  };

  programs.ssh = {
    knownHosts = {
      # Add your SSH known_hosts here e.g.
      # "ssh.nicholaslyz.com,server,192.168.184".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV";
    };
  };

  # Optimization
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  # Autoupgrades
  system.autoUpgrade = {
    # Default frequency is daily
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?


}
