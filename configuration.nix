{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./flatpak.nix
  ];
  # ── Bootloader ──────────────────────────────────────────────────────────────
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";  # adapte selon ton disque

  # ── Kernel & paramètres bas niveau ──────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_6_6;   # LTS stable, bon support AMD APU old-gen

  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # ── Réseau ──────────────────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ── Localisation ────────────────────────────────────────────────────────────
  time.timeZone               = "Europe/Paris";
  i18n.defaultLocale          = "fr_FR.UTF-8";
  console.keyMap              = "fr";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT    = "fr_FR.UTF-8";
    LC_MONETARY       = "fr_FR.UTF-8";
    LC_NAME           = "fr_FR.UTF-8";
    LC_NUMERIC        = "fr_FR.UTF-8";
    LC_PAPER          = "fr_FR.UTF-8";
    LC_TELEPHONE      = "fr_FR.UTF-8";
    LC_TIME           = "fr_FR.UTF-8";
  };

  # ── GPU : iGPU AMD (APU A10 Pro) ────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;   # nécessaire pour Minecraft (Java 32-bit libs)
  };

  # ── Serveur d'affichage X11 + Cinnamon ──────────────────────────────────────
  services.xserver = {
    enable = true;
    xkb.layout  = "fr";
    xkb.variant = "";
  };

  # Gestionnaire de connexion LightDM
  services.xserver.displayManager.lightdm.enable = true;

  # Environnement de bureau Cinnamon
  services.xserver.desktopManager.cinnamon.enable = true;
  services.dbus.enable = true;
  # ── Son (PipeWire) ───────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── Impression ───────────────────────────────────────────────────────────────
  services.printing.enable = false;

  # ── Utilisateur ──────────────────────────────────────────────────────────────
  users.users.saad = {
    isNormalUser = true;
    description  = "saad";
    extraGroups  = [ "networkmanager" "wheel" "audio" "video" "input" "tty" ];
  };

  # ── Packages système ─────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Outils de base
    git
    wget
    curl
    htop
    neofetch
    unzip
    p7zip

    # Outils GPU
    nvtopPackages.amd   # moniteur GPU AMD
    mesa-demos           # glxinfo, glxgears pour tester l'accélération

    # Cinnamon / bureau
    nemo
    gnome-screenshot
    xed-editor
    celluloid

    # Navigateur
    inputs.brave-previews.packages.${pkgs.system}.brave-origin-beta

    # Utilitaires réseau
    networkmanagerapplet

    # Minecraft
    inputs.freesmlauncher.packages.${pkgs.system}.default
  ];

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      trusted-users         = [ "root" "saad" ];
      substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://freesmlauncher.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };

  # Autorise les paquets non-libres (codecs, etc.)
  nixpkgs.config.allowUnfree = true;

  # ── Performances sur vieille machine ─────────────────────────────────────────
  boot.kernel.sysctl."vm.swappiness" = 10;

  zramSwap = {
    enable    = true;
    algorithm = "zstd";
  };

  # ── Firewall ─────────────────────────────────────────────────────────────────
  networking.firewall.enable = true;

  # ── Version système ───────────────────────────────────────────────────────────
  system.stateVersion = "25.11";
}
