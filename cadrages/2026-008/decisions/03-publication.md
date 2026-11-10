---
id: 03-publication
titre: Comment la chauffe de la SHT45 se voit-elle ?
statut: retenue
option_retenue: event-par-chauffe
---

## Description

Une chauffe isolée ne dit rien. Des chauffes répétées disent que la sonde est trop près de l'eau, ou que le bac est trop humide. Le propriétaire doit pouvoir le lire depuis l'application, sans liaison série. La liaison série écrit chaque chauffe dans tous les cas.

## Options

### compteur-dans-state

`state` publie `sondes.sht45.chauffes`, le nombre de chauffes depuis le démarrage.

**Pour** — `event` n'est pas encombré, et l'application déduit la fréquence des chauffes de deux états successifs.
**Contre** — un compte depuis le démarrage repart à zéro à chaque redémarrage, et ne dit pas quand chaque chauffe a eu lieu.

### event-par-chauffe

**Retenue.** Chaque chauffe publie un message sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`.

**Pour** — chaque chauffe est horodatée par celui qui reçoit le message, et se lit dans l'historique des événements, à côté des changements de mode et des réglages. Le message de `state` ne change pas.
**Contre** — jusqu'à 12 messages par heure, dans un bac saturé, sur un sujet jusque-là réservé aux commandes, aux réglages et au démarrage.

### liaison-serie-seulement

Rien sur MQTT.

**Pour** — le contrat MQTT ne change pas.
**Contre** — l'application ne voit pas que la sonde chauffe, ni qu'elle chauffe sans effet.

## Décision

`event-par-chauffe`, choisie par le propriétaire le 2026-11-10, contre la recommandation `compteur-dans-state`. Ce qui a tranché : voir chaque chauffe à sa date, dans l'historique des événements. Les 12 messages par heure au plus, l'intervalle minimal de 5 minutes de la décision `01-declenchement` les borne.
