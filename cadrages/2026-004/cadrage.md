---
id: 2026-004
titre: Publier les bornes des réglages dans l'état retenu
domaines: [supervision]
liens:
  - { tag: issue_github, nom: 'ssk-terrarium#16', url: 'https://github.com/sskorupski/ssk-terrarium/issues/16' }
  - { tag: pull_request, nom: 'ssk-terrarium#17', url: 'https://github.com/sskorupski/ssk-terrarium/pull/17' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-001', url: 'https://github.com/sskorupski/sterrarium-cadrage/pull/2' }
impacts:
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-reglages-bornes, operation: touche }
---

## Objectif

L'application sterrarium montre et modifie les réglages du régulateur — consigne, hystérésis, plages, fuseau — et doit aider la saisie en connaissant leurs bornes. Ces bornes sont fixées à la compilation du firmware (RG-reglages-bornes) et ne sont publiées nulle part : l'application n'a aujourd'hui d'autre moyen que de les recopier, et deux copies d'un même fait divergent au premier firmware qui les change.

Ce qu'on cherche : que l'application lise les bornes du firmware qui applique les réglages, sans jamais en devenir la source. Les bornes restent des constantes de compilation ; aucune commande ne les change.

### Ce que le référentiel disait déjà

- RG-topics-mqtt, dans l'énoncé que 2026-003 lui a donné, fixe le contenu de `state` ; c'est lui qui change ici.
- RG-reglages-bornes pose les bornes et dit qu'aucune commande ni aucun réglage enregistré ne les change : ce cadrage ne la modifie pas, il la rend lisible de l'extérieur.
- La décision 03-publication-des-bornes du cadrage 2026-001 de sterrarium ([sterrarium-cadrage#2](https://github.com/sskorupski/sterrarium-cadrage/pull/2)) a choisi la forme côté application ; elle est reprise ici, dans le référentiel du firmware dont elle change le contrat.

## Parcours utilisateur

1. Le régulateur publie son état retenu toutes les 30 s ; l'état porte désormais un objet `bornes` : `"bornes":{"consigne":[15.0,22.0],"hysteresis":[0.2,2.0],"somme_max":24.0,"plages_max":4,"fuseau_max":47}`.
2. L'application lit l'état à l'abonnement, sans attendre la mesure suivante, et propose la saisie dans ces bornes.
3. Un firmware plus ancien, sans `bornes`, laisse l'application en lecture seule de ses réglages : elle ne devine pas des bornes qu'on ne lui a pas données.
4. Une valeur envoyée hors bornes reste refusée par le firmware, seul juge (RG-reglages-bornes) : les bornes publiées aident la saisie, elles ne la valident pas.

### Ce qui a été appris en faisant

L'état le plus long — quatre plages, un fuseau de 47 caractères, toutes les mesures, une version de 30 caractères — mesure 593 octets avec ses bornes. Il tient dans la taille maximale de l'état (640 octets) et dans le tampon MQTT (768 octets, en-tête et sujet compris), qui n'ont pas eu à grandir ; une assertion de compilation vérifie désormais le tampon.

## Énoncés

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, temps depuis le démarrage, version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ) |

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…}`, où `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale ; consigne plus hystérésis doit rester strictement sous `somme_max` ; `plages_max` est le nombre maximal de plages et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. Elles ne se règlent par aucune commande.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode à la reconnexion suivante ; lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique.
