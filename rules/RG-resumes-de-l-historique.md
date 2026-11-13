---
id: RG-resumes-de-l-historique
fonctionnalites: [historique, mqtt]
statut: actif
cree_par: 2026-014
modifie_par: [2026-017, 2026-018]
---

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
- `consigne_ventilation`, la part du temps d'aération que prévoit le rythme de ventilation en place (RG-historique-des-mesures), sous la même forme que `consigne` ;
- `coupure_substrat`, un tableau, sous la même forme qu'une sortie : la part des états reçus où la coupure par le substrat coupait le chauffage ;
- `seuils_substrat.coupure` et `seuils_substrat.reprise`, les seuils qui s'appliquaient, sous la même forme que `consigne`. Une fenêtre où la coupure était désactivée de bout en bout vaut `null`, avec 0 dans `n` : rien ne s'appliquait ;
- `part_substrat`, la part de chauffe que permettait l'approche, sous la même forme que `consigne`.

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
- une sortie vaut la part des états reçus où elle était allumée, de 0 à 1, et `null` quand aucun état n'est reçu ; `coupure_substrat` aussi ;
- `consigne_ventilation` vaut, en moyenne, la part prévue sur les états de la fenêtre : une fenêtre qui passe du jour à la nuit pondère les deux rythmes.

Les mesures s'arrondissent au centième. Les parts — sorties, `coupure_substrat`, `part_substrat` et `consigne_ventilation` — s'arrondissent au millième : la part prévue se compare à celle du ventilateur, et au centième, 2 minutes par heure vaudraient 0,03 quand le ventilateur en fait 0,033, un écart qui n'existe pas.

Une série que le régulateur ne publie pas est absente du résumé, et non remplie de `null`. C'est le cas d'un substrat sans sonde, des sondes d'un firmware qui ne publie pas `sondes`, de `consigne_ventilation` pour un firmware qui ne publie pas `ventilation` sous la forme de RG-topics-mqtt, ou de `seuils_substrat` pour un firmware qui ne le publie pas. `coupure_substrat` est publié par tous les firmwares depuis 2026-005 : le champ existe avant ce cadrage, mais sa série n'entre dans l'historique qu'avec lui. Elle n'a pas de valeurs antérieures à sa mise en service : ses premières fenêtres valent `null`. Les noms des sondes sont ceux de l'historique (RG-historique-des-mesures).

Un résumé est republié toutes les 5 minutes, même inchangé : son `calcule_le` dit que la supervision vit. Le courtier, sans volume, le perd à son redémarrage, et il revient à la publication suivante. Un résumé pèse de 50 à 70 Ko, avec deux sondes.

Les résumés sont publiés par l'historique, sous le compte `historique`, qui ne peut publier que sur `ssk-terrarium/+/historique/#` (RG-courtier-authentifie). Le régulateur ne lit pas ces sujets. L'application les lit sous son compte `sterrarium`, qui lit déjà tout `ssk-terrarium/#`. Ni sujet ni format ne change ce que le régulateur publie (RG-topics-mqtt).

Ce que la règle protège :

- l'application lit l'historique par le seul courtier, son seul adaptateur et son seul compte : aucun secret, aucun client HTTP, aucune origine à ouvrir de plus (décision `02-lecture-hors-du-cluster`) ;
- une fenêtre sans mesure se lit comme telle à toutes les échelles, sans dépendre de la façon dont un client interrogerait la base ;
- un silence du régulateur se distingue d'un rejet de mesure ;
- une nuit froide ne disparaît pas dans la moyenne d'un mois, puisque chaque fenêtre garde son minimum et son maximum ;
- un résumé ancien se reconnaît à l'heure de son calcul ;
- ce que le ventilateur a fait se lit en regard de ce que son rythme prévoyait, sans que l'application recopie la règle du régulateur ;
- une chauffe absente se lit comme une coupure par le substrat, et non comme une panne, et les seuils se lisent à côté de la température du substrat qu'ils jugent.
