# Evaluated migration comparison
Compared with the pre-migration working tree, not Git HEAD.

## systemPackages
Removed:

Added:
- `/nix/store/bsfb6sqx9kfyk56m9zvx439v942zwb1c-syncthing-2.1.3`

## homePackages
Removed:
- `/nix/store/80i96bk9ppjrg0g52f0g2agvfxjrs6ny-nixvim`
- `/nix/store/bsfb6sqx9kfyk56m9zvx439v942zwb1c-syncthing-2.1.3`
- `/nix/store/i3v606z51wm70lzjndsbca8g06jb047s-mako-1.11.0`

Added:
- `/nix/store/0al7231lp59jsib2bl71qwwn4yyjw8gr-nixvim`
- `/nix/store/98ch8yhf2f2cwnqdhdazz0rin0pgn23s-delta-0.19.2`
- `/nix/store/milb4mx5vjbm65y9gfzrjcxfmsjyi8sl-sops-3.13.3`

## systemServices
Removed:

Added:
- `syncthing`
- `syncthing-init`

## userServices
Removed:
- `syncthing`
- `syncthing-init`

Added:

Filesystems, state versions, kernel, driver, device IDs and existing folder settings match. NixOS adds a null ignorePatterns schema default only.

Intentional differences: Delta/SOPS availability and corrected Git configuration; one SwayNC notification service instead of Mako; Syncthing moves from home/user to system ownership; shared editor file sources and snippets move under assets; Nix registry/input changes alter the system environment. No unrelated package-version refresh was requested.
