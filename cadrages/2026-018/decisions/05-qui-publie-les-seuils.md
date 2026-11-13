---
id: 05-qui-publie-les-seuils
titre: Qui dit quels seuils s'appliquent à l'instant ?
statut: retenue
option_retenue: le-firmware
---

## Description

L'historique doit garder les seuils qui s'appliquaient, pour que l'application les trace sans rien recalculer (RG-historique-lu-dans-les-resumes, référentiel de sterrarium). Ils se tirent des réglages, du moment de la journée et de l'activation. 2026-017 a fait calculer la consigne de ventilation par la supervision (décision `01-qui-calcule-la-part-prevue`), pour ne pas toucher au firmware.

## Options

### la-supervision

`etat.star` lit `securite_substrat` et `moment`, et en tire les seuils du moment.

**Pour** — aucun champ de plus dans l'état.
**Contre** — la supervision recopierait une règle du régulateur, et se tromperait au premier changement de la façon dont il juge le moment.

### le-firmware

**Retenue.** L'état publie `seuils_substrat`, les seuils que le régulateur applique, ou `null` quand la coupure est désactivée ; l'historique le garde comme les autres valeurs.

**Pour** — le régulateur reste seul juge ; ce cadrage change déjà le firmware, et la version qu'invoquait 2026-017 contre cette option est due de toute façon.
**Contre** — un champ de plus dans un état proche de sa taille.

## Décision

`le-firmware`. Ce qui a tranché : le firmware change de toute façon pour ce cadrage, et 2026-017 lui-même prévoyait que l'historique lise une valeur publiée plutôt que de la calculer dès que l'état la donnerait.
