---
id: 02-seuil-fixe
titre: Le seuil de coupure du substrat suit-il la consigne ?
statut: retenue
option_retenue: fixe-24
---

## Description

La demande dit « la consigne plus 5 °C, soit 24 °C ». La consigne se règle de 15 à 22 °C (RG-reglages-bornes) : un seuil qui la suit irait de 20 à 27 °C.

## Options

### consigne-plus-5

**Pour** — l'écart entre l'air visé et le substrat toléré reste le même quelle que soit la consigne.
**Contre** — à la consigne maximale, le substrat monte jusqu'à 27 °C ; le seuil devient un réglage par ricochet.

### fixe-24

**Retenue.** 24 °C quelle que soit la consigne, constante du firmware.

**Pour** — aucune commande ne peut le déplacer, même par la consigne ; rien à borner.
**Contre** — changer le seuil demande de recompiler.

## Décision

`fixe-24`, choisie par le propriétaire le 2026-11-09. Ce qui a tranché : un seuil qui ne dépend d'aucun réglage, sur le modèle du plancher de `PLAGES` (décision `02-plancher-hors-plage` de 2026-003). Le seuil de reprise, 18,5 °C, est fixe pour le même motif.
