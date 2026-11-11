---
id: 2026-014
titre: Garder l'historique des mesures sur ssk-it-01, et en publier des résumés sur le courtier pour que l'application le montre
domaines: [supervision, securite]
liens:
  - { tag: piste, nom: '#18', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/issues/18' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-001', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-002', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-009', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-011', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-011' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-001', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-001' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-005', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-005' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-007', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-007' }
  - { tag: pull_request, nom: 'sterrarium-cadrage#14', url: 'https://github.com/sskorupski/sterrarium-cadrage/pull/14' }
  - { tag: issue_github, nom: 'ssk-it-infra#51', url: 'https://github.com/ssk-it/ssk-it-infra/issues/51' }
  - { tag: pull_request, nom: 'ssk-it-infra#52', url: 'https://github.com/ssk-it/ssk-it-infra/pull/52' }
  - { tag: issue_github, nom: 'sterrarium#23', url: 'https://github.com/sskorupski/sterrarium/issues/23' }
impacts:
  - { regle: RG-historique-des-mesures, operation: cree }
  - { regle: RG-resumes-de-l-historique, operation: cree }
  - { adr: ADR-historique-victoriametrics, operation: cree }
  - { adr: ADR-courtier-mosquitto-sur-ssk-it-01, operation: modifie }
  - { regle: RG-courtier-authentifie, operation: modifie }
  - { regle: RG-topics-mqtt, operation: touche }
  - { regle: RG-mesures-periodiques, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { regle: RG-sondes-d-air, operation: touche }
  - { adr: ADR-supervision-par-mqtt-tls, operation: touche }
---

## Objectif

Le régulateur publie son état toutes les 30 secondes, et le courtier n'en retient que le dernier. Ce que le bac a vécu la nuit dernière, la semaine passée ou l'hiver précédent ne se lit nulle part dans l'application : on ne sait pas s'il est resté au chaud pendant le gel, combien d'heures le chauffage a tourné, ni si une sonde décroche chaque nuit avant de se taire. L'objectif O5 de 2026-001 demande un « historique », et la piste [#18](https://github.com/ssk-it/ssk-terrarium-cadrage/issues/18) le range dans la phase 5.

Un historique tourne pourtant déjà sur ssk-it-01, depuis le 9 novembre 2026, sans qu'aucun cadrage l'ait décidé, et contre la décision d'architecture en vigueur. Les alertes de 2026-009 s'appuient dessus. Le référentiel doit dire qu'il existe, ce qu'il garde, et pourquoi la raison qui l'avait écarté ne tient plus.

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| H1 | Comparer une nuit, une semaine, deux hivers | Les mesures de chaque régulateur sont gardées cinq ans |
| H2 | Lire l'historique depuis l'application, sur ses trois cibles, hors du cluster | sterrarium montre les 24 dernières heures, les 7 et 30 derniers jours et l'année, sans redirection de port |
| H3 | N'ouvrir rien de plus qu'il ne faut | Ni secret de plus dans l'application, ni entrée publique de plus sur le cluster, ni compte qui puisse commander le régulateur |
| H4 | Qu'une mesure absente reste absente | Une mesure rejetée n'est jamais écrite à zéro ni comblée, dans la base comme dans ce que lit l'application |
| H5 | Ne rien changer à la régulation | Le régulateur n'en sait rien ; la panne de l'historique ne touche que l'historique |

### Ce que le référentiel disait déjà

- **ADR-courtier-mosquitto-sur-ssk-it-01** : « Le courtier est un Mosquitto seul, déployé sur le cluster ssk-it-01 par le dépôt `ssk-it/ssk-it-infra`, sans volume ni historique. » La décision `03-hebergement-du-courtier` de [ssk-terrarium-cadrage#2026-002](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002) a écarté l'option `mosquitto-et-historique` : « avance la phase 5 ; une base et un tableau de bord avec volume, plusieurs centaines de mégaoctets sur un nœud de production partagé ». Ce qui avait tranché : « réutiliser l'entrée, les certificats et les secrets du cluster existant, sans rien y ajouter que le courtier lui-même — ni port, ni Load Balancer ».
- La feuille de route de [ssk-terrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001) et la piste #18 annonçaient « InfluxDB + Grafana ». Ce n'était pas une décision : aucune option n'y était pesée.
- **Ce qui est déployé** (ssk-it-infra `f156d56`, `42f9052`, `fc21f9b`, `88768da`, du 9 novembre 2026), dans l'espace de noms `historique` :
  - VictoriaMetrics v1.154.1 en un seul nœud, cinq ans de conservation, un volume de 1 Gio, 48 Mio de mémoire demandés et 192 Mio au plus ;
  - Telegraf 1.40.2, sans état, 32 et 128 Mio, abonné à `ssk-terrarium/+/state` sous un compte `historique` qui ne lit que cela, sur l'écouteur interne du courtier ;
  - un script `etat.star` qui garde 14 valeurs numériques de l'état : l'air retenu, le substrat, les quatre sorties, la consigne, l'hystérésis, quatre booléens à 1 ou 0, et `uptime_s`. Une mesure à `null` est omise, jamais écrite à 0. Les chaînes ne sont pas des séries ;
  - ni Ingress ni Grafana : vmui, l'interface de VictoriaMetrics, s'ouvre par une redirection de port, avec un tableau de bord `tableaux/terrarium.json`.
- Ce que l'historique déployé ne garde pas : la mesure de chaque sonde d'air (`sondes.<nom>`). Seule la mesure retenue pour réguler l'est. La température de la sonde extérieure, celle du garage, n'est donc pas gardée.
- [ssk-terrarium-cadrage#2026-009](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009), en cours, « s'appuie sur cet historique tel qu'il est déployé, et le dit, sans le cadrer à la place de la piste #18 ». Il y ajoute vmalert, Alertmanager et ntfy, et fait historiser le mode, `mise_en_securite.air`, `sondes.<nom>.defaut` et le réglage des alertes. Ce cadrage-ci ne reprend pas ces ajouts : il les laisse à 2026-009, et cadre l'historique sur lequel les deux reposent.
- [ssk-terrarium-cadrage#2026-011](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-011), en cours, modifie aussi ADR-courtier-mosquitto-sur-ssk-it-01 et RG-courtier-authentifie, et 2026-012 cette dernière. Ce cadrage part des énoncés de `main` ; celui qui se livre après un autre reprend son texte. 2026-011 rappelle aussi qu'une entrée publique attire les scanners : le motif vaut pour toute exposition de VictoriaMetrics.
- RG-courtier-authentifie ne nomme ni le compte `sterrarium` de l'application ni le compte `historique`, que l'ACL du courtier connaît pourtant (`mosquitto/base/acl`). Elle dit aussi que le courtier « n'accepte que des connexions chiffrées par TLS », alors que Telegraf le joint en clair dans le cluster. Ce cadrage corrige ce retard.
- Côté application ([sterrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-001)), trois décisions pèsent contre une lecture HTTP de l'historique :
  - ADR-mqtt-sur-websocket : un seul adaptateur, en TypeScript, derrière un port « courtier », pour éviter « un second adaptateur, et un second jeu de tests » ;
  - l'option `passerelle-http`, écartée par la décision `02-transport-mqtt` : « un service à écrire, déployer et sécuriser » ;
  - la décision `05-mot-de-passe`, qui écarte un secret compilé dans le site statique et un secret gardé par le navigateur.
  
  [sterrarium-cadrage#2026-005](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-005), en cours, écarte de même que l'application interroge Skaron en HTTP : « un secret de plus sur chaque appareil, dont la version web ne sait pas garder », « un client HTTP de plus », et « ouvrir le CORS ». La décision `02-lecture-hors-du-cluster` pèse chacun de ces motifs.
- La vue Historique de l'application se cadre dans [sterrarium-cadrage#2026-007](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-007), à partir du contrat que fixe ce cadrage.

### Ce que la réalisation a appris

Ces constats ont été relevés sur ssk-it-infra#52, le 11 novembre 2026, sur un banc Docker aux versions du dépôt, avec 400 jours d'états injectés :

- `query_range` n'aligne pas ses fenêtres sur le pas : elles partent de l'heure de la requête. Une sous-requête (`(…)[25h:5m]`) les aligne sur les multiples du pas, en temps universel, et c'est elle que Telegraf demande ;
- une fenêtre d'un pas explicite (`[1i]`) ne comble pas un trou : une fenêtre sans point est absente de la réponse. Sans fenêtre explicite, VictoriaMetrics prolonge une série par-dessus un point manquant ;
- Telegraf publie un résumé en un seul message retenu, par une sortie MQTT au sérialiseur `template`, sans service écrit : la réserve de la décision `02-lecture-hors-du-cluster` est levée ;
- un résumé pèse de 50 à 66 Ko, et non 100.

## Parcours utilisateur

1. Le régulateur publie son état toutes les 30 s. Telegraf le reçoit, et en écrit les valeurs numériques dans VictoriaMetrics, y compris celles de chaque sonde d'air.
2. Toutes les 5 minutes, Telegraf demande à VictoriaMetrics, pour chaque régulateur, le résumé des quatre périodes : 24 heures, 7 jours, 30 jours, un an. Il publie chaque résumé, retenu, sur `ssk-terrarium/<id>/historique/<periode>`.
3. Le propriétaire ouvre la page Historique de sterrarium. L'application s'abonne aux résumés du régulateur ouvert, et le courtier lui remet aussitôt ceux qu'il retient : les courbes s'affichent sans attendre.
4. Une nuit, la SHT45 est rejetée pendant 20 minutes. Dans le résumé des 24 heures, quatre fenêtres de 5 minutes n'ont aucune mesure de cette sonde : elles valent `null`, et sa courbe y a un trou. Le nombre d'états reçus montre que le régulateur parlait : c'est un rejet, et non un silence.
5. Le Wi-Fi de la maison tombe trois heures. Les fenêtres de ces trois heures ne comptent aucun état, et toutes les séries y valent `null`.
6. VictoriaMetrics redémarre. Telegraf garde en tampon ce qu'il n'a pas pu écrire, quelques heures au plus. Pendant l'arrêt, les résumés ne sont pas recalculés : le dernier retenu reste, avec l'heure de son calcul, et l'application le dit ancien. Si le courtier redémarre, il perd les résumés retenus, qui reviennent dans les 5 minutes.
7. L'administrateur veut une période libre, ou le détail d'une minute : il ouvre vmui par une redirection de port, comme aujourd'hui. Ce n'est pas un parcours de l'application.

## Énoncés

### RG-historique-des-mesures

L'état que chaque régulateur publie sur `state` (RG-topics-mqtt) est historisé sur le cluster ssk-it-01, et gardé cinq ans. Au-delà, ses points s'effacent.

Telegraf lit l'état sous le compte `historique`, qui ne peut rien commander (RG-courtier-authentifie). Il en écrit les valeurs numériques dans VictoriaMetrics, une série par champ et par régulateur, `terrarium_<champ>{id="<MAC>"}` :

- la température et l'humidité de l'air retenues pour réguler, et la température du substrat ;
- la température et l'humidité de chaque sonde d'air, sous le nom que l'état publie, dans `terrarium_sonde_temperature{id, sonde}` et `terrarium_sonde_humidite{id, sonde}`. Le nom vient de l'état, et aucune liste de sondes n'est figée : une sonde que l'historique ne connaît pas encore y entre d'elle-même. Le rôle d'une sonde n'est pas une étiquette de sa série : changer son rôle ne coupe pas sa courbe en deux ;
- l'état de chaque sortie, à 1 quand elle est allumée et à 0 sinon ;
- la consigne et l'hystérésis ;
- le défaut capteur, la pause de chauffe, l'heure connue et la plage en cours, à 1 ou 0 ;
- le temps depuis le démarrage ;
- et ce que les alertes demandent en plus ([ssk-terrarium-cadrage#2026-009](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009)).

Une mesure publiée à `null` n'écrit aucun point : elle n'est jamais écrite à zéro, ni remplacée par la dernière valeur connue. Les chaînes — version, plages, fuseau — et les bornes ne sont pas des séries : elles restent dans l'état retenu.

L'historique ne s'écrit que depuis l'état publié. Le régulateur n'en sait rien et ne l'attend jamais. Une panne de Telegraf ou de VictoriaMetrics ne change rien à la régulation (RG-regulation-sans-reseau). Ce que Telegraf n'a pas encore écrit quand il s'arrête est perdu : l'historique a alors un trou, et la régulation aucun.

VictoriaMetrics n'est joignable que dans le cluster : aucun nom, aucune entrée HTTPS ne l'expose. Hors du cluster, l'historique se lit par ses résumés sur le courtier (RG-resumes-de-l-historique). vmui s'ouvre par une redirection de port, pour qui administre le cluster.

Ce que la règle protège :

- on compare cette nuit à la semaine dernière, et cet hiver au précédent ;
- une sonde qui décroche chaque nuit se voit dans l'historique, avant de se voir dans l'élevage ;
- la température du garage, que mesure la sonde extérieure, se garde avec celle du bac ;
- un trou reste un trou : personne ne lit une température que rien n'a mesurée ;
- la base qui garde cinq ans de mesures n'est pas une entrée de plus offerte aux scanners.

### RG-resumes-de-l-historique

Toutes les 5 minutes, la supervision publie sur le courtier les résumés de chaque régulateur dont l'historique garde un état dans les 365 derniers jours. Il y a un résumé par période, retenu, sur `ssk-terrarium/<id>/historique/<periode>`. Les quatre périodes sont publiées, même vides, pour chaque régulateur qui a un état dans une journée close de l'année. Un régulateur tout neuf n'a d'abord que les périodes dont une fenêtre est close, et son résumé `1an` arrive après sa première journée close.

| `<periode>` | Ce qu'elle couvre | Pas d'une fenêtre | Fenêtres |
| --- | --- | --- | --- |
| `24h` | les 24 dernières heures | 5 minutes | 288 |
| `7j` | les 7 derniers jours | 30 minutes | 336 |
| `30j` | les 30 derniers jours | 2 heures | 360 |
| `1an` | les 365 derniers jours | 1 jour | 365 |

Un résumé est un objet JSON. Ses champs :

- `periode`, `pas_s` (le pas en secondes), `debut` et `fin` (en UTC), et `calcule_le`, l'heure de son calcul ;
- `etats`, le nombre d'états reçus dans chaque fenêtre ;
- `air.temperature`, `air.humidite`, `substrat.temperature`, `consigne`, et `sondes.<nom>.temperature` et `sondes.<nom>.humidite` pour chaque sonde, chacun sous la forme `{"moy":[…],"min":[…],"max":[…],"n":[…]}` ;
- `sorties.chauffage`, `sorties.eclairage`, `sorties.pompe` et `sorties.ventilateur`, chacun un tableau.

Un exemple, réduit ici à quatre fenêtres et à deux champs :

```json
{
  "periode": "24h",
  "pas_s": 300,
  "debut": "2026-11-10T14:05:00Z",
  "fin": "2026-11-10T14:25:00Z",
  "calcule_le": "2026-11-10T14:27:12Z",
  "etats": [10, 10, 9, 0],
  "air": {
    "temperature": { "moy": [18.9, 19.0, 18.8, null], "min": [18.7, 18.8, 18.6, null], "max": [19.1, 19.2, 19.0, null], "n": [10, 10, 9, 0] }
  },
  "sorties": { "chauffage": [0.4, 0.6, 0.33, null] }
}
```

Chaque tableau a une case par fenêtre, dans l'ordre. La fenêtre `i` va de `debut + i × pas_s`, exclu, à `debut + (i + 1) × pas_s`, inclus : c'est le sens des fenêtres de VictoriaMetrics. Les fenêtres sont alignées sur le pas, en temps universel : une fenêtre d'un jour va de minuit à minuit UTC. `fin` est la fin de la dernière fenêtre close. La fenêtre en cours n'est jamais résumée : le résumé `1an` a donc jusqu'à un jour de retard, et celui des 24 heures jusqu'à 5 minutes.

Dans chaque fenêtre :

- `etats` compte les états reçus du régulateur. Un état arrive toutes les 30 s : une fenêtre de 5 minutes en attend 10 ;
- une mesure a sa moyenne (`moy`), son minimum, son maximum et le nombre de mesures acceptées (`n`). Une fenêtre sans aucune mesure acceptée vaut `null` dans les trois premiers, et 0 dans `n`. Elle ne vaut jamais 0, ni la valeur d'une fenêtre voisine. Une fenêtre où une partie des mesures manque résume celles qui existent, et `n` dit combien ;
- une sortie vaut la part des états reçus où elle était allumée, de 0 à 1, et `null` quand aucun état n'est reçu.

Une série que le régulateur ne publie pas est absente du résumé, et non remplie de `null`. C'est le cas d'un substrat sans sonde, ou des sondes d'un firmware qui ne publie pas `sondes`. Les noms des sondes sont ceux de l'historique (RG-historique-des-mesures).

Un résumé est republié toutes les 5 minutes, même inchangé : son `calcule_le` dit que la supervision vit. Le courtier, sans volume, le perd à son redémarrage, et il revient à la publication suivante. Un résumé pèse de 50 à 70 Ko, avec deux sondes.

Les résumés sont publiés par l'historique, sous le compte `historique`, qui ne peut publier que sur `ssk-terrarium/+/historique/#` (RG-courtier-authentifie). Le régulateur ne lit pas ces sujets. L'application les lit sous son compte `sterrarium`, qui lit déjà tout `ssk-terrarium/#`. Ni sujet ni format ne change ce que le régulateur publie (RG-topics-mqtt).

Ce que la règle protège :

- l'application lit l'historique par le seul courtier, son seul adaptateur et son seul compte : aucun secret, aucun client HTTP, aucune origine à ouvrir de plus (décision `02-lecture-hors-du-cluster`) ;
- une fenêtre sans mesure se lit comme telle à toutes les échelles, sans dépendre de la façon dont un client interrogerait la base ;
- un silence du régulateur se distingue d'un rejet de mesure ;
- une nuit froide ne disparaît pas dans la moyenne d'un mois, puisque chaque fenêtre garde son minimum et son maximum ;
- un résumé ancien se reconnaît à l'heure de son calcul.

### ADR-historique-victoriametrics

L'historique tient dans l'espace de noms `historique` de ssk-it-01, déployé par ssk-it-infra (`historique/`). Il se compose de deux composants configurés, et d'aucun service écrit :

- **VictoriaMetrics**, en un seul nœud, sur un volume, qui garde cinq ans (`-retentionPeriod=5y`) et n'est joignable que par son Service dans le cluster ;
- **Telegraf**, sans état. Il s'abonne à `ssk-terrarium/+/state` sur l'écouteur interne du courtier, sans passer par Traefik, et en écrit les valeurs numériques dans VictoriaMetrics par le protocole InfluxDB. Toutes les 5 minutes, il interroge VictoriaMetrics sur `/api/v1/query_range`, dans le cluster, et publie les résumés de RG-resumes-de-l-historique.

Deux scripts Starlark de Telegraf mettent en forme l'état reçu et les résumés publiés : c'est le seul code de l'historique. Ni Grafana, ni InfluxDB, ni Ingress. vmui suffit à l'administrateur, par une redirection de port.

Ce qui a tranché :

- VictoriaMetrics est un seul binaire, interface comprise. Il tient en quelques dizaines de Mio de mémoire : 48 Mio demandés et 192 Mio au plus, et 32 et 128 Mio pour Telegraf. Sur le disque, il prend quelques dizaines de Mio par an pour une vingtaine de séries à un point toutes les 30 s. Le motif qui avait écarté un historique en 2026-002/03, « plusieurs centaines de mégaoctets sur un nœud de production partagé », ne tient pas à ces mesures — décision `01-regulariser-l-historique`.
- Hors du cluster, l'historique ne se lit que par ses résumés, publiés sur le courtier que tout client du terrarium joint déjà — décision `02-lecture-hors-du-cluster`.

Ce que l'architecture ne couvre pas :

- aucune sauvegarde du volume n'est décidée ici : perdre le volume perd l'historique, jamais la régulation ;
- l'application ne choisit ni sa période ni son pas : elle lit les quatre résumés publiés.

### ADR-courtier-mosquitto-sur-ssk-it-01

Le courtier est un Mosquitto seul, déployé sur le cluster ssk-it-01 par le dépôt `ssk-it/ssk-it-infra`, sans volume : il ne garde que des messages retenus, perdus à son redémarrage. L'historique des mesures vit à côté de lui, dans son propre espace de noms, et non dans le courtier (ADR-historique-victoriametrics).

Il est joint à `mq.ssk-it.fr`, sur le port 443 : un routeur TCP du Traefik existant prend sur l'entrée `websecure` les connexions qui demandent ce nom dans leur poignée de main (SNI), y termine le TLS avec un certificat cert-manager, et passe le flux à Mosquitto. Aucun port n'est ajouté au Load Balancer. Dans le cluster, l'historique le joint sur son écouteur interne, sans passer par Traefik.

Ce qui l'a décidé :

- le cluster existe déjà, avec son entrée publique, ses certificats et ses secrets scellés, et Mosquitto y tient dans quelques mégaoctets ; une machine au domicile aurait été une infrastructure de plus à tenir — décision `03-hebergement-du-courtier` de 2026-002 ;
- l'historique se garde à côté du courtier, qui reste sans volume — décision `01-regulariser-l-historique` de 2026-014.

### RG-courtier-authentifie

Depuis Internet, le courtier n'accepte que des connexions chiffrées par TLS et authentifiées par un compte. Dans le cluster, l'historique le joint sur son écouteur interne, sans TLS, mais sous son compte. Aucun compte anonyme.

Les droits des comptes :

- le compte du régulateur ne peut publier que sur `state`, `event` et `status` de son préfixe, et ne lire que ses `cmd/#` ;
- le compte du propriétaire peut lire tout `ssk-terrarium/#` et publier sur les `cmd/#` ;
- le compte `sterrarium`, celui de l'application, a les mêmes droits que celui du propriétaire, sous son propre nom (RG-compte-dedie de sterrarium-cadrage) ;
- le compte `historique` ne peut lire que les `state`, et ne publier que sur les `historique/#` des régulateurs (RG-resumes-de-l-historique).

Les mots de passe n'existent que scellés dans `ssk-it-infra`, et chez le client qui s'en sert : le régulateur, le coffre de l'application, le Secret de Telegraf.

Ce que la règle protège :

- le courtier est joignable depuis Internet : sans compte, personne ne lit ni ne commande le régulateur ;
- le régulateur lui-même ne peut pas se donner d'ordre ;
- l'historique, qui publie ses résumés, ne peut ni commander le régulateur, ni contrefaire son état.
