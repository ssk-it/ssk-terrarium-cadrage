---
id: 04-regulation
titre: Par quel algorithme réguler ?
statut: retenue
option_retenue: hysteresis
---

## Description

Le chauffage et la brumisation sont des sorties tout-ou-rien, sur un bac de 215 L isolé, dont la température évolue lentement.

## Options

### pid

Un régulateur proportionnel-intégral-dérivé, avec modulation de la sortie.

**Pour** — suit une consigne de près sur un système rapide.
**Contre** — trois réglages à trouver et à tenir ; une modulation que des relais tout-ou-rien rendent mal ; rien à gagner sur une inertie aussi forte.

### hysteresis

**Retenue.** Marche sous la consigne moins l'hystérésis, arrêt au-dessus de la consigne plus l'hystérésis ; un seuil et des impulsions pour la brumisation.

**Pour** — simple à comprendre, à tester et à prouver ; un seul réglage ; le relais ne bat pas.
**Contre** — une oscillation de l'ordre de l'hystérésis autour de la consigne, acceptable ici (±0,5 °C, O1).

## Décision

Hystérésis. Ce qui a tranché : l'inertie forte d'un bac de 215 L isolé, sur laquelle un PID n'apporte rien.
