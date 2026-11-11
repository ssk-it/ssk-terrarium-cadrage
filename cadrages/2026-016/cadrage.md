---
id: 2026-016
titre: Une consigne de chauffage pour le jour et une pour la nuit en mode ACTIF
domaines: [regulation, supervision]
liens:
  - { tag: pull_request, nom: 'ssk-terrarium#37', url: 'https://github.com/sskorupski/ssk-terrarium/pull/37' }
  - { tag: issue_github, nom: 'ssk-terrarium#36', url: 'https://github.com/sskorupski/ssk-terrarium/issues/36' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-015', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-015' }
impacts:
  - { regle: RG-chauffage-par-hysteresis, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-chauffage-par-plages, operation: touche }
  - { regle: RG-sorties-par-mode, operation: touche }
  - { regle: RG-chauffe-continue-bornee, operation: touche }
  - { regle: RG-coupure-par-le-substrat, operation: touche }
---

## Objectif

En mode `ACTIF`, le bac est tenu à la même consigne jour et nuit, 19 °C par défaut. Dehors, la nuit est plus fraîche que le jour, et les petits-gris sortent dans cette fraîcheur humide. Le propriétaire veut une consigne pour le jour et une pour la nuit, qui suivent le jour et la nuit de 2026-015 : un jour fixe ou des saisons.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| C1 | La nuit peut être plus fraîche que le jour | En `ACTIF`, le chauffage suit la consigne et l'hystérésis du moment de la journée |
| C2 | Les deux restent bornées | Jour et nuit dans les bornes de la consigne d'aujourd'hui, sous 24 °C |
| C3 | Les clients existants ne cassent pas | `consigne` et `hysteresis` gardent leur nom et leur sens : les valeurs de jour |
| C4 | Sans réglage, rien ne change | La nuit vaut par défaut 19 °C ± 0,5, comme le jour |

### Ce que le référentiel disait déjà

- **RG-jour-et-nuit** (2026-015, sur sa branche) : la frontière entre le jour et la nuit, et le jour retenu tant que l'heure n'est pas connue. Ce cadrage s'appuie sur elle et se livre après 2026-015, dont il reprend les énoncés de RG-reglages-bornes, RG-mode-au-demarrage et RG-topics-mqtt.
- **RG-chauffage-par-plages** : `PLAGES` chauffe sur la consigne en plage, et sur un plancher de 12 à 14 °C hors plage. Le propriétaire le garde tel quel (décision `01-portee-du-jour-et-de-la-nuit`) : en plage, c'est la consigne de jour.
- **La décision `04-reglages-a-distance` de 2026-002** et **RG-reglages-bornes** : la consigne de nuit a les mêmes bornes que celle de jour. Aucune ne peut porter l'air au-delà de 24 °C.
- **RG-chauffe-continue-bornee** et **RG-coupure-par-le-substrat** priment sur la consigne, de jour comme de nuit.
- **sterrarium**, l'application, règle aujourd'hui `consigne` et `hysteresis` : elles restent celles du jour, et l'application continue de fonctionner sans changement ; régler la nuit s'y cadrera à part.

## Parcours utilisateur

1. Après la mise à jour, rien ne change : `state` publie `"consigne":19.0,"hysteresis":0.5,"chauffage_nuit":{"consigne":19.0,"hysteresis":0.5}`.
2. Le propriétaire règle la nuit à 17 °C : `{"chauffage_nuit":{"consigne":17}}`. En `ACTIF`, à la fin du jour (`moment` passe à `nuit`), le chauffage vise 17 °C ± 0,5 ; au début du jour suivant, de nouveau 19 °C.
3. Il tente `{"chauffage_nuit":{"consigne":23}}` : 23 + 0,5 dépasse 24 °C, la commande est refusée en entier, avec `hors bornes`.
4. En `PLAGES`, rien ne change : en plage, la consigne de jour ; hors plage, le plancher.
5. Sans heure, c'est le jour (RG-jour-et-nuit) : le chauffage vise la consigne de jour.

## Énoncés

### RG-chauffage-par-hysteresis

