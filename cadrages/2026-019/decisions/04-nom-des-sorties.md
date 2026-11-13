---
id: 04-nom-des-sorties
titre: Comment l'état nomme-t-il les deux sorties de chauffage ?
statut: retenue
option_retenue: chauffage-et-chauffage-air
---

## Description

L'état publie `sorties.chauffage`. L'historique en tire `terrarium_chauffage{id}` (RG-historique-des-mesures), les résumés `sorties.chauffage` (RG-resumes-de-l-historique), et l'application comme le tableau de bord les lisent. `sorties.eclairage` disparaît avec la lampe.

## Options

### chauffage-et-chauffage-air

**Retenue.** `sorties.chauffage` reste le câble du substrat, et `sorties.chauffage_air` s'ajoute pour le câble de l'air.

**Pour** — la série `terrarium_chauffage` continue sans rupture : le câble du substrat est celui qui chauffait jusqu'ici, seul. Un lecteur qui ne connaît pas encore `chauffage_air` lit toujours juste ce qu'il lisait.
**Contre** — le nom `chauffage` ne dit pas qu'il s'agit du câble du bas : il faut le savoir.

### deux-noms-neufs

`chauffage_substrat` et `chauffage_air`.

**Pour** — des noms symétriques, qui disent chacun leur câble.
**Contre** — la série `terrarium_chauffage` s'arrête, et une nouvelle commence : cinq ans de courbe coupés en deux, et chaque lecteur cassé jusqu'à sa mise à jour.

### chauffage-agrege

`chauffage` vaut « au moins un câble allumé », et un objet à part détaille les deux câbles.

**Pour** — `chauffage` garde un sens global.
**Contre** — l'historique changerait de sens sans changer de nom : un 1 d'avant ne vaudrait plus un 1 d'après.

## Décision

`chauffage-et-chauffage-air`. Ce qui a tranché : la continuité de l'historique. Le câble du substrat fait exactement ce que faisait l'unique câble, et garde son nom.
