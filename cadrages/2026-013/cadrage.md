---
id: 2026-013
titre: Le ventilateur renouvelle l'air du bac selon une durée et une période réglables à distance
domaines: [regulation, supervision]
liens:
  - { tag: piste, nom: '#9', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/issues/9' }
  - { tag: issue_github, nom: 'ssk-terrarium#29', url: 'https://github.com/sskorupski/ssk-terrarium/issues/29' }
  - { tag: issue_github, nom: 'sterrarium#19', url: 'https://github.com/sskorupski/sterrarium/issues/19' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-008', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-008' }
impacts:
  - { regle: RG-ventilation-periodique, operation: cree }
  - { regle: RG-sorties-par-mode, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { adr: ADR-heure-par-ntp, operation: modifie }
  - { regle: RG-sorties-coupees-au-demarrage, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { regle: RG-capteur-en-defaut, operation: touche }
  - { regle: RG-brochage, operation: touche }
  - { adr: ADR-commande-230v-par-relais-filaires, operation: touche }
---

## Objectif

L'air du bac est confiné et proche de la saturation : une centaine d'escargots y respirent, le substrat est humide, et rien ne le renouvelle. Le ventilateur 5 V est câblé sur sa voie de relais depuis la phase 1 (RG-brochage, GPIO 33), mais le firmware le tient coupé dans tous les modes (RG-sorties-par-mode), faute de règle qui dise quand il tourne. `state` publie déjà `sorties.ventilateur`, toujours à `false`.

L'exigence F10 de 2026-001 donne des valeurs — 5 minutes par heure en `ACTIF`, une aération de 5 minutes par jour en `HIBERNATION` —, que le firmware a recopiées dans ses constantes avec la mention « à valider ». Personne ne sait encore si 5 minutes suffisent à renouveler l'air sans dessécher le bac. Le propriétaire veut pouvoir les ajuster depuis l'application sterrarium, en observant l'élevage, sans téléverser un firmware à chaque essai.

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| V1 | L'air du bac se renouvelle en activité comme en hibernation | En `ACTIF` et en `PLAGES`, le ventilateur tourne au début de chaque période ; en `HIBERNATION`, une fois par jour ; en `MAINTENANCE`, jamais |
| V2 | La durée et la période se règlent sans toucher au firmware | `ventilation` se règle par `cmd/config` et par la liaison série, et se conserve après une coupure |
| V3 | Aucun réglage ne fait tourner le ventilateur en continu, ni ne l'empêche de tourner | Une durée hors de 1 à 30 min, une période hors de 15 à 240 min, ou une durée qui n'est pas strictement sous la période, sont refusées en entier |
| V4 | L'aération d'hibernation tombe à l'heure choisie, et n'est jamais sautée faute d'heure | Heure connue : elle commence à l'heure réglée. Heure inconnue : elle commence 24 h après la précédente |
| V5 | Ce que fait le ventilateur se voit | `state` publie les réglages de la ventilation, leurs bornes et l'état du ventilateur |
| V6 | Sans réglage, on retrouve F10 | Par défaut, 5 minutes toutes les 60 minutes, et l'aération d'hibernation à 13:00 |

### Ce que le référentiel disait déjà

- **La piste #9** proposait RG-ventilation-periodique avec les valeurs de F10, sans les rendre réglables ni dire à quelle heure tombe l'aération quotidienne. Ce cadrage la réalise, en la rendant réglable (décision `01-reglage-de-la-ventilation`).
- **RG-sorties-par-mode** tient la ventilation coupée dans tous les modes, en annonçant que le cadrage de la phase 2 lui donnera son comportement en modifiant cette règle, et qu'elle suivra en `PLAGES` ce qu'elle fait en `ACTIF`. C'est ce que fait ce cadrage, pour la ventilation seule : la brumisation et l'éclairage restent coupés.
- **La décision `04-reglages-a-distance` de 2026-002** : tout réglage à distance est borné à la compilation, une commande hors bornes est refusée en entier. Ce cadrage ne la rouvre pas : les bornes de la ventilation sont des constantes du firmware (décision `02-bornes-de-la-ventilation`).
- **La décision `03-publication-des-bornes` de sterrarium 2026-001, reprise par la décision `01` de 2026-004** : les bornes se publient dans `state.bornes`, à côté des valeurs en place. Celles de la ventilation y entrent de la même façon : l'application ne peut rien régler qu'elle ne lise dans `state`.
- **NF5 et ADR-heure-par-ntp** : seuls l'éclairage et la ventilation devaient dépendre de l'heure. Ce cadrage n'emploie que « l'heure connue » qu'ADR-heure-par-ntp tient déjà, et retombe sur un décompte quand elle ne l'est pas (décision `03-calage-de-l-aeration-quotidienne`). Il n'a donc pas besoin de l'heure estimée après un démarrage sans réseau que propose RG-heure-ntp (piste #8, éclairage), qui reste à cadrer avec l'éclairage.
- **RG-sorties-coupees-au-demarrage** et **RG-relais-coupes-sans-commande** : le ventilateur est coupé avant toute autre opération du démarrage. Rien ne change : la ventilation ne reprend qu'une fois le démarrage fait, selon le mode repris.
- **RG-regulation-sans-reseau** : la ventilation se décide sur le régulateur, avec ses réglages enregistrés. Sans réseau, elle continue.
- **RG-capteur-en-defaut** et **RG-coupure-par-le-substrat** coupent le chauffage et la pompe. Ils ne touchent pas au ventilateur : renouveler l'air ne dépend d'aucune mesure.
- **`cmd/override`** (forçage temporaire d'une sortie, piste #13) reste hors périmètre. Le contrat MQTT ne le lie pas aux réglages de `cmd/config` : il se cadrera à part, pour toutes les sorties ensemble.

### Cadrages en cours qui touchent les mêmes règles

- **2026-008**, sur sa branche (demande ssk-it/ssk-terrarium-cadrage#34), modifie RG-topics-mqtt pour l'événement `chauffe-sonde`. L'énoncé de RG-topics-mqtt ci-dessous part du sien : ce cadrage se livre après lui. S'il était abandonné, l'énoncé perdrait ce qui le concerne avant la livraison.
- **2026-009** (alertes) et **2026-010** (mise à jour à distance), préparés en parallèle et pas encore poussés, modifient aussi RG-topics-mqtt, RG-reglages-bornes et RG-mode-au-demarrage. Le second livré reprend dans ses énoncés ce que le premier y a ajouté.

## Parcours utilisateur

1. Le propriétaire téléverse le firmware. Au démarrage, la liaison série annonce les réglages repris : `VENTILATION duree=5 periode=60 heure=13:00 au demarrage`. Le régulateur reprend le mode `ACTIF` : le ventilateur se met en marche aussitôt, pour les 5 premières minutes de la première période. La liaison série écrit `VENTILATION marche`, puis `VENTILATION arret` 5 minutes plus tard. `state` publie `sorties.ventilateur` à `true` pendant ces 5 minutes.
2. Dans l'application, il lit `ventilation` dans `state` — `{"duree":5,"periode":60,"heure":"13:00"}` — et ses bornes dans `state.bornes.ventilation`. Il porte la durée à 10 minutes : l'application publie `{"ventilation":{"duree":10}}` sur `cmd/config`. Le régulateur l'accepte, l'enregistre et répond sur `event`. Le décompte n'est pas relancé : la période en cours dure toujours 60 minutes depuis son début, et la prochaine aération dure 10 minutes.
3. Il tente une durée de 45 minutes, ou une période de 10 minutes. Le régulateur refuse la commande en entier, avec la raison `ventilation invalide`, et rien ne change. De même pour `{"ventilation":{"duree":20,"periode":20}}` : la durée doit rester strictement sous la période.
4. Il passe en `PLAGES`. Le ventilateur y fait ce qu'il fait en `ACTIF`, en plage comme hors plage : un changement de mode relance le décompte, et la première période commence par une aération.
5. En novembre, il passe en `HIBERNATION`. Le ventilateur ne tourne plus qu'une fois par jour, à 13:00 dans le fuseau réglé, pendant la durée réglée. Il choisit 14:30 : `{"ventilation":{"heure":"14:30"}}`. L'aération suivante tombe à 14:30.
6. Une coupure de courant suivie d'une panne de la box laisse le régulateur sans heure. En `HIBERNATION`, l'aération commence 24 heures après le démarrage, puis toutes les 24 heures tant que l'heure reste inconnue. Quand le NTP rend l'heure, l'aération retombe à 14:30 : elle n'a jamais lieu moins de 12 heures après la précédente.
7. Il passe en `MAINTENANCE` pour nettoyer le bac. Le ventilateur s'arrête aussitôt, même au milieu d'une aération, et ne tourne plus jusqu'au changement de mode suivant.

## Énoncés

### RG-ventilation-periodique

Le ventilateur renouvelle l'air du bac selon trois réglages :

- `duree` : combien de minutes dure une aération ;
- `periode` : en `ACTIF` et en `PLAGES`, toutes les combien de minutes une aération commence ;
- `heure` : en `HIBERNATION`, l'heure de l'aération quotidienne, écrite `HH:MM` dans le fuseau réglé (ADR-heure-par-ntp).

Par défaut, 5 minutes toutes les 60 minutes, et l'aération d'hibernation à 13:00. Les trois se règlent dans les bornes de RG-reglages-bornes.

Ce que fait le ventilateur selon le mode :

| Mode | Ventilateur |
| --- | --- |
| `ACTIF`, `PLAGES` | Les périodes se comptent depuis le démarrage ou le dernier changement de mode. Le ventilateur tourne les `duree` premières minutes de chaque période |
| `HIBERNATION` | Une aération de `duree` minutes par jour. Heure connue : elle commence à `heure`. Heure inconnue : 24 h après le début de la précédente, ou 24 h après le démarrage ou l'entrée dans le mode s'il n'y en a pas eu. Une aération ne commence jamais moins de 12 h après le début de la précédente |
| `MAINTENANCE` | Coupé, y compris au milieu d'une aération |

Un réglage accepté s'applique dès la mesure suivante, sans relancer le décompte : une aération en cours s'arrête dès qu'elle a atteint la durée réglée. Le ventilateur ne dépend d'aucune mesure : le défaut d'une sonde, la mise en sécurité et la coupure par le substrat n'y changent rien. Chaque mise en marche et chaque arrêt sont annoncés sur la liaison série, `VENTILATION marche` et `VENTILATION arret`.

Ce que la règle protège : l'air confiné et saturé du bac se renouvelle, sans se dessécher, y compris pendant les mois d'hibernation ; une heure perdue ne fait pas sauter l'aération quotidienne ; rien ne tourne pendant qu'on a les mains dans le bac.

### RG-sorties-par-mode

Le régulateur a quatre modes, et chacun dit ce que le chauffage et le ventilateur peuvent faire :

| Mode | Chauffage | Ventilateur | Usage |
| --- | --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Une aération par période (RG-ventilation-periodique) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Comme en `ACTIF`, en plage comme hors plage | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Une aération par jour (RG-ventilation-periodique) | Novembre à février |
| `MAINTENANCE` | Coupé | Coupé | Nettoyage, changement de substrat |

Dans `ACTIF`, `PLAGES` et `HIBERNATION`, la coupure par le substrat prime sur ce que dit le tableau pour le chauffage (RG-coupure-par-le-substrat). La brumisation et l'éclairage suivent en `PLAGES` ce qu'ils font en `ACTIF` ; ils restent coupés dans tous les modes jusqu'à ce que les cadrages des phases 2 et 4 leur donnent leur comportement, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler, et l'air du bac se renouvelle encore ; en maintenance, rien ne s'allume ni ne tourne pendant qu'on a les mains dans le bac.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air, la combinaison des sondes intérieures, et la durée, la période et l'heure de la ventilation sont réglables à distance et par la liaison série. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ;
- de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ;
- un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j` ;
- pour chaque sonde, le rôle `interieure` ou `exterieure`, avec au moins une sonde intérieure ;
- pour la combinaison, l'une des valeurs de RG-sondes-d-air ;
- pour la ventilation, une durée de 1 à 30 minutes et une période de 15 à 240 minutes, en minutes entières, la durée strictement sous la période, et une heure `HH:MM` valide.

Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Cela vaut aussi pour une commande qui, appliquée, ne laisserait aucune sonde intérieure, ou laisserait une durée de ventilation qui n'est pas strictement sous la période. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile.

Ne sont pas des réglages, et aucune commande ne les modifie :

- le hors-gel de `HIBERNATION` (4-6 °C) ;
- le plancher hors plage de `PLAGES` (12-14 °C) ;
- les seuils de la coupure par le substrat (24 °C et 18,5 °C) ;
- la durée maximale de chauffe continue ;
- les plages de rejet d'une mesure et le délai de 2 minutes avant un défaut (RG-capteur-en-defaut) ;
- l'écart minimal de 12 heures et le repli de 24 heures de l'aération d'hibernation (RG-ventilation-periodique) ;
- le chien de garde.

La mise en sécurité se désactive par commande, comme RG-capteur-en-defaut le prévoit, mais rien ne règle ce qu'elle fait quand elle est active.

Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni lever la coupure par le substrat, ni laisser le régulateur sans sonde pour réguler, ni faire tourner le ventilateur sans arrêt ou jamais.

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures ;
- la durée, la période et l'heure de la ventilation.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau, rôles et combinaison ensemble, durée, période et heure de la ventilation ensemble — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis ;
- les plages `01:35-06:30` et `14:05-17:05` ;
- le fuseau de Paris ;
- `sht45` intérieure, `dht11` extérieure et la combinaison `priorite-sht45` ;
- 5 minutes toutes les 60 minutes, et 13:00 pour la ventilation.

Le décompte des périodes de la ventilation et l'heure de la dernière aération ne sont pas enregistrés : ils repartent du démarrage (RG-ventilation-periodique). Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables.

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
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, les réglages de la ventilation (`ventilation`), l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45 |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide`. `ventilation` : objet partiel `{"duree":…,"periode":…,"heure":"HH:MM"}`, durée et période en minutes entières |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

`ventilation` publie les trois réglages en place de RG-ventilation-periodique, `{"duree":…,"periode":…,"heure":"HH:MM"}`, durée et période en minutes entières. Ce que fait le ventilateur à l'instant se lit dans `sorties.ventilateur`.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…],"ventilation":{"duree":[min,max],"periode":[min,max]}}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. `ventilation.duree` et `ventilation.periode` sont les intervalles admis, bornes comprises, en minutes entières ; la durée doit rester strictement sous la période. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`. Une commande `ventilation` hors bornes, mal formée, ou qui laisserait la durée au moins égale à la période, l'est avec la raison `ventilation invalide`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité, le rôle des sondes ni la ventilation à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série ;
- les réglages de la ventilation se lisent dans le même message que l'état du ventilateur qu'ils expliquent.

### ADR-heure-par-ntp

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Il se synchronise dès que le Wi-Fi est joint après un démarrage, puis une fois par jour. L'heure est tenue pour connue dès la première synchronisation depuis le démarrage, puis avance sur l'horloge interne de l'ESP32 même si le réseau tombe ; elle se perd à chaque redémarrage. Elle est lue dans un fuseau horaire réglable, écrit comme une chaîne POSIX TZ ; par défaut celui de Paris, heure d'été comprise (`CET-1CEST,M3.5.0,M10.5.0/3`) — décision `05-fuseau`. En dépendent aujourd'hui le chauffage du mode `PLAGES`, qui ne descend jamais au plancher hors plage sur une heure inconnue (RG-chauffage-par-plages), et l'aération quotidienne du mode `HIBERNATION`, qui retombe sur un décompte de 24 heures tant que l'heure n'est pas connue (RG-ventilation-periodique). Les cycles de ventilation d'`ACTIF` et de `PLAGES` se comptent en durée écoulée, sans l'heure. Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC (2026-001), et le Wi-Fi est déjà là pour la supervision (2026-002).
