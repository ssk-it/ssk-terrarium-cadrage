---
id: 2026-008
titre: La SHT45 se chauffe pour sortir de la condensation
domaines: [materiel, regulation, supervision]
liens:
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-006', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-006' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-007', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-007' }
  - { tag: issue_github, nom: 'ssk-terrarium#24', url: 'https://github.com/sskorupski/ssk-terrarium/issues/24' }
impacts:
  - { regle: RG-chauffe-de-la-sht45, operation: cree }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { adr: ADR-capteur-air-sht45, operation: touche }
  - { regle: RG-mesures-periodiques, operation: touche }
  - { regle: RG-capteur-en-defaut, operation: touche }
  - { regle: RG-reglages-bornes, operation: touche }
  - { regle: RG-chien-de-garde, operation: touche }
---

## Objectif

Le 9 novembre 2026, la SHT45 a rendu 102 % d'humidité : trempée de condensation, elle mesurait l'eau posée sur elle, non l'air du bac. 2026-006 en traite les effets : la mesure est rejetée avec sa cause, `humidite-hors-plage`, et la mise en sécurité peut se désactiver. 2026-007 ajoute un DHT11 qui prend le relais pendant le rejet. Aucun des deux ne fait sortir la SHT45 de la condensation. Il faut toujours que quelqu'un vienne la sécher, et pendant ce temps le régulateur se passe de sa meilleure sonde.

Le bac vit entre 75 et 90 % HR, et les brumisations le portent plus haut encore. À ces humidités, l'eau se dépose sur la sonde dès que l'air la sature, même un court instant. La SHT45 a un chauffage intégré, que Sensirion prévoit pour ce cas : une impulsion de chauffe évapore l'eau déposée sur la puce et corrige la dérive que laisse une longue exposition à l'humidité.

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| H1 | La SHT45 sort d'elle-même de la condensation | Après une mesure à 95 % HR ou plus, ou à plus de 100 %, la sonde se chauffe sans intervention |
| H2 | La chauffe ne fausse aucune mesure retenue | Aucune mesure prise pendant la chauffe ou juste après n'entre dans la régulation ni dans `state` |
| H3 | La chauffe ne dérange pas la régulation | Pas de relevé supprimé, pas de bascule vers le DHT11, pas de décompte sur les 2 minutes de tolérance |
| H4 | La chauffe se voit | Chaque chauffe s'écrit sur la liaison série et se publie sur `event` |

### Ce que le référentiel disait déjà

- **ADR-capteur-air-sht45** et la décision `03-capteur-air` de 2026-001 : la SHT45 à membrane PTFE a été retenue parce que le DHT22 dérive au-dessus de 80 % HR et qu'une BME280 sans membrane sature. La nomenclature de 2026-001 dit déjà que la membrane ne protège que le capteur, et qu'il faut placer la carte loin de la buse. Ce cadrage complète ce choix sans le rouvrir : la chauffe s'ajoute à la parade physique, elle ne la remplace pas.
- **RG-capteur-en-defaut**, dans l'énoncé de 2026-007 : plages de rejet (0 à 100 % HR, bornes comprises), causes, délai de 2 minutes. Une mesure à 102 % reste rejetée : la chauffe n'y change rien. Le seuil de 95 % est dans la plage valide : la mesure qui déclenche la chauffe à ce seuil est acceptée, et sert à réguler comme les autres. La règle reconnaît aussi qu'une mesure fausse mais plausible n'est pas détectée. Une mesure prise sur une puce encore chaude en est une : température trop haute, humidité trop basse. C'est pourquoi ce cadrage place la chauffe entre deux relevés (décision `02-place-dans-le-cycle`), plutôt que de compter sur le rejet pour l'écarter.
- **RG-sondes-d-air** (créée par 2026-007) : une mesure écartée de la SHT45 fait passer la régulation sur le DHT11 dès cette mesure. Le propriétaire veut que la chauffe ne provoque pas cette bascule. Comme aucun relevé ne tombe pendant le cycle, aucune mesure n'est écartée, et la règle n'a pas à changer.
- **RG-mesures-periodiques** : un relevé toutes les 30 secondes. La chauffe se loge entre deux relevés, sans en décaler aucun.
- **RG-reglages-bornes** : le seuil, la durée, la puissance et l'intervalle minimal de la chauffe ne sont pas des réglages. Ce sont des constantes du firmware, comme les plages de rejet.
- **RG-chien-de-garde** : le chien de garde du firmware est réglé à 10 s. La chauffe de 1 s, plus sa mesure de fin, bloque la boucle environ 1,1 s, ce qui laisse de la marge.
- **RG-topics-mqtt** : `event` porte les changements de mode, les réglages et le démarrage. Ce cadrage y ajoute la chauffe de la sonde.
- Cadrages en cours : 2026-006 et 2026-007, sur leur branche. Ce cadrage part de leurs énoncés, en particulier de celui de RG-topics-mqtt dans 2026-007, et se livre après eux.
- La brumisation (phase 4) n'est pas encore câblée. Quand elle le sera, la chauffe suivra le plus souvent une impulsion de brumisation : rien n'est à décider pour elle aujourd'hui.

