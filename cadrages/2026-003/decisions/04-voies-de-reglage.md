---
id: 04-voies-de-reglage
titre: Par où régler les plages et le fuseau ?
statut: retenue
option_retenue: serie-et-mqtt
---

## Description

Les plages et le fuseau doivent survivre à une coupure et se régler sans recompiler. 2026-002 règle la consigne par MQTT ; la liaison série porte déjà les commandes de mode.

## Options

### serie-et-mqtt

**Retenue.** Commandes série `PLAGES` et `FUSEAU`, champs `plages` et `fuseau` de `cmd/config` ; une seule validation, en mémoire non volatile.

**Pour** — on règle sans réseau, au pied du bac, comme à distance.
**Contre** — deux syntaxes à documenter.

### mqtt-seulement

**Pour** — une seule voie, comme la consigne.
**Contre** — impossible de régler les plages sans réseau, alors que le mode doit pouvoir fonctionner sans.

### serie-seulement

**Pour** — rien de plus exposé au réseau.
**Contre** — l'objectif W3 de 2026-002 (régler à distance) ne couvre plus le mode qu'on vient d'ajouter.

## Décision

`serie-et-mqtt`, choisie par le propriétaire le 2026-11-08. Ce qui a tranché : régler sans réseau.
