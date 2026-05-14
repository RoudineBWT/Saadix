{ config, pkgs, lib, inputs, ... }:

{
  # ── Bootloader ──────────────────────────────────────────────────────────────
   boot.loader.grub.enable  = true;
   boot.loader.grub.device  = "/dev/sda";  # adapte selon ton disque

  # ── Kernel & paramètres bas niveau ──────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_6_6;   # LTS stable, bon support AMD APU old-gen

  # Paramètres utiles sur vieille machine
  boot.kernelParams = [
    "quiet"
    "splash"
    "amdgpu.dc=0"       # désactive Display Core sur vieux APU AMD (évite freeze au boot)
    "radeon.dpm=1"      # active la gestion dynamique d'alimentation pour la puce AMD
  ];

  # ── Réseau ──────────────────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ── Localisation ────────────────────────────────────────────────────────────
  time.timeZone               = "Europe/Paris";    # Change si besoin
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

  # ── GPU : iGPU AMD (APU A10 Pro) + NVIDIA GT 630 (Fermi GF108) ──────────────
  # Le GT 630 (c816 / GF108) est une architecture FERMI — pas Kepler !
  # Seul le driver propriétaire nvidia legacy 390.xx le supporte correctement.
  # Le driver 470 ne fonctionne PAS sur Fermi (erreur fréquente).
  # "nouveau" fonctionne pour l'affichage de base mais peut être instable (kernel panics connus sur GF108).

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package                = config.boot.kernelPackages.nvidiaPackages.legacy_390;
    modesetting.enable     = false;  # le 390 ne supporte pas bien le KMS
    powerManagement.enable = false;
    open                   = false;  # pas de driver open pour Fermi
    nvidiaSettings         = false;
  };

  # Active le rendu matériel Mesa pour l'APU AMD (radeontop/vdpau)
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  # ── Serveur d'affichage X11 + Cinnamon ──────────────────────────────────────
  services.xserver = {
    enable = true;

    # Disposition clavier française sous X
    xkb.layout  = "fr";
    xkb.variant = "";
  };

  # Gestionnaire de connexion LightDM (natif à Cinnamon)
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick.enable = true;   # greeter par défaut de Linux Mint / Cinnamon
  };

  # Environnement de bureau Cinnamon
  services.xserver.desktopManager.cinnamon.enable = true;

  # ── Son (PipeWire) ───────────────────────────────────────────────────────────
  security.rtkit.enable  = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;   # compatibilité PulseAudio
  };

  # ── Impression (optionnel) ───────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Bluetooth (optionnel) ────────────────────────────────────────────────────
  # hardware.bluetooth.enable = true;

  # ── Flatpak (géré par nix-flatpak) ──────────────────────────────────────────
  services.flatpak = {
    enable = true;

    # Dépôts Flatpak
    remotes = [
      {
        name     = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Applications à installer de façon déclarative
    # Ajoute ou retire selon les besoins de ton frère
    packages = [
      { appId = "org.vinegarhq.Sober";          origin = "flathub"; }
    ];

    # Met à jour les Flatpaks à chaque rebuild (optionnel)
    update.auto = {
      enable     = true;
      onCalendar = "weekly";
    };
  };

  # ── Utilisateur ──────────────────────────────────────────────────────────────
  users.users.saad = {         # ← Change le nom d'utilisateur ici
    isNormalUser   = true;
    description    = "saad";
    extraGroups    = [ "networkmanager" "wheel" "audio" "video" ];
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
    nvtopPackages.nvidia    # moniteur GPU (nvidia 390)
    mesa-demos               # glxinfo, glxgears pour tester l'accélération

    # Cinnamon / bureau
    nemo                     # gestionnaire de fichiers
    gnome-screenshot
    xed-editor               # éditeur de texte Cinnamon
    celluloid                # lecteur vidéo léger (MPV frontend)

    # Navigateur
    brave-orgin-beta

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
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };

  # Autorise les paquets non-libres (utile pour codecs, drivers, etc.)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  # ── Performances sur vieille machine ─────────────────────────────────────────
  # Swappiness basse : privilégie la RAM avant le swap
  boot.kernel.sysctl."vm.swappiness" = 10;

  # Zram swap (compression RAM) — utile si RAM < 8 Go
  zramSwap = {
    enable    = true;
    algorithm = "zstd";
  };

  # ── Firewall ─────────────────────────────────────────────────────────────────
  networking.firewall.enable = true;

  # ── Version système ───────────────────────────────────────────────────────────
  # NE PAS CHANGER après la première installation
  system.stateVersion = "25.11";
}
