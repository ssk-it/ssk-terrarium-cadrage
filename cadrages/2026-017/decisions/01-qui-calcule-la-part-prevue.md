---
id: 01-qui-calcule-la-part-prevue
titre: Qui calcule la part du temps d'aération que prévoit le rythme ?
statut: retenue
option_retenue: la-supervision
---

## Description

La part prévue se tire de réglages que l'état publie déjà : le mode, le moment de la journée, la durée et la période du rythme, la durée d'hibernation. Mais aucune valeur de l'état ne la donne telle quelle, et le mode est une chaîne, que l'historique ne garde pas. Il faut que quelqu'un fasse le calcul, et qu'il soit vrai état par état, pas seulement avec les réglages d'aujourd'hui.

## Options

### l-application

L'application tire la part prévue des réglages en place, et la trace sur la période.

**Pour** — rien à changer à la supervision ni au contrat.
**Contre** — fausse dès qu'un réglage a changé dans la période, ou à chaque passage du jour à la nuit si on la trace à plat. Elle recopierait dans l'application une règle du régulateur, ce que RG-historique-lu-dans-les-resumes du référentiel de sterrarium exclut. Écartée aussi par la décision 03 de sterrarium-cadrage 2026-013.

### le-firmware

Le régulateur publie dans son état la part qu'il prévoit d'aérer ; l'historique la garde comme les autres valeurs numériques.

**Pour** — le régulateur reste seul juge de son rythme ; si sa façon d'aérer change, la valeur suit sans rien toucher ailleurs.
**Contre** — une version du firmware, à déployer sur chaque régulateur, et un champ de plus dans un état déjà proche de sa taille, pour un usage qui n'est que d'affichage.

### la-supervision

**Retenue.** `etat.star` calcule la part prévue à chaque état reçu, d'après RG-ventilation-periodique, et l'écrit comme une série de plus.

**Pour** — aucune version du firmware ; la valeur suit les réglages et le moment de la journée, état par état ; l'application la lit comme toute autre série du résumé.
**Contre** — la supervision recopie une règle du régulateur : un nouveau mode ou un nouveau rythme doit s'y reporter. RG-historique-des-mesures le dit, pour que le prochain changement de RG-ventilation-periodique le trouve.

## Décision

`la-supervision`. Ce qui a tranché : seule une valeur calculée état par état reste vraie quand un réglage ou le moment change dans la période, et la supervision peut la tirer de ce que l'état publie déjà, sans attendre une version du firmware. Le jour où l'état publiera sa part prévue, l'historique la lira au lieu de la calculer, sans rien changer au résumé.
