{ pkgs, config, lib, ... }:
{
# ── Enable flatpak service ────────────────────────────────────────────────────────────
  services.flatpak = {
        enable = true;
        remotes = [
          {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          }
        ];

        packages = [
          { appId = "org.vinegarhq.Sober"; origin = "flathub"; }
        ];

        # Mise à jour auto via nix-flatpak
        update.auto = {
          enable = true;
          onCalendar = "daily";
        };
      };
    }