En mode `ACTIF`, le chauffage suit la consigne et l'hystérésis du moment de la journée (RG-jour-et-nuit) : celles de jour le jour, ou tant que l'heure n'est pas connue, et celles de nuit la nuit. Il s'allume quand la température de l'air descend sous la consigne moins l'hystérésis, et s'éteint quand elle dépasse la consigne plus l'hystérésis ; entre les deux, il garde son état. Au passage du jour à la nuit, et inversement, il garde son état et suit dès la mesure suivante les nouvelles valeurs. Par défaut, la consigne vaut 19 °C et l'hystérésis 0,5 °C, de jour comme de nuit. En plage du mode `PLAGES`, c'est toujours la consigne et l'hystérésis de jour (RG-chauffage-par-plages). RG-coupure-par-le-substrat et RG-chauffe-continue-bornee priment sur cette règle. Ce que la règle protège : l'air reste dans la bande voulue, plus fraîche la nuit si on le veut, sans que le relais batte à chaque mesure.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage de jour, utilisées en mode `ACTIF` le jour et pendant les plages du mode `PLAGES`, celles de nuit, utilisées en mode `ACTIF` la nuit, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air, la combinaison des sondes intérieures, le jour et la nuit (RG-jour-et-nuit), et les réglages de la ventilation (RG-ventilation-periodique) sont réglables à distance et par la liaison série. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- de jour comme de nuit, consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ;
- de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ;
- un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j` ;
- pour chaque sonde, le rôle `interieure` ou `exterieure`, avec au moins une sonde intérieure ;
- pour la combinaison, l'une des valeurs de RG-sondes-d-air ;
- pour le jour et la nuit, un jour `HH:MM-HH:MM` qui ne passe pas minuit, d'au moins une heure, et laissant une nuit d'au moins une heure ; en mode `saisons`, de 1 à 6 saisons, aux dates `MM-JJ` valides et toutes différentes, le 29 février exclu, chacune avec un tel jour ;
- pour la ventilation de jour et de nuit, le mode `metronome` ou `rubato`, une durée de 1 à 30 minutes et une période de 15 à 240 minutes, la durée strictement sous la période, et un écart de 10 à 50 % ;
- pour l'aération d'hibernation, une heure `HH:MM` et une durée de 1 à 30 minutes ;
- pour l'option saturation, le comportement `aeration` ou `continu`, une humidité de 80 à 100 % HR, une attente de 1 à 60 minutes, une durée de 1 à 30 minutes et une pause de 15 à 240 minutes.

Les durées, périodes, attentes et pauses sont en minutes entières, l'écart et l'humidité en pour cent entiers.

Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Cela vaut aussi pour une commande qui, appliquée, ne laisserait aucune sonde intérieure, ou laisserait une durée de ventilation qui n'est pas strictement sous sa période. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile.

Ne sont pas des réglages, et aucune commande ne les modifie :

- le hors-gel de `HIBERNATION` (4-6 °C) ;
- le plancher hors plage de `PLAGES` (12-14 °C) ;
- les seuils de la coupure par le substrat (24 °C et 18,5 °C) ;
- la durée maximale de chauffe continue ;
- les plages de rejet d'une mesure et le délai de 2 minutes avant un défaut (RG-capteur-en-defaut) ;
- l'écart minimal de 12 heures et le repli de 24 heures de l'aération d'hibernation (RG-ventilation-periodique) ;
- le tirage au hasard du mode `rubato`, qui ne sort jamais des bornes ci-dessus ;
- le chien de garde.

La mise en sécurité se désactive par commande, comme RG-capteur-en-defaut le prévoit, mais rien ne règle ce qu'elle fait quand elle est active.

Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni lever la coupure par le substrat, ni laisser le régulateur sans sonde pour réguler, ni faire tourner le ventilateur sans arrêt ou jamais, même par l'option saturation ou par le hasard du mode `rubato`.

Sur la liaison série, `CONFIG` suivi d'un JSON règle exactement comme `cmd/config` (2026-015, décision `05-reglage-par-la-liaison-serie`).

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis de jour, et celles de nuit ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures ;
- le jour et la nuit ;
- les réglages de la ventilation : jour, nuit, hibernation et option saturation.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis de jour ensemble, de nuit ensemble, plages, fuseau, rôles et combinaison ensemble, jour et nuit, réglages de la ventilation ensemble — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis, de jour comme de nuit ;
- les plages `01:35-06:30` et `14:05-17:05` ;
- le fuseau de Paris ;
- `sht45` intérieure, `dht11` extérieure et la combinaison `priorite-sht45` ;
- le mode `metronome` et le jour `08:00-21:00` ;
- pour la ventilation de jour comme de nuit, le mode `metronome`, 5 minutes toutes les 60 minutes, un écart de 30 % ; l'aération d'hibernation à 13:00 pendant 5 minutes ; l'option saturation inactive, en `aeration`, à 95 % HR, 10 minutes d'attente, 5 minutes d'aération et 60 minutes de pause.

Un réglage de ventilation enregistré sous la forme de 2026-013 (durée, période et heure seules) n'est pas repris : le régulateur prend celui du firmware, qui lui est égal par défaut. Le décompte des aérations, l'heure de la dernière et l'attente de l'option saturation ne sont pas enregistrés : ils repartent du démarrage (RG-ventilation-periodique). Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables.

Ce que la règle protège :

- une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel ;
- un régulateur qui ne sait pas où il en est ne chauffe pas au hasard ;
- un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant ;
- des rôles illisibles ne laissent pas le régulateur sans sonde intérieure ;
- un réglage de ventilation illisible ne laisse pas le bac sans aération.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne et l'hystérésis de jour, celles de nuit (`chauffage_nuit`), les plages, le fuseau, le jour et la nuit (`jour_nuit`), le jour d'aujourd'hui (`jour_aujourdhui`) et le moment de la journée (`moment`), les réglages de la ventilation (`ventilation`) et l'aération de saturation en cours ou non (`aeration_saturation`), l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45 |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : de jour, en °C. `chauffage_nuit` : objet partiel `{"consigne":…,"hysteresis":…}`, en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide`. `jour_nuit` : objet complet, qui remplace celui en place. `ventilation` : objet partiel à deux niveaux, `{"jour":{…},"nuit":{…},"hibernation":{…},"saturation":{…}}`, chacun partiel |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

