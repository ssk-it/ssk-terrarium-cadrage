---
id: 06-zone-d-approche
titre: Le chauffage coupe-t-il net au seuil du substrat, ou ralentit-il avant ?
statut: retenue
option_retenue: approche-reglable
---

## Description

Les relevés des 24 heures précédant le 13 novembre 2026 montrent ce que coûte une coupure franche. L'air n'atteint pas sa consigne de 18 °C ; le chauffage tourne donc sans arrêt et pousse le substrat jusqu'à 24 °C vers 16 h. Par inertie, celui-ci monte encore à 24,4 °C, puis met environ 10 h 30 à redescendre sous 18,5 °C, soit moins de 0,6 °C par heure. Pendant ce temps, le garage se refroidit (la sonde extérieure passe de 14 à 12 °C vers 21 h 30) et l'air du bac tombe à 13,5 °C. Le propriétaire demande de lisser les pics du substrat sans laisser l'air chuter.

Une reprise plus haute (décision `02-seuils-reglables`) raccourcit la coupure, mais garde le pic et le dépassement par inertie : le substrat touche toujours son seuil.

## Options

### coupure-franche

Le chauffage suit l'air jusqu'au seuil de coupure, puis s'arrête jusqu'à la reprise : ce que fait 2026-005.

**Pour** — une seule règle, un seul état à lire.
**Contre** — le substrat dépasse son seuil par inertie, et l'air reste des heures sans chauffe.

### anticipation-par-la-pente

Couper avant le seuil quand la pente du substrat annonce qu'il va l'atteindre.

**Pour** — vise directement le dépassement.
**Contre** — une pente se calcule sur des mesures au dixième de degré, bruitées, toutes les 30 s ; elle se trompe au moindre courant d'air, et ne dit rien de l'air.

### approche-reglable

**Retenue.** Une zone d'approche, de largeur réglable, sous le seuil de coupure. Quand le substrat y entre et que l'air demande de la chauffe, le chauffage ne tourne qu'une part de chaque tranche de 10 minutes : 100 % à l'entrée de la zone, et de moins en moins jusqu'à 0 % au seuil de coupure. Une largeur de 0 garde la coupure franche.

**Pour** — le substrat se stabilise sous son seuil au lieu de le franchir puis de redescendre de 5,5 °C ; l'air reçoit une chauffe réduite mais continue ; le relais ne commute qu'aux tranches, au plus deux fois en 10 minutes.
**Contre** — une règle de plus, et une part de chauffe à publier pour que l'historique explique un chauffage qui ne tourne qu'à moitié.

## Décision

`approche-reglable`, demandée par le propriétaire le 13 novembre 2026. Ce qui a tranché : c'est la seule option qui agit avant le pic, sans reposer sur une pente bruitée. La largeur vaut 0 par défaut, pour que rien ne change sans réglage (objectif S3). Les relevés suggèrent d'essayer 2 °C, avec une reprise à 22 °C.
