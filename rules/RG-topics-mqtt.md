---
id: RG-topics-mqtt
fonctionnalites: [mqtt, modes, reglages]
statut: actif
cree_par: 2026-002
modifie_par: [2026-003, 2026-004, 2026-005, 2026-006]
---

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides ou rejetées), cause du rejet de la mesure de l'air (`cause_mesure_air`), mise en sécurité de chaque sonde (`mise_en_securite`), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, temps depuis le démarrage, version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ), `mise_en_securite` (objet partiel `{"air":true\|false}`) |

`cause_mesure_air` vaut `null` quand la dernière mesure de l'air a été acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut : `muet`, `temperature-hors-plage` ou `humidite-hors-plage`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés par un défaut de sonde ; la cause, elle, se publie dès la première mesure rejetée. `mise_en_securite` publie l'état de chaque sonde qui en a une, aujourd'hui `{"air":true}` ou `{"air":false}`.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…}`, où `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale ; consigne plus hystérésis doit rester strictement sous `somme_max` ; `plages_max` est le nombre maximal de plages et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. Elles ne se règlent par aucune commande.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode ni la mise en sécurité à la reconnexion suivante ; lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ; une valeur rejetée n'est jamais lue comme une mesure courante, et la cause du rejet comme la mise en sécurité se lisent dans le même message que le défaut qu'elles expliquent.
