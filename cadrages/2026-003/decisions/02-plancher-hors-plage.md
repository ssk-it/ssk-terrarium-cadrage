---
id: 02-plancher-hors-plage
titre: Quel seuil hors plage, et est-il réglable ?
statut: retenue
option_retenue: 12-14-fixe
---

## Description

La demande fixe un seuil de 12 °C hors plage. Le chauffage est en tout-ou-rien (`ADR-regulation-par-hysteresis`) : un seuil sec ferait battre le relais à chaque mesure. Il faut une bande, et dire si elle se règle.

## Options

### 12-14-fixe

**Retenue.** Marche sous 12 °C, arrêt à 14 °C, constantes du firmware.

**Pour** — même largeur que le hors-gel d'`HIBERNATION` (4-6 °C), relais peu sollicité ; pas un réglage, donc rien à borner.
**Contre** — changer le plancher demande de recompiler.

### 12-13-fixe

**Pour** — l'air reste plus près de 12 °C.
**Contre** — bande d'1 °C : le relais commute deux fois plus souvent.

### reglable-borne

Plancher réglable par la liaison série et MQTT, dans des bornes à définir.

**Pour** — souplesse.
**Contre** — un réglage de plus à borner et à revalider au démarrage, pour un besoin que personne n'a exprimé.

## Décision

`12-14-fixe`, choisie par le propriétaire le 2026-11-08. Ce qui a tranché : le modèle du hors-gel, déjà en place et sans réglage.
