---
id: 03-brumisation-sur-la-mesure-retenue
titre: Sur quelle humidité la pompe brumise-t-elle quand le DHT11 décide ?
statut: retenue
option_retenue: brumise-sur-la-mesure-retenue
---

## Description

La brumisation (phase 4) déclenchera la pompe sous un seuil d'humidité de l'air, 75 % HR par défaut. Quand la mesure de l'air vient du DHT11, son humidité n'est garantie que jusqu'à 90 % HR, à ±5 %. Or le bac vit entre 75 et 90 % HR : c'est la raison même de ADR-capteur-air-sht45.

## Options

### pompe-coupee-sans-sht45

Le secours du DHT11 ne vaut que pour le chauffage. Quand la SHT45 n'est pas retenue, la pompe reste coupée, comme sous un défaut capteur aujourd'hui.

**Pour** — une humidité imprécise ne peut ni noyer le bac ni le laisser sécher. Le bac garde quelques heures d'inertie d'humidité.
**Contre** — une panne prolongée de la SHT45 assèche le bac, alors qu'une mesure, même grossière, existe.

### brumise-sur-la-mesure-retenue

**Retenue.** La pompe suit l'humidité de la mesure de l'air, quelle que soit la sonde qui la donne, et toujours dans la durée maximale d'une impulsion (RG-impulsion-de-brumisation-bornee).

**Pour** — le bac reste humidifié pendant une panne de la SHT45. Chauffage et pompe suivent la même mesure, ce qui se lit d'un seul coup d'œil dans `state`.
**Contre** — avec ±5 % HR, le DHT11 peut lire 70 % un bac à 80 % et brumiser de trop, ou l'inverse. Au-delà de 90 % HR, sa mesure n'est plus garantie.

## Décision

`brumise-sur-la-mesure-retenue`, choisie par le propriétaire le 2026-11-10, contre la recommandation `pompe-coupee-sans-sht45`. Ce qui a tranché : ne pas laisser le bac sécher pendant une panne. Le risque de sur- ou de sous-brumisation est accepté. La durée maximale d'une impulsion, qui n'est pas un réglage (INV-5 du firmware), le borne.
