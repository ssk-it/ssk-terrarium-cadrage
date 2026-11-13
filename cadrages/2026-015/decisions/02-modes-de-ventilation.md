---
id: 02-modes-de-ventilation
titre: Comment rendre la ventilation moins mécanique ?
statut: retenue
option_retenue: metronome-ou-rubato
---

## Description

Le métronome de 2026-013 répète la même aération au même intervalle. Le propriétaire veut un air qui bouge de façon moins régulière, sans perdre ce que les réglages garantissent : un renouvellement moyen, et un ventilateur qui ne tourne ni sans arrêt ni jamais.

## Options

### alea-fixe

Un écart au hasard de ±30 %, constante du firmware.

**Pour** — un réglage de moins.
**Contre** — le propriétaire ne peut ni l'atténuer ni l'accentuer.

### metronome-ou-rubato

**Retenue.** Deux modes : `metronome`, celui de 2026-013, et `rubato`, où chaque aération tire sa durée et l'intervalle jusqu'à la suivante dans ±`ecart` autour des réglages, `ecart` de 10 à 50 %, puis ramenés dans les bornes. Le nom vient de la musique : jouer librement autour du tempo sans le perdre.

**Pour** — le même renouvellement moyen, jamais au même rythme ; un écart réglable ; le métronome reste.
**Contre** — un hasard à tester : le cœur le reçoit en paramètre, pour que les tests en fixent la suite.

### vitesse-variable

Une brise douce plutôt que tout ou rien, en commandant la vitesse du ventilateur.

**Pour** — le plus proche d'un air qui bouge.
**Contre** — un autre ventilateur ou un transistor : du matériel. Gardée comme piste.

## Décision

`metronome-ou-rubato`, nom et écart réglable choisis par le propriétaire. Ce qui a tranché : l'irrégularité s'obtient sans matériel nouveau, et sans rien céder des bornes.
