---
id: 2026-015
titre: Un jour et une nuit qui suivent les saisons, et une ventilation moins mécanique
domaines: [regulation, supervision]
liens:
  - { tag: pull_request, nom: 'ssk-terrarium#37', url: 'https://github.com/sskorupski/ssk-terrarium/pull/37' }
  - { tag: issue_github, nom: 'ssk-terrarium#35', url: 'https://github.com/sskorupski/ssk-terrarium/issues/35' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-013', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-013' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#47', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/issues/47' }
impacts:
  - { regle: RG-jour-et-nuit, operation: cree }
  - { regle: RG-ventilation-periodique, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { adr: ADR-heure-par-ntp, operation: modifie }
  - { regle: RG-sorties-par-mode, operation: touche }
  - { regle: RG-capteur-en-defaut, operation: touche }
  - { regle: RG-sondes-d-air, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
---

## Objectif

Depuis 2026-013, le ventilateur aère le bac à la manière d'un métronome : la même durée, au même intervalle, jour et nuit, tant que personne ne change les réglages. L'air d'un sous-bois ne se renouvelle pas ainsi : il bouge davantage le jour, se calme la nuit, quand les petits-gris sortent dans l'humidité, et ses mouvements ne reviennent jamais à la minute près. Le propriétaire veut un bac qui respire de façon moins mécanique, et un rythme de jour et de nuit qui suive l'année, plutôt que des horaires figés.

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| J1 | Le régulateur sait s'il fait jour ou nuit | `state` publie le moment de la journée et le jour d'aujourd'hui |
| J2 | Le jour suit l'année sans saut | En mode `saisons`, le début et la fin du jour glissent jour après jour d'une saison à la suivante |
| V1 | La ventilation peut être irrégulière sans s'emballer | En mode `rubato`, chaque aération tire sa durée et son intervalle autour des réglages, sans sortir des bornes |
| V2 | Le jour et la nuit ont chacun leur ventilation | Mode, durée, période et écart se règlent pour le jour et pour la nuit |
| V3 | Un air saturé se renouvelle, si on le veut | L'option saturation, inactive par défaut, fait tourner le ventilateur quand l'humidité reste au-dessus d'un seuil réglé |
| V4 | Sans réglage, rien ne change | Par défaut, le métronome de 2026-013, identique le jour et la nuit, et l'option saturation inactive |

La consigne de chauffage de jour et de nuit, que le propriétaire veut aussi, suit dans un cadrage à part, qui reprend RG-jour-et-nuit. La variation de vitesse du ventilateur est une piste : elle demande un autre ventilateur, ou un transistor à la place du relais.

### Ce que le référentiel disait déjà

- **RG-ventilation-periodique** (2026-013) : métronome seul, une durée, une période, une heure d'hibernation, aucune mesure. Ce cadrage la récrit : le métronome devient l'un de deux modes, ses réglages se dédoublent entre le jour et la nuit, et l'option saturation est la seule exception à « aucune mesure ».
- **Le contrat MQTT de 2026-013** publiait `ventilation` à plat, `{"duree","periode","heure"}`. Il change de forme ici. Aucun client ne le lit encore : le réglage dans l'application est l'issue sterrarium#19, pas commencée.
- **La décision `04-reglages-a-distance` de 2026-002** : tout réglage reste borné à la compilation. Le hasard du mode `rubato` et l'option saturation restent dans les bornes de RG-reglages-bornes ; ils ne l'ouvrent pas.
- **ADR-heure-par-ntp** : l'heure est connue après la première synchronisation, perdue à chaque redémarrage. RG-jour-et-nuit lit aussi la date, et retient le jour tant que l'heure n'est pas connue, comme `PLAGES` chauffe sur la consigne sans heure.
- **La piste #8** (éclairage à l'heure NTP) propose un éclairage de 8 h à 21 h. Le jour par défaut est le même ; quand l'éclairage sera cadré, il pourra suivre RG-jour-et-nuit plutôt que ses propres horaires.
- **RG-sondes-d-air et RG-capteur-en-defaut** : l'option saturation lit la mesure de l'air retenue pour réguler, et se tait quand elle manque.
- **Cadrages en cours** : 2026-009, 2026-010, 2026-011, 2026-012 et 2026-014 sont ouverts. 2026-009, 2026-010 et 2026-014 touchent aussi RG-topics-mqtt, RG-reglages-bornes ou RG-mode-au-demarrage : le dernier livré reprend dans ses énoncés ce que les autres y ont ajouté. L'énoncé de RG-topics-mqtt ci-dessous part de celui de 2026-013.

## Parcours utilisateur

1. Après la mise à jour, rien ne change : `state` publie `"jour_nuit":{"mode":"metronome","jour":"08:00-21:00"}`, `"moment":"jour"` ou `"nuit"`, et la ventilation de jour et de nuit en `metronome`, 5 minutes toutes les 60.
2. Le propriétaire passe la nuit en `rubato` : `{"ventilation":{"nuit":{"mode":"rubato","periode":120}}}`. La nuit, une aération dure de 3,5 à 6,5 minutes, arrondies à la minute, et la suivante commence de 84 à 156 minutes plus tard, au hasard. Le jour reste en métronome.
3. Il règle quatre saisons : `{"jour_nuit":{"mode":"saisons","saisons":[{"debut":"03-20","jour":"07:00-20:00"},{"debut":"06-21","jour":"06:00-22:00"},{"debut":"09-22","jour":"07:30-19:30"},{"debut":"12-21","jour":"08:30-17:30"}]}}`. Le 5 mai, 46 jours après le 20 mars sur les 93 qui le séparent du 21 juin, le jour commence à 06:30 et finit à 20:59 : `state` publie `"jour_aujourdhui":"06:30-20:59"`.
4. Il active l'option saturation : `{"ventilation":{"saturation":{"active":true}}}`. Après une brumisation, l'air reste à 96 % HR pendant 10 minutes : le ventilateur tourne 5 minutes, `aeration_saturation` passe à `true`, puis aucune aération de saturation ne revient avant 60 minutes. Avec le comportement `continu`, le ventilateur aurait tourné tant que l'humidité restait à 95 % ou plus, 5 minutes au plus.
5. La sonde intérieure tombe en défaut : la mesure de l'air manque, l'option saturation se tait, la ventilation de jour et de nuit continue.
6. Une coupure de courant suivie d'une box en panne laisse le régulateur sans heure : il retient le jour, et ventile avec les réglages du jour jusqu'au retour de l'heure.
7. Sur la liaison série, `JOUR` et `VENTILATION` affichent les réglages en place ; `CONFIG {"ventilation":{"jour":{"duree":1}}}` règle comme `cmd/config`.

## Énoncés

### RG-jour-et-nuit

Le régulateur distingue le jour et la nuit selon l'un de deux modes, réglables :

- **`metronome`** : le même jour tous les jours, écrit `HH:MM-HH:MM`.
- **`saisons`** : de 1 à 6 saisons, chacune avec sa date de début, `MM-JJ`, et son jour, `HH:MM-HH:MM`. Rangées par date, elles se suivent en boucle sur l'année. Entre le début d'une saison et celui de la suivante, le début et la fin du jour glissent jour après jour, en ligne droite, de ceux de la saison vers ceux de la suivante, arrondis à la minute ; ils les atteignent le jour où la suivante commence. Avec une seule saison, son jour vaut toute l'année. Les jours se comptent sur une année de 365 jours : le 29 février prend le jour du 28.

Le jour commence à l'heure de début, incluse, et finit à l'heure de fin, exclue ; il ne passe pas minuit, dure au moins une heure, et laisse une nuit d'au moins une heure. Le reste est la nuit. Date et heure se lisent dans le fuseau réglé (ADR-heure-par-ntp). Tant que l'heure n'est pas connue, c'est le jour.

Par défaut : `metronome`, `08:00-21:00`.

Ce que la règle protège : un rythme de jour et de nuit qui suit l'année sans saut d'un jour à l'autre, et qui ne bascule jamais dans la nuit faute d'heure.

### RG-ventilation-periodique

Le ventilateur renouvelle l'air du bac selon le mode :

| Mode | Ventilateur |
| --- | --- |
| `ACTIF`, `PLAGES` | Il suit les réglages du moment de la journée, `jour` ou `nuit` (RG-jour-et-nuit) |
| `HIBERNATION` | Une aération par jour, de jour comme de nuit, réglée par `hibernation` |
| `MAINTENANCE` | Coupé, même au milieu d'une aération, option saturation comprise |

**En `ACTIF` et en `PLAGES`**, `jour` et `nuit` portent chacun un mode, une durée, une période et un écart :

- **`metronome`** : chaque aération dure `duree` minutes, et la suivante commence `periode` minutes après le début de la précédente.
- **`rubato`** : chaque aération tire au hasard sa durée entre `duree` × (1 − `ecart`) et `duree` × (1 + `ecart`), et l'intervalle jusqu'au début de la suivante entre `periode` × (1 − `ecart`) et `periode` × (1 + `ecart`), arrondis à la minute, puis ramenés dans les bornes de RG-reglages-bornes, la durée strictement sous l'intervalle. En moyenne, l'air se renouvelle comme en métronome ; jamais deux fois au même rythme.

La première aération commence au démarrage et à chaque changement de mode. La durée d'une aération et l'intervalle jusqu'à la suivante se fixent à son début, avec les réglages du moment de la journée à cet instant : un réglage accepté, ou le passage du jour à la nuit, vaut à partir de l'aération suivante.

**En `HIBERNATION`**, une aération de `hibernation.duree` minutes par jour. Heure connue : elle commence à `hibernation.heure`, dans le fuseau réglé. Heure inconnue : 24 h après le début de la précédente, ou après le démarrage ou l'entrée dans le mode s'il n'y en a pas eu. Une aération ne commence jamais moins de 12 h après le début de la précédente.

**L'option `saturation`**, inactive par défaut, vaut en `ACTIF`, `PLAGES` et `HIBERNATION`. Elle se déclenche quand toutes les mesures de l'air (RG-sondes-d-air) depuis `attente` minutes ont une humidité d'au moins `humidite` % HR ; une mesure en dessous, ou une mesure de l'air manquante, recommence l'attente. Déclenchée, elle fait tourner le ventilateur selon son `comportement` :

- **`aeration`** : pendant `duree` minutes ;
- **`continu`** : tant que l'humidité reste d'au moins `humidite` % HR, et au plus `duree` minutes ; une mesure en dessous, ou manquante, l'arrête.

Puis l'attente ne reprend qu'après `pause` minutes. Pendant qu'elle tourne, l'option saturation l'emporte sur le jour, la nuit et l'hibernation, qui continuent leur décompte. Le ventilateur ne dépend d'aucune autre mesure : le défaut d'une sonde, la mise en sécurité et la coupure par le substrat n'y changent rien.

Par défaut, `jour` et `nuit` valent `metronome`, 5 minutes toutes les 60 minutes, avec un écart de 30 % ; `hibernation` vaut 13:00 et 5 minutes ; `saturation` est inactive, en `aeration`, à 95 % HR, avec 10 minutes d'attente, 5 minutes d'aération et 60 minutes de pause. Chaque mise en marche et chaque arrêt sont annoncés sur la liaison série, `VENTILATION marche` et `VENTILATION arret`, suivis de `(saturation)` quand c'est l'option qui les cause.

Ce que la règle protège : l'air confiné et saturé du bac se renouvelle sans se dessécher, plus le jour que la nuit si on le veut, et sans régularité mécanique ; une heure perdue ne fait pas sauter l'aération d'hibernation ; un air saturé ne le reste pas, sans que le ventilateur tourne sans fin ; rien ne tourne pendant qu'on a les mains dans le bac.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air, la combinaison des sondes intérieures, le jour et la nuit (RG-jour-et-nuit), et les réglages de la ventilation (RG-ventilation-periodique) sont réglables à distance et par la liaison série. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ;
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

Sur la liaison série, `CONFIG` suivi d'un JSON règle exactement comme `cmd/config` (décision `05-reglage-par-la-liaison-serie`).

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures ;
- le jour et la nuit ;
- les réglages de la ventilation : jour, nuit, hibernation et option saturation.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau, rôles et combinaison ensemble, jour et nuit, réglages de la ventilation ensemble — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis ;
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
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, le jour et la nuit (`jour_nuit`), le jour d'aujourd'hui (`jour_aujourdhui`) et le moment de la journée (`moment`), les réglages de la ventilation (`ventilation`) et l'aération de saturation en cours ou non (`aeration_saturation`), l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45 |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide`. `jour_nuit` : objet complet, qui remplace celui en place. `ventilation` : objet partiel à deux niveaux, `{"jour":{…},"nuit":{…},"hibernation":{…},"saturation":{…}}`, chacun partiel |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

`jour_nuit` publie le réglage de RG-jour-et-nuit : `{"mode":"metronome","jour":"08:00-21:00"}`, ou `{"mode":"saisons","saisons":[{"debut":"03-20","jour":"07:00-21:00"},…]}`, saisons rangées par date. `jour_aujourdhui` est le jour calculé pour la date du jour, `"HH:MM-HH:MM"`, ou `null` tant que l'heure n'est pas connue. `moment` vaut `jour` ou `nuit` ; il vaut `jour` tant que l'heure n'est pas connue.

`ventilation` publie les réglages en place de RG-ventilation-periodique : `{"jour":{"mode":…,"duree":…,"periode":…,"ecart":…},"nuit":{…},"hibernation":{"heure":"HH:MM","duree":…},"saturation":{"active":…,"comportement":…,"humidite":…,"attente":…,"duree":…,"pause":…}}`. Ce que fait le ventilateur à l'instant se lit dans `sorties.ventilateur`, et `aeration_saturation` dit si c'est l'option saturation qui le fait tourner.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…],"saisons_max":…,"ventilation":{"duree":[min,max],"periode":[min,max],"ecart":[min,max],"humidite":[min,max],"attente":[min,max],"pause":[min,max]}}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. `saisons_max` est le nombre maximal de saisons. Les intervalles de `ventilation` sont admis bornes comprises, en minutes ou en pour cent entiers ; `duree` vaut pour la ventilation de jour et de nuit, l'aération d'hibernation et l'option saturation ; une durée de ventilation doit rester strictement sous sa période. Aucune commande ne règle ces bornes.

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

### ADR-heure-par-ntp

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Il se synchronise dès que le Wi-Fi est joint après un démarrage, puis une fois par jour. L'heure est tenue pour connue dès la première synchronisation depuis le démarrage, puis avance sur l'horloge interne de l'ESP32 même si le réseau tombe ; elle se perd à chaque redémarrage. Elle est lue dans un fuseau horaire réglable, écrit comme une chaîne POSIX TZ ; par défaut celui de Paris, heure d'été comprise (`CET-1CEST,M3.5.0,M10.5.0/3`) — décision `05-fuseau`. En dépendent le jour et la nuit (RG-jour-et-nuit), qui lisent aussi la date, et qui retiennent le jour tant que l'heure n'est pas connue ; le chauffage du mode `PLAGES`, qui ne descend jamais au plancher hors plage sur une heure inconnue (RG-chauffage-par-plages), et l'aération quotidienne du mode `HIBERNATION`, qui retombe sur un décompte de 24 heures tant que l'heure n'est pas connue (RG-ventilation-periodique). Les cycles de ventilation d'`ACTIF` et de `PLAGES` se comptent en durée écoulée ; seuls leurs réglages, de jour ou de nuit, dépendent de l'heure. Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC (2026-001), et le Wi-Fi est déjà là pour la supervision (2026-002).
