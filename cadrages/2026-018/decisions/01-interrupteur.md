---
id: 01-interrupteur
titre: La coupure par le substrat peut-elle se désactiver ?
statut: retenue
option_retenue: desactivable-visible-enregistree
---

## Description

2026-005 (décision `06-modes`) voulait une règle sans exception, et 2026-002 (décision `04-reglages-a-distance`) qu'aucune protection ne dépende d'un réglage : sans limiteur matériel, une commande ne devait pas pouvoir lever la coupure. Le propriétaire demande un interrupteur en tête de la carte du chauffage. Il fallait dire si on le donne, et comment il reste sûr.

## Options

### pas-d-interrupteur

La coupure reste toujours active ; seuls ses seuils se règlent.

**Pour** — la protection ne se lève jamais par commande, comme le voulait 2026-002.
**Contre** — pour changer le substrat, éprouver une sonde ou chauffer volontairement un substrat froid, il faut porter la coupure à sa borne haute : un détour qui revient à la désactiver sans le dire.

### desactivable-libre

Un booléen comme un autre, sans autre trace que sa valeur dans l'état.

**Pour** — le plus simple.
**Contre** — une coupure désactivée par erreur, ou par un compte compromis, ne se voit qu'en lisant l'état au bon moment.

### desactivable-visible-enregistree

**Retenue.** Un booléen, actif par défaut, enregistré ; sa désactivation se publie dans l'état (`seuils_substrat` à `null`), s'annonce sur `event` et sur la liaison série, et s'historise. Un réglage illisible au démarrage la remet active.

**Pour** — le propriétaire a son interrupteur ; une désactivation se lit après coup dans l'historique, et en direct dans les événements.
**Contre** — rien n'empêche une désactivation de durer : seule sa visibilité protège.

### desactivable-jusqu-au-redemarrage

Comme la précédente, mais la désactivation n'est pas enregistrée : un redémarrage la remet active.

**Pour** — une désactivation oubliée ne survit pas à une coupure de courant.
**Contre** — l'application afficherait l'interrupteur coupé puis rallumé sans que personne n'y ait touché ; un changement de substrat de plusieurs jours serait interrompu par le moindre redémarrage.

## Décision

`desactivable-visible-enregistree`, choisie par le propriétaire le 13 novembre 2026 en retenant « rouvrir avec garde-fous ». Ce qui a tranché : un réglage qui se comporte comme les autres, et dont la désactivation ne peut pas passer inaperçue. Elle rouvre `06-modes` de 2026-005 et `04-reglages-a-distance` de 2026-002, dont le motif — l'absence de limiteur — reste vrai : c'est pourquoi la désactivation est rendue visible plutôt que libre.
