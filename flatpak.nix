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
        # Put your flatpak here or you just use terminal to install them
        packages = [
          "org.vinegarhq.Sober"
        ];
      };

  # ── Flatpak auto-update ──────────────────────────────────────────────────
  systemd.services.flatpak-update = {
        description = "Update Flatpak apps";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.flatpak}/bin/flatpak update --noninteractive";
        };
      };

      systemd.timers.flatpak-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
  }
