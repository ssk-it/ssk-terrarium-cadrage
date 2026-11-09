---
id: 05-signalement
titre: Comment la coupure se signale-t-elle ?
statut: retenue
option_retenue: serie-et-mqtt
---

## Description

Une coupure peut durer longtemps, l'air sous la consigne : sans signal, elle se lirait comme une panne de chauffage.

## Options

### serie-et-mqtt

**Retenue.** Une ligne sur la liaison série à l'entrée et à la sortie, comme la pause de 2 h, et un champ `coupure_substrat` dans `state`.

**Pour** — se voit sur place et à distance, sans attendre une alerte.
**Contre** — change le contrat de `state` (RG-topics-mqtt).

### serie-seule

**Pour** — MQTT inchangé.
**Contre** — à distance, l'air sous la consigne sans chauffe ne s'explique pas.

## Décision

`serie-et-mqtt`, choisie par le propriétaire le 2026-11-09. Ce qui a tranché : pouvoir expliquer à distance un chauffage coupé. La coupure n'est pas un défaut : elle n'allume pas la LED d'état.
