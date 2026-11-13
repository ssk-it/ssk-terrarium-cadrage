---
id: 02-precision-de-la-part-prevue
titre: À quelle précision publier la part prévue ?
statut: retenue
option_retenue: millieme
---

## Description

Appris en réalisant (ssk-it/ssk-it-infra#55) : le résumé arrondit les mesures au centième, et les parts des sorties au millième. La part prévue est une mesure par sa forme — moyenne, minimum, maximum, nombre —, mais elle se compare à la part du ventilateur.

## Options

### centieme

L'arrondi des mesures.

**Pour** — une seule règle d'arrondi pour tout ce qui a la forme d'une mesure.
**Contre** — 2 minutes par heure valent 0,03 quand la part du ventilateur vaut 0,033 : l'application lirait un écart de 0,3 point qui n'existe pas, et le prendrait pour une aération de saturation.

### millieme

**Retenue.** L'arrondi des parts des sorties.

**Pour** — la part prévue et celle du ventilateur ont la même précision : un écart nul se lit nul.
**Contre** — une exception à l'arrondi des mesures, que l'énoncé doit dire.

## Décision

`millieme`. Ce qui a tranché : la valeur n'existe que pour être comparée à la part du ventilateur ; elle prend donc sa précision.
