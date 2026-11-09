---
id: 03-sonde-muette
titre: Que devient la coupure quand la sonde du substrat se tait ?
statut: retenue
option_retenue: air-reprend-apres-2-min
---

## Description

La sonde est optionnelle (RG-mesures-periodiques). Si elle se tait ou rend des mesures invalides pendant une coupure, rien ne dit plus si le substrat est redescendu.

## Options

### air-reprend-apres-2-min

**Retenue.** La coupure tient tant que la sonde se tait moins de 2 minutes, puis se lève ; l'air décide seul jusqu'au retour d'une mesure valide.

**Pour** — même tolérance que le capteur d'air (RG-capteur-en-defaut) : une erreur passagère ne lève rien ; une sonde débranchée ne bloque pas le chauffage, hors-gel compris.
**Contre** — une sonde qui se tait pendant que le substrat est chaud laisse l'air rechauffer un substrat qu'on ne voit plus.

### reste-coupe

Le chauffage reste coupé jusqu'à une mesure valide sous 18,5 °C.

**Pour** — on ne chauffe pas un substrat qu'on a vu chaud.
**Contre** — une sonde débranchée ou morte coupe le chauffage pour toujours, hors-gel compris : l'élevage peut geler pour une sonde optionnelle.

## Décision

`air-reprend-apres-2-min`, choisie par le propriétaire le 2026-11-09. Ce qui a tranché : une sonde optionnelle ne doit pas pouvoir empêcher le hors-gel.
