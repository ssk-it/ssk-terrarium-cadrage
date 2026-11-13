---
id: 03-authenticite-de-l-image
titre: Qu'est-ce qui garantit que l'image installée vient du propriétaire ?
statut: retenue
option_retenue: signature-minisign-verifiee-par-le-firmware
---

## Description

Le firmware est la seule protection du bac en phase 1. Une image installée à distance remplace les bornes, les coupures et le chien de garde. Plusieurs comptes peuvent commander : le propriétaire, et l'application, dont le mot de passe est partagé par tous ses appareils (sterrarium-cadrage 2026-002). Il faut qu'aucun d'eux, ni aucune compromission de la source, ne puisse faire installer autre chose qu'une image voulue par le propriétaire.

## Options

### tls-seul

L'image est téléchargée depuis un hôte authentifié par TLS, et cela suffit.

**Pour** — rien à écrire de plus.
**Contre** — l'authenticité repose alors sur tout ce qui peut écrire dans la source : Skaron, son bucket, ses clés d'API, la CI. Une seule fuite suffit à installer un firmware sans bornes.

### secure-boot-v2

Le secure boot d'ESP-IDF : le bootloader vérifie une signature RSA à chaque démarrage.

**Pour** — vérification par la ROM, la plus forte qui soit.
**Contre** — il faut brûler les eFuses : c'est irréversible, et une erreur rend la carte inutilisable. Il faut aussi un bootloader compilé avec cette option, ce que le framework Arduino précompilé ne permet pas sans quitter ADR-firmware-platformio-arduino. Le premier passage se ferait de toute façon au câble.

### signature-minisign-verifiee-par-le-firmware

**Retenue.** Le propriétaire signe `firmware.bin` avec minisign sur son poste. La clé publique est compilée dans le firmware. Le firmware calcule l'empreinte BLAKE2b-512 au fil de l'écriture, puis vérifie la signature Ed25519 avec libsodium, avant de rendre la partition démarrable.

**Pour** — c'est le format de signature que Skaron transporte déjà pour Tauri : rien n'est à inventer côté distribution. La vérification se fait au fil de l'eau, sans tenir l'image en mémoire. Aucun eFuse n'est touché, et tout reste réversible au câble.
**Contre** — une clé privée de plus à garder, sur le poste du propriétaire. Une image installée au câble n'est pas vérifiée, ce qui va de soi, puisque le câble exige d'être sur place.

## Décision

`signature-minisign-verifiee-par-le-firmware`. Le critère qui a tranché : c'est la seule option qui rende la clé du propriétaire nécessaire et suffisante, sans toucher à des eFuses irréversibles.
