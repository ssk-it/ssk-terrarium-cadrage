---
id: 03-reglages-du-jour-et-de-la-nuit
titre: Quels réglages de ventilation le jour et la nuit, et quand changent-ils ?
statut: retenue
option_retenue: deux-blocs-fixes-au-debut
---

## Description

Le jour et la nuit ont chacun leur ventilation. Il fallait dire ce qui se dédouble, ce que devient l'hibernation, et ce qui se passe au passage de l'un à l'autre, ou quand un réglage change pendant une aération.

## Options

### deux-blocs-appliques-aussitot

`jour` et `nuit` portent chacun mode, durée, période et écart ; au passage, ou à un nouveau réglage, le décompte suit aussitôt les nouvelles valeurs.

**Pour** — un changement se voit immédiatement.
**Contre** — en `rubato`, une aération déjà tirée au hasard se retirerait au milieu ; en métronome, passer d'une période à une autre fait sauter la phase, avec une aération qui tombe ou disparaît au moment du passage.

### deux-blocs-fixes-au-debut

**Retenue.** `jour` et `nuit` portent chacun mode, durée, période et écart. La durée d'une aération et l'intervalle jusqu'à la suivante se fixent à son début, avec les réglages du moment à cet instant. `hibernation` garde son aération quotidienne, avec sa propre heure et sa propre durée, sans jour ni nuit.

**Pour** — une seule règle pour les deux modes et pour le passage du jour à la nuit ; rien ne se coupe au milieu.
**Contre** — un changement attend l'aération suivante : jusqu'à 4 heures avec la période la plus longue. Un changement de mode relance aussitôt le décompte.

## Décision

`deux-blocs-fixes-au-debut`. Ce qui a tranché : une aération commencée va à son terme, quel que soit ce qui change pendant. 2026-013 appliquait un nouveau réglage aussitôt ; c'est abandonné, au profit d'une règle unique.
