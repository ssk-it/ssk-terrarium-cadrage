---
id: 04-humidite
titre: Quand alerter d'une humidité hors de 60-95 % ?
statut: retenue
option_retenue: tous-les-modes-30-minutes
---

## Description

F9 fixe 60-95 % HR. La brumisation n'existe pas encore (phase 2), et quand elle viendra, chaque brumisation dépassera 95 % un moment. L'hibernation se veut au sec, sous 60 %.

## Options

### actif-et-plages

Hors 60-95 % pendant plus de 30 minutes, en `ACTIF` et `PLAGES` seulement.

**Pour** — pas d'alerte attendue en hibernation.
**Contre** — ne voit pas une hibernation trop humide.

### tous-les-modes-30-minutes

**Retenue.** Hors 60-95 % pendant plus de 30 minutes, dans tous les modes.

**Pour** — une seule règle ; le délai écarte la pointe d'une brumisation ; une hibernation trop humide se voit.
**Contre** — une hibernation au sec, sous 60 %, sonne, sauf à couper l'alerte ou à baisser son seuil (RG-reglage-des-alertes).

### pas-d-alerte

Reporter l'humidité au cadrage de la brumisation.

**Pour** — rien à régler avant que l'humidité ne soit pilotée.
**Contre** — une SHT45 qui dérive, ou un bac qui sèche, passe inaperçu jusque-là.

## Décision

`tous-les-modes-30-minutes`, choisi par le propriétaire le 11 novembre 2026. Ce qui a tranché : le seuil et l'activation se règlent depuis l'application, ce qui ôte à cette option son seul défaut.