`jour_nuit` publie le réglage de RG-jour-et-nuit : `{"mode":"metronome","jour":"08:00-21:00"}`, ou `{"mode":"saisons","saisons":[{"debut":"03-20","jour":"07:00-21:00"},…]}`, saisons rangées par date. `jour_aujourdhui` est le jour calculé pour la date du jour, `"HH:MM-HH:MM"`, ou `null` tant que l'heure n'est pas connue. `moment` vaut `jour` ou `nuit` ; il vaut `jour` tant que l'heure n'est pas connue.

`consigne` et `hysteresis` gardent leur nom et leur sens pour les clients existants : ce sont les valeurs de jour, celles qu'emploie aussi `PLAGES`. `chauffage_nuit` publie `{"consigne":…,"hysteresis":…}`, à une décimale. Celles qui s'appliquent à l'instant en `ACTIF` se lisent avec `moment`.

`ventilation` publie les réglages en place de RG-ventilation-periodique : `{"jour":{"mode":…,"duree":…,"periode":…,"ecart":…},"nuit":{…},"hibernation":{"heure":"HH:MM","duree":…},"saturation":{"active":…,"comportement":…,"humidite":…,"attente":…,"duree":…,"pause":…}}`. Ce que fait le ventilateur à l'instant se lit dans `sorties.ventilateur`, et `aeration_saturation` dit si c'est l'option saturation qui le fait tourner.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…],"saisons_max":…,"ventilation":{"duree":[min,max],"periode":[min,max],"ecart":[min,max],"humidite":[min,max],"attente":[min,max],"pause":[min,max]}}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale, de jour comme de nuit. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. `saisons_max` est le nombre maximal de saisons. Les intervalles de `ventilation` sont admis bornes comprises, en minutes ou en pour cent entiers ; `duree` vaut pour la ventilation de jour et de nuit, l'aération d'hibernation et l'option saturation ; une durée de ventilation doit rester strictement sous sa période. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`. Une commande `ventilation` hors bornes, mal formée, ou qui laisserait une durée au moins égale à sa période, l'est avec la raison `ventilation invalide` ; une commande `jour_nuit` hors bornes ou mal formée, avec la raison `jour_nuit invalide`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité, le rôle des sondes ni la ventilation à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série ;
- les réglages de la ventilation, le moment de la journée et l'aération de saturation se lisent dans le même message que l'état du ventilateur qu'ils expliquent.
