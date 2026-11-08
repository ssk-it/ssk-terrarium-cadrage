---
id: 04-reglages-a-distance
titre: Que peut-on changer à distance, et dans quelles bornes ?
statut: retenue
option_retenue: mode-et-consigne-bornes
---

## Description

Le propriétaire veut forcer le mode et modifier les seuils à distance. En phase 1, aucun limiteur matériel ne coupe le chauffage au-delà de 24 °C : la consigne est la seule chose qui décide de la température haute. Une consigne reçue du réseau doit donc être bornée par le firmware, et les protections ne doivent dépendre d'aucun réglage.

## Options

### reporter

Publication seule ; mode et réglages restent sur la liaison série.

**Pour** — aucun risque nouveau.
**Contre** — l'objectif W3 tombe ; changer de mode oblige à rouvrir le boîtier.

### mode-seulement

`cmd/mode` seul.

**Pour** — le mode ne fait que choisir entre des comportements déjà bornés.
**Contre** — la consigne reste figée à 19 °C.

### mode-et-consigne-bornes

**Retenue.** `cmd/mode` et `cmd/config` pour la consigne et l'hystérésis du chauffage, bornées à la compilation : consigne 15-22 °C, hystérésis 0,2-2 °C, consigne plus hystérésis sous 24 °C ; refus entier hors bornes.

**Pour** — W3 tenu ; aucune valeur reçue ne peut porter l'arrêt du chauffage au-delà du seuil d'alerte haute.
**Contre** — validation, persistance et revalidation au démarrage à écrire et à tester.

### reglages-libres

Tous les seuils de la piste #13, sans autre borne que leur type.

**Pour** — tout réglable d'un coup.
**Contre** — sans limiteur, une erreur de saisie chauffe le bac au-delà de 24 °C.

## Décision

Le mode et la consigne bornée, dans un second temps du chantier, après la publication. Ce qui a tranché : les bornes de la consigne, fixées à la compilation, remplacent en partie un limiteur qui manque en phase 1.
