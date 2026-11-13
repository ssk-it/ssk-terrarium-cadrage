---
id: 04-validation-du-nouveau-firmware
titre: Quand un nouveau firmware est-il assez sûr pour qu'on ne revienne plus à l'ancien ?
statut: retenue
option_retenue: regulation-et-courtier
---

## Description

Le bootloader revient à l'image précédente si la nouvelle redémarre avant d'avoir été déclarée valide. Arduino la déclare valide dès le démarrage, si bien qu'un firmware qui ne plante pas, mais qui ne régule pas, ou qui ne sait plus joindre le courtier, resterait en place. Il faut choisir ce qu'un nouveau firmware doit avoir prouvé, et en combien de temps.

## Options

### au-demarrage

Le comportement d'Arduino : valide dès que `setup()` est atteint.

**Pour** — rien à écrire.
**Contre** — seul un plantage très précoce est défait. Un firmware qui lit mal ses sondes, ou qui ne se reconnecte plus, reste en place, et ne se corrige alors qu'au câble.

### regulation-seule

Valide une fois la boucle lancée et une mesure de l'air retenue.

**Pour** — ne dépend pas du réseau, comme la régulation (RG-regulation-sans-reseau).
**Contre** — un firmware qui régule mais ne rejoint plus le courtier ne peut plus recevoir de correctif à distance. C'est précisément ce que l'OTA devait éviter.

### regulation-et-courtier

**Retenue.** Valide une fois une mesure de l'air retenue **et** le courtier rejoint, dans les 5 minutes qui suivent le démarrage. Sinon, le firmware redémarre et le bootloader revient à l'ancien.

**Pour** — un firmware validé est à la fois capable de réguler et de recevoir la mise à jour suivante. 5 minutes couvrent la reconnexion Wi-Fi (backoff de RG-regulation-sans-reseau) et le délai du courtier, sans laisser longtemps un firmware douteux aux commandes.
**Contre** — une panne de Wi-Fi qui coïncide avec la mise à jour la fait défaire. C'est sans danger : on revient au firmware qui marchait, et l'on refait la mise à jour plus tard.

## Décision

`regulation-et-courtier`. Le critère qui a tranché : un firmware qu'on ne peut plus joindre ne se corrige qu'en ouvrant le boîtier, ce que l'OTA existe pour éviter. Défaire à tort coûte une mise à jour à refaire, alors que garder à tort coûte un passage au garage.
