---
id: 01-ou-dire-la-cause
titre: Où l'application de supervision lit-elle la cause d'un rejet ?
statut: retenue
option_retenue: champ-dans-state
---

## Description

Le régulateur sait pourquoi il rejette une mesure ; l'application de supervision ne le voit pas. Il faut un endroit où la cause se lise à distance, y compris par une application qui s'ouvre longtemps après le début du défaut.

## Options

### deduite-par-l-application

L'application lit les valeurs publiées et les compare aux plages de plausibilité qu'elle recopie du firmware.

**Pour** — aucun changement de firmware, livrable le jour même.
**Contre** — les plages vivent en double, et divergeront au premier changement du firmware ; c'est le défaut que sterrarium-cadrage 2026-001 (décision 03) et 2026-004 ont écarté pour les bornes des réglages. Elle suppose aussi que la valeur refusée soit publiée, ce que RG-topics-mqtt interdit : corriger cet écart la rendrait aveugle. Elle ne distingue pas un capteur muet d'une valeur hors plage.

### evenement-au-passage-en-defaut

Le régulateur publie sur `event` la cause, au moment où le capteur passe en défaut.

**Pour** — rien ne change dans `state`.
**Contre** — `event` n'est pas retenu : une application ouverte après le passage en défaut ne voit jamais la cause, alors que c'est le cas courant d'un défaut survenu la nuit.

### champ-dans-state

**Retenue.** Un champ `cause_mesure_air` dans `state`, `null` ou la cause.

**Pour** — retenu comme le reste de l'état : toute application le lit à l'abonnement, dans le même message que le défaut qu'il explique. Les plages restent au seul firmware.
**Contre** — une modification de RG-topics-mqtt, à coordonner avec 2026-005 qui la modifie aussi ; et un firmware à reflasher.

## Décision

`champ-dans-state`. Ce qui a tranché : la cause doit se lire par une application qui n'était pas ouverte au moment du défaut, ce que seul un message retenu garantit.
