---
id: 06-ce-qui-se-regle
titre: Que peut-on régler d'une alerte depuis sterrarium ?
statut: retenue
option_retenue: activation-seuils-et-delais
---

## Description

Une fois le réglage logé dans le régulateur, reste à dire ce qu'il porte : l'activation seule, ou aussi les seuils et les délais. Chaque réglage de plus est une borne à valider dans le firmware et une saisie à rendre accessible dans l'application.

## Options

### activation-seule

Chaque alerte s'active ou se coupe ; seuils et délais restent ceux du cadrage.

**Pour** — un réglage booléen par alerte, rien à borner.
**Contre** — un seuil mal choisi ne se corrige qu'en reflashant la carte.

### activation-seuils-et-delais

**Retenue.** En plus de l'activation, les seuils de température et d'humidité et les délais se règlent, dans des bornes fixées par le firmware.

**Pour** — le propriétaire ajuste les alertes à son élevage et à sa saison sans rien reconstruire.
**Contre** — des bornes à valider, et un seuil bas toujours sous le seuil haut. vmalert fixe la durée d'une condition à l'écriture de chaque règle : les délais se choisissent dans une liste fermée, une règle par délai admis.

## Décision

`activation-seuils-et-delais`, choisi par le propriétaire le 11 novembre 2026. Ce qui a tranché : le réglage existe pour éviter les alertes qu'on finit par couper, et c'est d'abord le seuil qui les fait sonner à tort.
