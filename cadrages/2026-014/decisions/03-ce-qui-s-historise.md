---
id: 03-ce-qui-s-historise
titre: Quelles valeurs de l'état l'historique garde-t-il ?
statut: retenue
option_retenue: avec-chaque-sonde
---

## Description

`etat.star` garde 14 valeurs numériques de l'état, mais pas la mesure de chaque sonde d'air (`sondes.<nom>`, 2026-007) : seule celle qui est retenue pour réguler l'est. Or c'est sonde par sonde qu'un décrochage se voit, et la sonde extérieure mesure le garage, qu'aucune autre série ne garde. 2026-009 ajoute de son côté ce que les alertes demandent : le mode, `mise_en_securite.air`, `sondes.<nom>.defaut` et le réglage des alertes.

## Options

### l-etat-tel-quel

Garder les 14 valeurs actuelles.

**Pour** — rien à changer.
**Contre** — la mesure d'une sonde ne se lit que quand elle est retenue. Une sonde extérieure ou de relais n'a pas de courbe, et la température du garage se perd.

### tout-l-etat

Historiser aussi les chaînes : version, plages, fuseau, et les bornes.

**Pour** — tout se retrouve.
**Contre** — une chaîne n'est pas une série. Il faudrait une étiquette par valeur, qui ferait naître une série nouvelle à chaque changement. Les bornes sont des constantes du firmware, et se lisent dans l'état retenu.

### avec-chaque-sonde

**Retenue.** Les 14 valeurs, plus la température et l'humidité de chaque sonde, dans deux séries étiquetées par le nom de la sonde, `terrarium_sonde_temperature{id, sonde}` et `terrarium_sonde_humidite{id, sonde}`. Le rôle n'est pas une étiquette.

**Pour** — chaque sonde a sa courbe, celle du garage comprise. Une sonde nouvelle y entre sans changer l'historique. Changer le rôle d'une sonde ne coupe pas sa courbe en deux.
**Contre** — quatre séries de plus pour deux sondes. Le rôle passé d'une sonde ne se lit pas dans l'historique : l'application montre le rôle en place.

## Décision

`avec-chaque-sonde`. Ce qui a tranché : la question qu'on pose à un historique de sondes, « laquelle décroche, et quand ? », ne se lit que sonde par sonde.
