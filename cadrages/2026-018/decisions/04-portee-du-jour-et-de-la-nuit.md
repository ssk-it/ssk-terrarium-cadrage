---
id: 04-portee-du-jour-et-de-la-nuit
titre: Dans quels modes les seuils de nuit s'appliquent-ils ?
statut: retenue
option_retenue: tous-les-modes
---

## Description

Les seuils se règlent pour le jour et pour la nuit. 2026-016, en cours, limite la consigne de nuit au mode `ACTIF` (sa décision `01-portee-du-jour-et-de-la-nuit`). La coupure, elle, vaut dans tous les modes qui chauffent (2026-005, décision `06-modes`).

## Options

### actif-seul

Comme la consigne de nuit : les seuils de nuit en `ACTIF`, ceux du jour ailleurs.

**Pour** — le même modèle que 2026-016.
**Contre** — en `PLAGES`, une plage de nuit chaufferait sous les seuils de jour : la nuit réglée ne vaudrait pas la nuit.

### tous-les-modes

**Retenue.** Les seuils du moment, selon RG-jour-et-nuit, en `ACTIF`, `PLAGES` et `HIBERNATION` ; ceux du jour tant que l'heure n'est pas connue.

**Pour** — la coupure garde sa règle sans exception ; ce que le propriétaire règle pour la nuit vaut la nuit.
**Contre** — un écart de modèle avec la consigne de nuit, à expliquer dans l'application.

## Décision

`tous-les-modes`, choisie par le propriétaire le 13 novembre 2026. Ce qui a tranché : la coupure protège le substrat, quel que soit le mode qui chauffe. La consigne dit quoi viser, la coupure quoi ne pas dépasser : leurs portées n'ont pas à être les mêmes.
