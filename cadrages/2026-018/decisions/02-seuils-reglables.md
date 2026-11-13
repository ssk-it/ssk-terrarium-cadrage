---
id: 02-seuils-reglables
titre: Dans quelles bornes les seuils de coupure et de reprise se règlent-ils ?
statut: retenue
option_retenue: bornes-compilees-ecart-2
---

## Description

2026-005 avait fixé 24 °C et 18,5 °C à la compilation (décision `02-seuil-fixe`) : « un seuil qui ne dépend d'aucun réglage ». Elle avait aussi écarté une reprise proche de la coupure (décision `01-combinaison-air-substrat`, option `plafond-reprise-a-23-5`), parce que le substrat oscillerait autour du seuil. Rendre les seuils réglables rouvre les deux.

## Options

### libres

Deux nombres, sans autre borne que leur type.

**Pour** — rien à borner.
**Contre** — une faute de frappe (`42` pour `24`) supprime la protection ; une reprise à 23,9 °C refait l'oscillation écartée.

### bornes-compilees

Coupure de 20 à 28 °C, reprise de 15 à 26 °C, indépendamment.

**Pour** — aucune valeur ne porte le substrat au-delà de 28 °C.
**Contre** — une coupure à 22 et une reprise à 21,9 restent admises : l'oscillation revient.

### bornes-compilees-ecart-2

**Retenue.** Coupure de 20 à 28 °C ; reprise au moins 2 °C sous la coupure, et pas sous 15 °C ; au dixième de degré. Une commande qui laisserait une reprise trop proche est refusée en entier.

**Pour** — la borne haute protège le substrat, l'écart empêche l'oscillation, et les deux se publient dans `bornes` pour que l'application les montre.
**Contre** — le propriétaire ne peut pas retrouver l'écart de 0,5 °C de l'option écartée en 2026-005, même s'il le voulait.

## Décision

`bornes-compilees-ecart-2`. Ce qui a tranché : garder des deux décisions de 2026-005 ce qui les motivait — pas de substrat trop chaud, pas d'oscillation — en le faisant porter par des bornes plutôt que par une constante. Les valeurs, 28 °C et 2 °C, sont des propositions à confirmer (Questions ouvertes du cadrage).