## Parcours utilisateur

1. Le régulateur relève la SHT45 : 96 % HR. La mesure est acceptée et sert à réguler, comme toute mesure dans la plage. Aucune chauffe n'a eu lieu depuis 5 minutes : juste après le relevé, la SHT45 chauffe 1 s à sa puissance la plus haute. La mesure qu'elle rend à la fin de la chauffe est jetée. La liaison série écrit `CHAUFFE sonde sht45 : humidite 96.0 %`, et `event` publie `{"evenement":"chauffe-sonde","sonde":"sht45","motif":"humidite-haute"}`.
2. Pendant les 29 secondes qui suivent, la puce refroidit. Aucun relevé n'est pris : les sorties gardent l'état décidé sur le relevé précédent, `state` publie toujours la mesure de ce relevé, et le DHT11 ne prend pas la main.
3. Le relevé suivant tombe à l'heure habituelle : la sonde est sèche, et rend 88 % HR. La régulation continue.
4. Si la sonde rend encore 96 %, la régulation l'emploie, mais aucune chauffe n'a lieu avant que 5 minutes se soient écoulées depuis la précédente. Un bac réellement saturé ne fait donc pas chauffer la puce en continu.
5. La SHT45 rend 102 %. La mesure est rejetée (`humidite-hors-plage`), comme le prévoit RG-capteur-en-defaut : si le DHT11 est intérieur, il prend la main pour ce relevé. Si aucune chauffe n'a eu lieu depuis 5 minutes, la sonde chauffe juste après, et `event` publie le motif `humidite-hors-plage`. La SHT45 reprend la main au relevé suivant, si elle est sèche.
6. Ça se passe mal : la sonde reste trempée après plusieurs chauffes. Les rejets s'accumulent, et au bout de 2 minutes la sonde passe en défaut (RG-capteur-en-defaut), le DHT11 régule ou la mise en sécurité s'applique. Les messages `chauffe-sonde` répétés toutes les 5 minutes disent au propriétaire que la chauffe ne suffit pas : il faut sécher la sonde ou l'éloigner de l'eau.
7. Ça se passe mal : la SHT45 ne répond pas à la commande de chauffe. La liaison série écrit l'erreur, rien n'est publié sur `event`, et l'intervalle de 5 minutes commence quand même : on ne relance pas une chauffe en échec à chaque relevé.

## Énoncés

### RG-chauffe-de-la-sht45

Juste après un relevé de la SHT45 (RG-mesures-periodiques), le régulateur chauffe la sonde quand ce relevé rend une humidité de 95 % HR ou plus, ou qu'il est rejeté pour `humidite-hors-plage` (RG-capteur-en-defaut), et qu'aucune chauffe n'a commencé depuis 5 minutes. La chauffe dure 1 seconde, à la plus haute puissance du chauffage intégré (200 mW). Elle s'applique quel que soit le rôle de la SHT45 (RG-sondes-d-air) et quel que soit le mode. Une sonde muette ne se chauffe pas.

La mesure que la sonde rend à la fin de la chauffe est jetée : elle n'entre ni dans la mesure de l'air, ni dans `state`, ni dans le décompte des rejets. Aucun relevé n'est pris pendant la chauffe : le relevé suivant tombe à l'heure habituelle, 30 secondes après celui qui l'a déclenchée, une fois la puce refroidie. Entre les deux, rien ne change de ce que la régulation a décidé : les sorties gardent l'état décidé sur le relevé précédent, aucune sonde ne prend le relais d'une autre, et le délai de 2 minutes de RG-capteur-en-defaut ne court pas plus vite.

Chaque chauffe s'écrit sur la liaison série, avec l'humidité du relevé qui l'a déclenchée, et se publie sur `event` avec son motif, `humidite-haute` (95 % HR ou plus) ou `humidite-hors-plage` (RG-topics-mqtt). Une chauffe que la sonde refuse s'écrit sur la liaison série, ne se publie pas, et compte pour l'intervalle de 5 minutes.

Le seuil de 95 % HR, la durée et la puissance de la chauffe, et l'intervalle de 5 minutes sont des constantes du firmware : aucune commande ne les règle (RG-reglages-bornes).

Ce que la règle protège : la SHT45 se débarrasse d'elle-même de la condensation qui la fait mesurer l'eau plutôt que l'air, sans que personne ait à venir la sécher. Aucune mesure faussée par la chaleur de la puce n'est lue comme une mesure de l'air. La chauffe n'occupe la sonde que 1 seconde toutes les 5 minutes au plus, bien sous les 10 % du temps que Sensirion fixe à son chauffage, et un bac réellement saturé ne la fait pas chauffer en continu. Les chauffes répétées se lisent sur `event` : le propriétaire sait quand la chauffe ne suffit plus et qu'il faut déplacer ou sécher la sonde.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45 |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide` |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…]}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité ni le rôle des sondes à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série.
