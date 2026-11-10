---
id: 2026-007
titre: Une seconde sonde d'air, intérieure ou extérieure au choix, qui prend le relais de l'autre
domaines: [materiel, regulation, securite, supervision]
liens:
  - { tag: issue_github, nom: 'ssk-terrarium#22', url: 'https://github.com/sskorupski/ssk-terrarium/issues/22' }
  - { tag: issue_github, nom: 'sterrarium#15', url: 'https://github.com/sskorupski/sterrarium/issues/15' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-006', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-006' }
impacts:
  - { regle: RG-sondes-d-air, operation: cree }
  - { adr: ADR-capteur-air-sht45, operation: modifie }
  - { regle: RG-capteur-en-defaut, operation: modifie }
  - { regle: RG-mesures-periodiques, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-brochage, operation: modifie }
  - { regle: RG-chauffage-par-hysteresis, operation: touche }
  - { regle: RG-chauffage-par-plages, operation: touche }
  - { regle: RG-sorties-par-mode, operation: touche }
  - { regle: RG-chauffe-continue-bornee, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
---

## Objectif

Le régulateur n'a qu'une sonde d'air, la SHT45. Le 9 novembre 2026, une humidité impossible de 102 % (2026-006) l'a mise en défaut : le chauffage a été coupé et le terrarium a refroidi jusqu'à 15,2 °C, sans aucune autre mesure pour prendre le relais. Une seule sonde est un point de défaillance unique : quand elle tombe, le régulateur n'a plus que le choix entre se mettre en sécurité, et laisser l'élevage refroidir, ou chauffer à l'aveugle (2026-006, décision `03-lever-la-mise-en-securite`).

Le propriétaire a récupéré un module DHT11 (KY-015), qui mesure lui aussi la température et l'humidité. Il veut en faire une seconde sonde d'air, et pouvoir choisir depuis l'application le rôle de chaque sonde :

- **intérieure** : la sonde mesure l'air du bac et sert à la régulation ;
- **extérieure** : la sonde mesure l'air du garage, et sa mesure est seulement publiée.

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| D1 | La panne d'une sonde intérieure ne met pas l'élevage en danger quand l'autre fonctionne | Deux sondes intérieures, l'une rejetée : la régulation continue sur l'autre, sans mise en sécurité |
| D2 | Le rôle des sondes se change sans toucher au câblage ni au firmware | Rôles et combinaison se règlent par `cmd/config` et par la liaison série, et sont conservés après une coupure |
| D3 | Le régulateur n'est jamais sans sonde pour réguler | Un réglage qui ne laisserait aucune sonde intérieure est refusé en entier |
| D4 | La sonde qui décide se voit | `state` publie chaque sonde, son rôle, son état, et la mesure retenue pour réguler |
| D5 | Sans réglage, rien ne change | Par défaut, la SHT45 est seule intérieure, le DHT11 est extérieur : la régulation reste celle d'aujourd'hui |

### Ce que le référentiel disait déjà

- **ADR-capteur-air-sht45** et la décision `03-capteur-air` de 2026-001 : l'air du bac est mesuré par une SHT45. Le DHT22 a été écarté parce qu'il dérive au-dessus de 80 % HR, là où vit le bac, et que son protocole propriétaire est peu fiable sur un câble long. Le DHT11 a le même protocole, et une précision moindre. Ce cadrage fait évoluer l'ADR à la demande du propriétaire (décision `01-role-des-sondes`) : la SHT45 reste la sonde de référence, celle que retient la configuration par défaut, mais le DHT11 peut être déclaré intérieur.
- **RG-capteur-en-defaut**, dans l'énoncé que lui donne 2026-006 : le rejet d'une mesure, sa cause, le délai de 2 minutes, la mise en sécurité désactivable. Ces règles s'appliquent désormais à chaque sonde, et la mise en sécurité porte sur l'ensemble des sondes intérieures.
- La décision `01-combinaison-air-substrat` de 2026-005 a écarté « deux déclencheurs pour une seule sortie » : il faut que ce que fait le chauffage se lise sur une seule mesure. Ce cadrage la respecte (décision `02-combinaison-des-sondes`) : quelle que soit la combinaison choisie, le régulateur calcule **une** mesure de l'air, publiée dans `state` comme aujourd'hui, et c'est elle seule qui décide.
- La décision `03-sonde-muette` de 2026-005 voulait déjà qu'une sonde optionnelle ne puisse pas empêcher le hors-gel. Le basculement d'une sonde intérieure sur l'autre va dans le même sens.
- **RG-reglages-bornes** dit que la coupure sur capteur en défaut n'est pas un réglage, alors que 2026-006 la rend désactivable par commande sans citer cette règle dans ses impacts. Ce cadrage, livré après 2026-006, lève la contradiction dans l'énoncé de RG-reglages-bornes : la désactivation est l'exception que RG-capteur-en-defaut prévoit, le délai de 2 minutes et les plages de rejet restent hors réglage.
- **RG-topics-mqtt** : 2026-006 ajoute `cause_mesure_air` et `mise_en_securite`, mais son énoncé ne reprend pas `coupure_substrat`, que 2026-005 a ajouté et livré. L'énoncé ci-dessous porte les deux.
- **RG-brochage** n'avait aucune broche pour une seconde sonde. Le DHT11 prend GPIO 13 (décision `04-brochage-et-bibliotheque`).
- **RG-regulation-sans-reseau** : le rôle des sondes et la combinaison sont enregistrés sur le régulateur. Une fois réglés, ils ne dépendent plus du réseau.
- La brumisation (phase 4) n'est pas encore câblée : la pompe reste coupée en phase 1. La décision `03-brumisation-sur-la-mesure-retenue` dit ce qu'elle fera quand elle le sera.
- Cadrage en cours : 2026-006, sur sa branche. Le code de son côté firmware est fusionné (ssk-terrarium#21). Ce cadrage part de ses énoncés et se livre après lui.

## Parcours utilisateur

1. Le propriétaire câble le DHT11 sur GPIO 13 et téléverse le firmware. Au démarrage, la liaison série annonce les deux sondes et leur rôle : `SONDES sht45=interieure dht11=exterieure combinaison=priorite-sht45`. Le DHT11 est extérieur par défaut : la régulation est celle d'aujourd'hui, et `state` publie aussi sa mesure dans `sondes.dht11`.
2. Dans l'application, il déclare le DHT11 intérieur. L'application publie `{"sondes":{"dht11":"interieure"}}` sur `cmd/config`. Le régulateur l'accepte, l'enregistre, et répond sur `event`. À la mesure suivante, `state` publie `sondes.dht11.role` à `interieure`. Avec la combinaison `priorite-sht45`, c'est toujours la SHT45 qui décide : `sonde_retenue` vaut `sht45`.
3. La SHT45 rend 102 % d'humidité. Sa mesure est rejetée (`sondes.sht45.cause` = `humidite-hors-plage`). Dès cette mesure, la régulation passe sur le DHT11 : `air` publie la mesure du DHT11, et `sonde_retenue` passe à `dht11`. Il n'y a ni délai de tolérance ni mise en sécurité, et `defaut_capteur` reste à `false`.
4. Passé 2 minutes de rejet, la SHT45 est en défaut. Ce défaut est signalé sans couper la régulation : `sondes.sht45.defaut` passe à `true`, la LED d'état s'allume, et la liaison série écrit `DEFAUT sonde sht45, regulation sur dht11`. Le propriétaire sait ainsi qu'il régule sur la sonde la moins précise.
5. La SHT45 sèche. Dès qu'elle rend une mesure acceptée, elle reprend la main : `sonde_retenue` revient à `sht45`, la LED s'éteint, et la liaison série écrit `REPRISE sonde sht45`.
6. Si les deux sondes intérieures sont rejetées en même temps, on retrouve le comportement d'aujourd'hui : les sorties gardent leur état pendant 2 minutes, puis chauffage et pompe sont coupés. `defaut_capteur` passe alors à `true`, sauf si la mise en sécurité est désactivée (RG-capteur-en-defaut).
7. Le propriétaire choisit la combinaison `moyenne`. Les deux sondes valides, la régulation porte sur la moyenne de leurs températures et la moyenne de leurs humidités, et `sonde_retenue` vaut `moyenne`. Si l'une est rejetée, la régulation porte sur l'autre seule.
8. Il tente de déclarer les deux sondes extérieures. Le régulateur refuse la commande en entier et répond sur `event` : `aucune sonde interieure`. Rien ne change.
9. Il déclare la SHT45 extérieure et le DHT11 intérieur. Le régulateur l'accepte : le DHT11 régule seul, avec ses limites (ADR-capteur-air-sht45). Si le DHT11 tombe, la SHT45 ne prend pas le relais, puisqu'elle est extérieure : c'est la mise en sécurité qui s'applique.

## Énoncés

### RG-sondes-d-air

Le régulateur a deux sondes d'air, nommées par leur composant : `sht45`, sur le bus I²C, et `dht11`, sur sa propre broche (RG-brochage). Le DHT11 est facultatif : son absence se traite comme une sonde muette.

Chaque sonde a un rôle : `interieure`, quand elle mesure l'air du bac et sert à la régulation, ou `exterieure`, quand elle mesure l'air du garage et que sa mesure est seulement publiée. Au moins une sonde est intérieure. Par défaut, `sht45` est intérieure et `dht11` extérieure.

La **mesure de l'air** que les autres règles emploient est une seule mesure, température et humidité, calculée à chaque relevé à partir des seules sondes intérieures dont la mesure est acceptée (RG-capteur-en-defaut), selon la combinaison réglée :

| Combinaison | Mesure de l'air |
| --- | --- |
| `priorite-sht45` (par défaut) | celle de `sht45` si elle est acceptée, sinon celle de `dht11` |
| `priorite-dht11` | celle de `dht11` si elle est acceptée, sinon celle de `sht45` |
| `moyenne` | la moyenne des températures et la moyenne des humidités des sondes acceptées |
| `plus-froide` | celle de la sonde acceptée la plus froide, température et humidité ensemble |

Une combinaison ne joue qu'entre sondes intérieures : une sonde extérieure n'entre dans aucune. Quand une seule sonde intérieure est acceptée, la mesure de l'air est la sienne, quelle que soit la combinaison. Quand aucune ne l'est, il n'y a pas de mesure de l'air, et RG-capteur-en-defaut s'applique. Le passage d'une sonde à l'autre se fait à la mesure qui le provoque. Il ne remet pas à zéro l'état de l'hystérésis, ni le compte de la chauffe continue.

Le rôle de chaque sonde et la combinaison se règlent par `cmd/config` (RG-topics-mqtt) et par la liaison série, dans les bornes de RG-reglages-bornes. Ils s'enregistrent en mémoire non volatile (RG-mode-au-demarrage).

Ce que la règle protège : la panne d'une sonde ne coupe plus le chauffage quand une autre peut prendre le relais, et la régulation porte toujours sur une seule mesure, publiée, qui dit à elle seule ce que fait le chauffage (2026-005, décision `01-combinaison-air-substrat`). Déclarer le DHT11 intérieur, ou le retenir en priorité, fait réguler sur une sonde moins précise que la SHT45 : c'est un choix du propriétaire, fait en connaissance de cause (ADR-capteur-air-sht45).

### ADR-capteur-air-sht45

La température et l'humidité de l'air du bac sont mesurées par une Sensirion SHT45 munie d'une membrane PTFE, sur le bus I²C : c'est la sonde de référence, la seule intérieure par défaut. Le choix vient de la décision `03-capteur-air` de 2026-001 : le bac vit entre 75 et 90 % HR, plage où le DHT22 dérive et où une BME280, sans membrane, sature.

Un DHT11 (module KY-015) peut s'y ajouter en seconde sonde d'air, sur sa propre broche, avec un rôle intérieur ou extérieur qui se règle (RG-sondes-d-air). Déclaré intérieur, il peut régler le chauffage et, une fois la brumisation câblée, la pompe, avec ses limites :

- son humidité n'est garantie que de 20 à 90 % HR, à ±5 % ;
- sa température n'est garantie que de 0 à 50 °C, à ±2 °C, par pas de 1 °C ;
- son protocole propriétaire à un fil est sensible à la longueur du câble.

Le propriétaire a accepté ces limites le 2026-11-10 (2026-007, décisions `01-role-des-sondes` et `03-brumisation-sur-la-mesure-retenue`), pour qu'une panne de la SHT45 n'oblige plus à choisir entre refroidir et chauffer à l'aveugle.

### RG-capteur-en-defaut

Une mesure d'une sonde d'air est rejetée quand la sonde ne répond pas (muette), ou quand elle est impossible dans le terrarium : température hors de −20 à 60 °C, ou humidité relative hors de 0 à 100 %, bornes comprises, une valeur non numérique comptant comme hors plage. Température et humidité venant du même composant (ADR-capteur-air-sht45), une mesure rejetée l'est entière. La cause d'un rejet se dit par l'une de ces valeurs, la première qui s'applique : `muet`, `temperature-hors-plage`, `humidite-hors-plage`. Les mêmes plages valent pour les deux sondes : elles écartent ce qu'aucun terrarium ne peut connaître, non ce qu'un composant ne sait pas mesurer.

Une sonde dont les mesures sont rejetées pendant plus de 2 minutes est en défaut. Ce défaut de sonde est signalé sur la liaison série avec sa cause, et sur le courtier (RG-topics-mqtt). Pour une sonde intérieure, il est aussi signalé par la LED d'état. À lui seul, il ne coupe rien : tant qu'une autre sonde intérieure est acceptée, la régulation continue sur elle (RG-sondes-d-air).

La mise en sécurité porte sur l'air intérieur, c'est-à-dire sur l'ensemble des sondes intérieures. Elle est active par défaut. Active, elle déclare un défaut capteur quand aucune sonde intérieure n'a rendu de mesure acceptée depuis plus de 2 minutes : chauffage et pompe sont coupés, et le défaut est signalé par la LED d'état, sur la liaison série avec la cause de chaque sonde intérieure, et sur le courtier. L'alerte sur téléphone s'y ajoutera avec sa phase. Pendant ces 2 minutes, aucune décision nouvelle n'est prise sans mesure de l'air : les sorties gardent l'état décidé sur la dernière mesure de l'air. Une erreur passagère ne coupe donc rien. Les sorties ne reprennent que lorsqu'une sonde intérieure rend de nouveau une mesure acceptée.

La mise en sécurité se désactive et se réactive par commande (`cmd/config`, RG-topics-mqtt), et le choix est conservé en mémoire non volatile, au-delà d'une coupure de courant. Désactivée, aucun défaut capteur n'est déclaré : quand aucune sonde intérieure n'est acceptée, la régulation se poursuit sur la mesure rejetée de la sonde intérieure prioritaire, si elle en rend une. Quand toutes sont muettes, les sorties gardent la dernière décision prise, sans limite. La sonde prioritaire est celle que nomme une combinaison `priorite-…`, et la SHT45 pour `moyenne` et `plus-froide`, si elle est intérieure. Les rejets et les défauts de sonde restent signalés, LED d'état et liaison série comprises. La désactivation est elle-même signalée sur la liaison série au démarrage et publiée dans `state`, pour qu'aucun lecteur ne la croie active. La durée maximale de chauffe continue (RG-chauffe-continue-bornee) s'applique dans tous les cas.

Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle sans que son propriétaire l'ait décidé, et la panne d'une sonde ne le prive pas de régulation quand une autre la remplace. Celui qui le supervise sait, sans lire le code, quelle sonde a lâché, et s'il faut vérifier le câblage ou le capteur lui-même. Une mesure fausse mais plausible, d'une sonde décrochée dans un coin froid, n'est pas détectée (2026-001, décision 06). Avec deux sondes intérieures, elle peut l'emporter selon la combinaison : `plus-froide` retient une sonde décrochée dans un coin froid, et `moyenne` en retient la moitié de l'écart. Désactiver la mise en sécurité est un risque accepté par le propriétaire (2026-006, décision `03-lever-la-mise-en-securite`).

### RG-mesures-periodiques

Le régulateur relève chaque sonde d'air (RG-sondes-d-air), température et humidité, toutes les 30 secondes, et en déduit la mesure de l'air qui sert à la régulation. Une sonde extérieure est relevée et publiée de la même façon, mais n'entre pas dans la mesure de l'air. Le DHT11 est facultatif : son absence n'empêche pas la régulation, tant qu'une sonde intérieure est acceptée. Le régulateur mesure aussi la température du substrat côté chaud quand la sonde est présente ; son absence n'empêche pas la régulation de l'air. Quand elle est présente, la mesure du substrat peut couper le chauffage (RG-coupure-par-le-substrat).

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air et la combinaison des sondes intérieures sont réglables à distance et par la liaison série. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ;
- de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ;
- un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j` ;
- pour chaque sonde, le rôle `interieure` ou `exterieure`, avec au moins une sonde intérieure ;
- pour la combinaison, l'une des valeurs de RG-sondes-d-air.

Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Cela vaut aussi pour une commande qui, appliquée, ne laisserait aucune sonde intérieure. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile.

Ne sont pas des réglages, et aucune commande ne les modifie :

- le hors-gel de `HIBERNATION` (4-6 °C) ;
- le plancher hors plage de `PLAGES` (12-14 °C) ;
- les seuils de la coupure par le substrat (24 °C et 18,5 °C) ;
- la durée maximale de chauffe continue ;
- les plages de rejet d'une mesure et le délai de 2 minutes avant un défaut (RG-capteur-en-defaut) ;
- le chien de garde.

La mise en sécurité se désactive par commande, comme RG-capteur-en-defaut le prévoit, mais rien ne règle ce qu'elle fait quand elle est active.

Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni lever la coupure par le substrat, ni laisser le régulateur sans sonde pour réguler.

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau, rôles et combinaison ensemble — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis ;
- les plages `01:35-06:30` et `14:05-17:05` ;
- le fuseau de Paris ;
- `sht45` intérieure, `dht11` extérieure et la combinaison `priorite-sht45`.

Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables.

Ce que la règle protège :

- une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel ;
- un régulateur qui ne sait pas où il en est ne chauffe pas au hasard ;
- un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant ;
- des rôles illisibles ne laissent pas le régulateur sans sonde intérieure.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide` |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…]}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. Aucune commande ne règle ces bornes.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité ni le rôle des sondes à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent.

### RG-brochage

Le brochage de l'ESP32 est le suivant :

| Fonction | GPIO | Remarque |
| --- | --- | --- |
| I²C SDA (SHT45) | 21 | |
| I²C SCL | 22 | |
| 1-Wire DS18B20 | 4 | Pull-up 4,7 kΩ vers 3,3 V |
| Données DHT11 (KY-015) | 13 | Module alimenté en 3,3 V ; résistance de tirage du module |
| Relais chauffage | 26 | Coupé au démarrage |
| Relais LED | 27 | Coupé au démarrage |
| Relais pompe | 25 | Coupé au démarrage |
| Relais ventilateur | 33 | Coupé au démarrage |
| LED d'état | 2 | LED externe + 330 Ω : la KS5016 n'en a pas sur cette broche |

Le niveau logique « coupé » des quatre sorties de relais dépend du niveau de déclenchement du module, à vérifier (RG-relais-coupes-sans-commande).
