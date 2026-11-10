---
id: 02-combinaison-des-sondes
titre: Quand deux sondes intérieures sont acceptées, laquelle décide ?
statut: retenue
option_retenue: combinaison-reglable
---

## Description

Deux sondes intérieures valides donnent deux mesures. Le chauffage n'a qu'une sortie. La décision `01-combinaison-air-substrat` de 2026-005 a écarté « deux déclencheurs pour une seule sortie », parce que ce que fait le chauffage ne se lit plus alors sur une seule mesure. Il fallait dire comment les deux mesures deviennent une seule décision.

## Options

### priorite-fixe-sht45

La SHT45 décide quand elle est acceptée. Le DHT11 ne prend le relais que lorsqu'elle est rejetée.

**Pour** — la régulation porte toujours sur la sonde la plus précise quand elle fonctionne. Le DHT11 n'apporte sa marge d'erreur qu'en secours.
**Contre** — le propriétaire ne peut pas donner la main au DHT11 tant que la SHT45 fonctionne.

### moyenne-fixe

La régulation porte toujours sur la moyenne des sondes acceptées.

**Pour** — une erreur modérée de l'une est atténuée par l'autre.
**Contre** — l'imprécision du DHT11, ±2 °C et ±5 % HR, entre en permanence dans la décision, même quand la SHT45 fonctionne.

### plus-froide-fixe

La sonde acceptée la plus froide décide.

**Pour** — le froid est le risque premier de l'élevage, dans un garage à 10-12 °C l'hiver.
**Contre** — une sonde qui lit trop bas fait chauffer jusqu'à la coupure par le substrat ou la pause de chauffe continue, sans limiteur matériel en phase 1.

### combinaison-reglable

**Retenue.** La combinaison se règle parmi `priorite-sht45`, `priorite-dht11`, `moyenne` et `plus-froide`. Par défaut, c'est `priorite-sht45`.

**Pour** — le propriétaire adapte la combinaison à ce qu'il sait de ses sondes. Quelle que soit la combinaison, le régulateur calcule une seule mesure de l'air, publiée dans `state` avec la sonde qui la donne (`sonde_retenue`) : la décision se lit toujours sur une seule mesure, ce qui répond au motif de 2026-005.
**Contre** — un réglage de plus, et deux combinaisons, `moyenne` et `plus-froide`, qui laissent une sonde fausse mais plausible peser sur la décision (RG-capteur-en-defaut).

## Décision

`combinaison-reglable`, choisie par le propriétaire le 2026-11-10. On lui avait présenté trois options fixes, `priorite-fixe-sht45` en tête. Ce qui a tranché : laisser le choix à celui qui connaît l'état de ses sondes. Il faut aussi que la décision reste lisible sur une seule mesure publiée. Pour cela, la combinaison produit une mesure de l'air, jamais deux déclencheurs. La valeur par défaut, `priorite-sht45`, reprend l'option recommandée : sans réglage, le DHT11 n'est qu'un secours.
