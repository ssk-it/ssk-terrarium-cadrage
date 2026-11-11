---
id: 02-bornes-de-la-ventilation
titre: Dans quelles bornes la durée et la période de la ventilation se règlent-elles ?
statut: retenue
option_retenue: bornes-larges
---

## Description

La décision `04-reglages-a-distance` de 2026-002 veut que tout réglage à distance soit borné à la compilation. Restait à fixer les bornes de la durée et de la période. Trop étroites, elles empêchent d'éprouver ce que F10 laisse « à valider » ; trop larges, elles laissent un ventilateur qui ne s'arrête presque jamais dessécher le bac.

## Options

### bornes-etroites

Durée de 1 à 15 minutes, période de 30 à 180 minutes, et durée au plus la moitié de la période : le ventilateur ne tourne jamais plus d'un temps sur deux.

**Pour** — une erreur de saisie ne peut pas faire tourner le ventilateur plus de la moitié du temps.
**Contre** — moins de latitude pour éprouver, et une contrainte de rapport de plus à vérifier, à publier et à expliquer dans l'application.

### bornes-larges

**Retenue.** Durée de 1 à 30 minutes, période de 15 à 240 minutes, en minutes entières, et la durée strictement sous la période — la contrainte que le firmware vérifie déjà sur ses constantes (`static_assert`).

**Pour** — de quoi essayer une aération longue et rare comme une aération courte et fréquente. Une seule contrainte entre les deux valeurs.
**Contre** — 14 minutes toutes les 15 restent admises : le ventilateur peut tourner presque sans arrêt.

## Décision

`bornes-larges`, au choix du propriétaire. Ce qui a tranché : un ventilateur 5 V ne met pas l'élevage en danger immédiat comme le chauffage peut le faire ; un réglage trop généreux se voit dans `state` et dans le bac, et se corrige à distance. Les bornes gardent ce qu'il faut d'absolu : le ventilateur s'arrête à chaque période, et tourne au moins une minute par période.
