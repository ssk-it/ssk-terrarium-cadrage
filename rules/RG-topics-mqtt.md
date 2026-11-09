---
id: RG-topics-mqtt
fonctionnalites: [mqtt, modes, reglages]
statut: actif
cree_par: 2026-002
modifie_par: [2026-003]
---

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, temps depuis le démarrage, version du firmware |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ) |

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode à la reconnexion suivante.
