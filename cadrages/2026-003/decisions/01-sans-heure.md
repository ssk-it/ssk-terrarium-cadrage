---
id: 01-sans-heure
titre: Que fait le mode PLAGES tant que l'heure n'est pas connue ?
statut: retenue
option_retenue: comme-en-plage
---

## Description

Le régulateur n'a pas d'horloge RTC : l'heure se perd à chaque redémarrage, et ne revient qu'avec le NTP, donc avec le Wi-Fi et Internet. RG-regulation-sans-reseau veut que l'absence de réseau ne mette pas l'élevage en danger. Il faut dire ce que fait le chauffage du mode `PLAGES` entre le démarrage et la première synchronisation, qui peut ne jamais venir si la box est en panne.

## Options

### comme-hors-plage

Sans heure, seul le plancher hors plage s'applique : marche sous 12 °C, arrêt à 14 °C.

**Pour** — on ne chauffe jamais vers la consigne à une heure qui n'est peut-être pas dans une plage ; moins d'énergie.
**Contre** — une panne de box à la rentrée d'une coupure laisse l'élevage à 12-14 °C sans limite de durée : l'absence de réseau change le régime de chauffe, ce que RG-regulation-sans-reseau veut éviter.

### comme-en-plage

**Retenue.** Sans heure, le mode chauffe vers la consigne, comme `ACTIF`.

**Pour** — l'absence de réseau ne peut jamais abaisser le chauffage au plancher ; le comportement dégradé est celui, connu et éprouvé, d'`ACTIF`, dans les bornes de RG-reglages-bornes.
**Contre** — sans réseau, le bac est chauffé à la consigne en continu, au-delà des plages voulues.

### heure-estimee

Repartir de la dernière heure enregistrée en mémoire non volatile, comme la piste #8 le propose pour l'éclairage.

**Pour** — les plages continuent à peu près.
**Contre** — après une coupure de durée inconnue, l'heure estimée retarde d'autant : les plages tomberaient à des heures fausses, sans que rien ne le signale.

## Décision

`comme-en-plage`, choisie par le propriétaire le 2026-11-08. Ce qui a tranché : en cas de doute, chauffer à une consigne bornée vaut mieux que laisser l'air au plancher pour une durée inconnue.
