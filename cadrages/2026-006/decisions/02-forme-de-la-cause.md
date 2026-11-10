---
id: 02-forme-de-la-cause
titre: Remplacer le booléen defaut_capteur, ou publier la cause à côté ?
statut: retenue
option_retenue: champ-a-cote
---

## Description

`defaut_capteur` est un booléen que l'application sterrarium lit déjà. La cause pourrait le remplacer (`null` ou la cause) ou s'y ajouter. Il faut aussi décider si la cause se publie dès le premier rejet, ou seulement une fois le défaut déclaré.

## Options

### remplacer-le-booleen

`defaut_capteur` devient `null` ou une chaîne de cause.

**Pour** — un seul champ, aucune combinaison incohérente possible.
**Contre** — l'application en place lit un booléen : un firmware reflashé la ferait mal lire jusqu'à sa mise à jour. Il confond aussi deux faits distincts, le rejet de la dernière mesure et le dépassement du délai de 2 minutes qui coupe les sorties.

### champ-a-cote

**Retenue.** `defaut_capteur` reste le booléen qu'il était ; `cause_mesure_air` dit, dès la première mesure rejetée, pourquoi elle l'est.

**Pour** — l'application en place continue de lire le défaut ; la cause s'annonce pendant les 2 minutes de tolérance, avant que rien ne soit coupé, ce qui laisse le temps d'intervenir.
**Contre** — deux champs à lire ensemble.

## Décision

`champ-a-cote`. Ce qui a tranché : ne pas casser l'application déjà déployée, et dire la cause avant que les sorties ne soient coupées.
