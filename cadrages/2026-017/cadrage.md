---
id: 2026-017
titre: 'La consigne de ventilation dans l''historique et ses résumés'
domaines: [supervision]
liens:
  - { tag: document, nom: 'sterrarium-cadrage#2026-013', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-013' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-014', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-014' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-015', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-015' }
  - { tag: issue_github, nom: 'ssk-it-infra#54', url: 'https://github.com/ssk-it/ssk-it-infra/issues/54' }
  - { tag: pull_request, nom: 'ssk-it-infra#55', url: 'https://github.com/ssk-it/ssk-it-infra/pull/55' }
impacts:
  - { regle: RG-historique-des-mesures, operation: modifie }
  - { regle: RG-resumes-de-l-historique, operation: modifie }
  - { regle: RG-ventilation-periodique, operation: touche }
  - { regle: RG-topics-mqtt, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
---

## Objectif

L'application sterrarium va montrer, dans le graphique Global de sa page Historique, la part du temps où le ventilateur a tourné en regard de celle que son rythme prévoyait ([sterrarium-cadrage#2026-013](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-013), décision `03-consigne-de-ventilation`). Le chauffage a sa consigne en degrés dans l'historique ; la ventilation n'en a pas. L'écart entre ce qui était prévu et ce qui a tourné dit les aérations de saturation : sans la part prévue, on ne sait pas si le ventilateur a tourné parce que le rythme le voulait, ou parce que l'air restait saturé.

Rien de cela n'est dans l'historique : le rythme, le moment de la journée et le mode sont dans l'état, mais l'historique ne garde que les valeurs numériques, et le mode est une chaîne. L'application ne recalcule rien des résumés (RG-historique-lu-dans-les-resumes, référentiel de sterrarium) : la valeur doit venir de la supervision.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| V1 | Lire ce que le rythme de ventilation prévoyait, fenêtre par fenêtre | Chaque résumé porte `consigne_ventilation`, juste quand un réglage ou le moment de la journée change dans la période |
| V2 | Comparer sans écart fictif | La part prévue et la part du ventilateur ont la même précision |
| V3 | Ne rien changer au régulateur | Aucune version du firmware : la valeur se tire de l'état déjà publié |

### Ce que le référentiel disait déjà

- **RG-historique-des-mesures** et **RG-resumes-de-l-historique** ([ssk-terrarium-cadrage#2026-014](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-014), livré le 12 novembre 2026) : l'historique garde les valeurs numériques de l'état, et les résumés en publient la moyenne, le minimum, le maximum et le nombre par fenêtre. Ce cadrage les modifie toutes deux. Il ne s'est pas glissé dans 2026-014 : son chantier était réalisé, et y ajouter un champ non encore réalisé en aurait bloqué la fusion.
- **RG-ventilation-periodique** et **RG-topics-mqtt** ([ssk-terrarium-cadrage#2026-015](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-015)) : la forme de `ventilation` dans l'état — `jour` et `nuit` avec leur durée et leur période, `hibernation` avec sa durée —, `moment` et le comportement de chaque mode. La formule de ce cadrage les lit sans les changer.
- **RG-regulation-sans-reseau** : le régulateur n'attend jamais la supervision. Rien ne change pour lui.
- Le cadrage 2026-016 en cours (consigne de jour et de nuit en `ACTIF`) touche la consigne de chauffage, pas la ventilation.

## Parcours utilisateur

1. Le régulateur publie son état toutes les 30 s, comme aujourd'hui.
2. À chaque état, l'historique calcule la part prévue : en `ACTIF`, de jour, avec un rythme de 5 minutes toutes les 30, il écrit 0,167 ; à la nuit tombée, avec 2 minutes par heure, 0,033.
3. Toutes les 5 minutes, chaque résumé publie `consigne_ventilation` à côté de `sorties.ventilateur`. La fenêtre de 5 minutes où la nuit tombe porte la moyenne des deux.
4. L'application la dessine en tirets sur l'axe en %, à côté de l'aire du ventilateur. L'après-midi, l'aire dépasse la ligne : l'option saturation a aéré en plus.
5. Le régulateur passe en `MAINTENANCE` : la consigne tombe à 0, comme le ventilateur.
6. Un régulateur dont le firmware ne publie pas `ventilation` n'a pas de consigne de ventilation : le champ manque à son résumé, et l'application ne la montre pas.

## Énoncés

### RG-historique-des-mesures

L'état que chaque régulateur publie sur `state` (RG-topics-mqtt) est historisé sur le cluster ssk-it-01, et gardé cinq ans. Au-delà, ses points s'effacent.

Telegraf lit l'état sous le compte `historique`, qui ne peut rien commander (RG-courtier-authentifie). Il en écrit les valeurs numériques dans VictoriaMetrics, une série par champ et par régulateur, `terrarium_<champ>{id="<MAC>"}` :

- la température et l'humidité de l'air retenues pour réguler, et la température du substrat ;
- la température et l'humidité de chaque sonde d'air, sous le nom que l'état publie, dans `terrarium_sonde_temperature{id, sonde}` et `terrarium_sonde_humidite{id, sonde}`. Le nom vient de l'état, et aucune liste de sondes n'est figée : une sonde que l'historique ne connaît pas encore y entre d'elle-même. Le rôle d'une sonde n'est pas une étiquette de sa série : changer son rôle ne coupe pas sa courbe en deux ;
- l'état de chaque sortie, à 1 quand elle est allumée et à 0 sinon ;
- la consigne et l'hystérésis ;
- la consigne de ventilation, `terrarium_consigne_ventilation{id}` : la part du temps d'aération que prévoit le rythme en place (RG-ventilation-periodique), de 0 à 1, calculée à chaque état reçu — `ventilation.<moment>.duree / ventilation.<moment>.periode` en `ACTIF` et en `PLAGES`, selon le `moment`, `jour` ou `nuit` ; `ventilation.hibernation.duree / 1440` en `HIBERNATION` ; 0 en `MAINTENANCE`. Le mode d'un rythme, métronome ou rubato, n'y change rien : le rubato aère en moyenne comme le métronome. L'option saturation n'y entre pas : c'est l'écart à cette consigne qui la montre. Aucun point quand `ventilation` manque, qu'un de ces champs manque ou n'est pas un nombre, que la période vaut 0, ou que le mode ou le moment est inconnu ;
- le défaut capteur, la pause de chauffe, l'heure connue et la plage en cours, à 1 ou 0 ;
- le temps depuis le démarrage ;
- et ce que les alertes demandent en plus ([ssk-terrarium-cadrage#2026-009](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009)).

Une mesure publiée à `null` n'écrit aucun point : elle n'est jamais écrite à zéro, ni remplacée par la dernière valeur connue. Les chaînes — version, plages, fuseau — et les bornes ne sont pas des séries : elles restent dans l'état retenu. La consigne de ventilation est la seule valeur que la supervision calcule au lieu de la lire : si la façon dont le régulateur aère change, son calcul doit suivre, et le jour où l'état publiera sa part prévue, l'historique la lira au lieu de la calculer.

L'historique ne s'écrit que depuis l'état publié. Le régulateur n'en sait rien et ne l'attend jamais. Une panne de Telegraf ou de VictoriaMetrics ne change rien à la régulation (RG-regulation-sans-reseau). Ce que Telegraf n'a pas encore écrit quand il s'arrête est perdu : l'historique a alors un trou, et la régulation aucun.

VictoriaMetrics n'est joignable que dans le cluster : aucun nom, aucune entrée HTTPS ne l'expose. Hors du cluster, l'historique se lit par ses résumés sur le courtier (RG-resumes-de-l-historique). vmui s'ouvre par une redirection de port, pour qui administre le cluster.

Ce que la règle protège :

- on compare cette nuit à la semaine dernière, et cet hiver au précédent ;
- une sonde qui décroche chaque nuit se voit dans l'historique, avant de se voir dans l'élevage ;
- la température du garage, que mesure la sonde extérieure, se garde avec celle du bac ;
- on voit si le ventilateur a tourné plus que son rythme ne le prévoyait, et quand ;
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
- `sorties.chauffage`, `sorties.eclairage`, `sorties.pompe` et `sorties.ventilateur`, chacun un tableau ;
- `consigne_ventilation`, la part du temps d'aération que prévoit le rythme de ventilation en place (RG-historique-des-mesures), sous la même forme que `consigne`.

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
- une sortie vaut la part des états reçus où elle était allumée, de 0 à 1, et `null` quand aucun état n'est reçu ;
- `consigne_ventilation` vaut, en moyenne, la part prévue sur les états de la fenêtre : une fenêtre qui passe du jour à la nuit pondère les deux rythmes.

Les mesures s'arrondissent au centième. Les parts — sorties et `consigne_ventilation` — s'arrondissent au millième : la part prévue se compare à celle du ventilateur, et au centième, 2 minutes par heure vaudraient 0,03 quand le ventilateur en fait 0,033, un écart qui n'existe pas.

Une série que le régulateur ne publie pas est absente du résumé, et non remplie de `null`. C'est le cas d'un substrat sans sonde, des sondes d'un firmware qui ne publie pas `sondes`, ou de `consigne_ventilation` pour un firmware qui ne publie pas `ventilation` sous la forme de RG-topics-mqtt. Elle n'a pas de valeurs antérieures à sa mise en service : ses premières fenêtres valent `null`. Les noms des sondes sont ceux de l'historique (RG-historique-des-mesures).

Un résumé est republié toutes les 5 minutes, même inchangé : son `calcule_le` dit que la supervision vit. Le courtier, sans volume, le perd à son redémarrage, et il revient à la publication suivante. Un résumé pèse de 50 à 70 Ko, avec deux sondes.

Les résumés sont publiés par l'historique, sous le compte `historique`, qui ne peut publier que sur `ssk-terrarium/+/historique/#` (RG-courtier-authentifie). Le régulateur ne lit pas ces sujets. L'application les lit sous son compte `sterrarium`, qui lit déjà tout `ssk-terrarium/#`. Ni sujet ni format ne change ce que le régulateur publie (RG-topics-mqtt).

Ce que la règle protège :

- l'application lit l'historique par le seul courtier, son seul adaptateur et son seul compte : aucun secret, aucun client HTTP, aucune origine à ouvrir de plus (décision `02-lecture-hors-du-cluster`) ;
- une fenêtre sans mesure se lit comme telle à toutes les échelles, sans dépendre de la façon dont un client interrogerait la base ;
- un silence du régulateur se distingue d'un rejet de mesure ;
- une nuit froide ne disparaît pas dans la moyenne d'un mois, puisque chaque fenêtre garde son minimum et son maximum ;
- un résumé ancien se reconnaît à l'heure de son calcul ;
- ce que le ventilateur a fait se lit en regard de ce que son rythme prévoyait, sans que l'application recopie la règle du régulateur.
