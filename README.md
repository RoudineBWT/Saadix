# NixOS — AMD A10 Pro + GTX 630 / Cinnamon

Configuration NixOS avec Flakes, nix-flatpak et l'environnement de bureau Cinnamon.

---

## Structure

```
nixos-config/
├── flake.nix                 # Point d'entrée Nix Flakes
├── configuration.nix         # Config système principale
├── hardware-configuration.nix  # ⚠️ À RÉGÉNÉRER sur la machine
└── README.md
```

---

## Installation pas à pas

### 1. Booter l'ISO NixOS

Télécharge l'ISO sur https://nixos.org/download (version "GNOME" ou "minimal").
Grave-la sur une clé USB avec Ventoy ou `dd`.

### 2. Partitionner et monter

```bash
# Exemple avec un seul disque /dev/sda (GPT + EFI)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 512MB 100%

mkfs.fat  -F 32 /dev/sda1
mkfs.ext4       /dev/sda2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

> Si la machine utilise du BIOS legacy (pas d'EFI), adapte le `configuration.nix`
> en remplaçant `systemd-boot` par GRUB (commentaires inclus dans le fichier).

### 3. Générer le hardware-configuration

```bash
nixos-generate-config --root /mnt
```

Cela crée `/mnt/etc/nixos/hardware-configuration.nix`.
**Copie ce fichier** à la place du `hardware-configuration.nix` fourni ici.

### 4. Copier la configuration sur la machine

```bash
# Depuis un autre PC (via réseau ou clé USB)
cp -r nixos-config/* /mnt/etc/nixos/
```

### 5. Éditer les valeurs personnelles

Dans `configuration.nix`, change :

| Ligne | Ce qu'il faut changer |
|-------|-----------------------|
| `networking.hostName` | Nom de la machine |
| `time.timeZone` | Fuseau horaire |
| `users.users.ton-frere` | Nom d'utilisateur réel |
| `initialPassword` | Mot de passe provisoire |

### 6. Installer

```bash
nixos-install --flake /mnt/etc/nixos#nixos
```

Puis redémarre :

```bash
reboot
```

---

## Après l'installation

### Changer le mot de passe

```bash
passwd
```

### Mettre à jour le système

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

### Mettre à jour les inputs du flake

```bash
sudo nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

---

## Notes sur le matériel

### AMD A10 Pro (iGPU Radeon)
- Driver `radeon` (open source, inclus dans le kernel)
- `amdgpu.dc=0` désactivé dans les paramètres kernel pour éviter les freezes
  sur les vieux APU Richland/Kaveri

### NVIDIA GT 630 (Fermi GF108 — c816)
- Le GT 630 référence c816 est un chip **GF108, architecture Fermi** (≠ Kepler)
- Seul le driver propriétaire **nvidia 390.xx legacy** le supporte sous Linux
- Le driver 470 ne fonctionne **pas** sur Fermi malgré ce que le site NVIDIA peut suggérer
- `nouveau` est fonctionnel pour l'affichage 2D mais des kernel panics GF108 sont documentés — le 390.xx est plus fiable
- La config utilise `hardware.nvidia.package = nvidiaPackages.legacy_390`

### zram swap
- Activé par défaut — compresse la RAM avec zstd
- Particulièrement utile si la machine a ≤ 8 Go de RAM

---

## Ajouter des applications Flatpak

Dans `configuration.nix`, section `services.flatpak.packages` :

```nix
{ appId = "org.kde.kdenlive";     origin = "flathub"; }
{ appId = "net.lutris.Lutris";    origin = "flathub"; }
{ appId = "com.valvesoftware.Steam"; origin = "flathub"; }
```

Puis :

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```
