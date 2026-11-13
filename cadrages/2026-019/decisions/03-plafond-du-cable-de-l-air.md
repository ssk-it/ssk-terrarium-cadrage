---
id: 03-plafond-du-cable-de-l-air
titre: Le substrat borne-t-il aussi le câble de l'air ?
statut: retenue
option_retenue: plafond-fixe-a-28
---

## Description

Hors de la coupure, le câble de l'air chauffe pendant que le substrat est déjà à son seuil. Une part de sa chaleur descend vers le terreau. Il n'y a pas de limiteur matériel (2026-001, décision `06-protection-contre-la-surchauffe`, sskorupski/ssk-terrarium#9) : la sonde du substrat reste la seule borne de sa température.

L'air, lui, borne le câble par l'hystérésis : il s'arrête à la consigne plus l'hystérésis. Mais une sonde d'air décrochée dans un coin froid, mesure plausible et fausse, le ferait chauffer sans fin, sous la seule pause de RG-chauffe-continue-bornee.

## Options

### aucun-plafond

Le câble de l'air ne dépend que de l'air.

**Pour** — la règle la plus simple.
**Contre** — avec une sonde d'air trompée, rien ne borne la température du substrat que ce câble réchauffe.

### plafond-fixe-a-28

**Retenue.** Le câble de l'air est coupé dès qu'une mesure valide du substrat atteint 28 °C, et reprend sous 26 °C. Ce plafond est fixé à la compilation, et ne s'applique que lorsque la coupure par le substrat est active.

**Pour** — 28 °C est déjà la borne haute du seuil de coupure (RG-reglages-bornes) : c'est la température que le propriétaire a refusé de laisser atteindre au substrat, et l'écart de 2 °C est celui qu'il impose entre coupure et reprise. Le plafond ne joue jamais en marche normale : le câble du substrat est coupé bien avant.
**Contre** — une règle de plus, sans réglage, et qui ne se publie que par ses effets.

### coupure-reglee-pour-les-deux

Appliquer aux deux câbles les seuils réglés de la coupure.

**Pour** — un seul jeu de seuils.
**Contre** — c'est la coupure commune que la décision `02-pilotage-des-deux-cables` écarte : l'air redevient sans chauffe à chaque coupure.

## Décision

`plafond-fixe-a-28`. Ce qui a tranché : sans limiteur matériel, un câble que le substrat ne borne pas du tout serait le seul élément chauffant sans borne de température. Le plafond reprend une valeur que le propriétaire a déjà choisie, et ne gêne jamais la chauffe de l'air en marche normale. Il suit l'activation de la coupure : quand le propriétaire s'en passe, il s'en passe pour les deux câbles.
