---
id: 03-seuil-bas-de-temperature
titre: Quel seuil bas de température déclenche une alerte, quand le mode fait varier ce que le bac doit tenir ?
statut: retenue
option_retenue: selon-le-mode
---

## Description

F9 fixe une alerte sous 15 °C. Mais `HIBERNATION` tient le bac entre 4 et 6 °C, `PLAGES` le laisse entre 12 et 14 °C hors plage, et le garage est à 10-12 °C l'hiver (RG-sorties-par-mode, RG-chauffage-par-plages). Un seuil fixe sonnerait tout l'hiver ; un seuil trop bas ne verrait pas un `ACTIF` qui ne chauffe plus.

## Options

### f9-tel-quel

15 et 24 °C dans tous les modes.

**Pour** — l'exigence F9 telle qu'écrite, un seul seuil à comprendre.
**Contre** — une alerte basse permanente en hibernation et chaque nuit en `PLAGES` : on finit par couper l'alerte, et on ne voit plus la vraie.

### haute-et-gel

24 °C, et 3 °C, quel que soit le mode.

**Pour** — simple, jamais de bruit.
**Contre** — un `ACTIF` dont le chauffage a lâché, à 13 °C, ne sonne pas.

### selon-le-mode

**Retenue.** Le seuil haut vaut 24 °C dans tous les modes. Le seuil bas suit ce que le mode doit tenir :

- 15 °C en `ACTIF` et en plage ;
- 11 °C hors plage, un degré sous le plancher de 12 °C ;
- 3 °C en `HIBERNATION` et en `MAINTENANCE`, un degré sous le hors-gel.

La condition doit durer 10 minutes.

**Pour** — l'alerte ne part que si le bac sort de ce que son mode promet.
**Contre** — le mode doit être historisé ; trois seuils bas à comprendre et à régler.

## Décision

`selon-le-mode`, choisi par le propriétaire le 11 novembre 2026, avec un délai de 10 minutes. Ce délai écarte une mesure isolée ou une porte ouverte, et laisse le temps d'agir avant une surchauffe. Ce qui a tranché : une alerte qui sonne pour un état voulu finit coupée, et ne protège plus de rien.
