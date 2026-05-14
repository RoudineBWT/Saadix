# NixOS — AMD A10 Pro / Cinnamon

Configuration NixOS avec Flakes, nix-flatpak et l'environnement de bureau Cinnamon.

---

## Structure

```
nixos-config/
├── flake.nix                   # Point d'entrée Nix Flakes
├── configuration.nix           # Config système principale
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
# Exemple avec un seul disque /dev/sda (BIOS legacy / MBR)
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary ext4 1MB 100%

mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt
```

> Si la machine supporte l'EFI, adapte le partitionnement avec une partition ESP
> et remplace GRUB par `systemd-boot` dans `configuration.nix`.

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
| `users.users.saad` | Nom d'utilisateur réel |
| `boot.loader.grub.device` | Disque cible (ex: `/dev/sda`) |

### 6. Installer

```bash
nixos-install --flake /mnt/etc/nixos#saadix
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
sudo nixos-rebuild switch --flake /etc/nixos#saadix
```

### Mettre à jour les inputs du flake

```bash
sudo nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#saadix
```

---

## Notes sur le matériel

### AMD A10 Pro (iGPU Radeon)
- Driver `radeon` open source — inclus dans le kernel, dans le cache nixos (pas de compilation)
- `hardware.graphics.enable32Bit = true` activé pour la compatibilité Minecraft
- Suffisant pour Cinnamon + Minecraft

### zram swap
- Activé par défaut — compresse la RAM avec zstd
- Particulièrement utile si la machine a ≤ 8 Go de RAM

---

## Ajouter des applications Flatpak

Dans `configuration.nix`, section `services.flatpak.packages` :

```nix
{ appId = "org.kde.kdenlive";        origin = "flathub"; }
{ appId = "net.lutris.Lutris";       origin = "flathub"; }
{ appId = "com.valvesoftware.Steam"; origin = "flathub"; }
```

Puis :

```bash
sudo nixos-rebuild switch --flake /etc/nixos#saadix
```
