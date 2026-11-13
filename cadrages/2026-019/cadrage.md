---
id: 2026-019
titre: 'Un second câble chauffant pour l''air, que la coupure par le substrat ne coupe pas'
domaines: [materiel, regulation, securite, supervision]
liens:
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-001', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-005', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-005' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-007', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-007' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-018', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-018' }
  - { tag: pull_request, nom: 'ssk-terrarium-cadrage#54', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/pull/54' }
  - { tag: issue_github, nom: 'ssk-terrarium#40', url: 'https://github.com/sskorupski/ssk-terrarium/issues/40' }
  - { tag: issue_github, nom: 'ssk-it-infra#58', url: 'https://github.com/ssk-it/ssk-it-infra/issues/58' }
  - { tag: pull_request, nom: 'ssk-it-infra#59', url: 'https://github.com/ssk-it/ssk-it-infra/pull/59' }
impacts:
  - { regle: RG-sorties-par-mode, operation: modifie }
  - { regle: RG-coupure-par-le-substrat, operation: modifie }
  - { regle: RG-chauffe-continue-bornee, operation: modifie }
  - { regle: RG-brochage, operation: modifie }
  - { regle: RG-sorties-coupees-au-demarrage, operation: modifie }
  - { regle: RG-regulation-sans-reseau, operation: modifie }
  - { regle: RG-resumes-de-l-historique, operation: modifie }
  - { adr: ADR-commande-230v-par-relais-filaires, operation: modifie }
  - { regle: RG-chauffage-par-hysteresis, operation: touche }
  - { regle: RG-chauffage-par-plages, operation: touche }
  - { regle: RG-capteur-en-defaut, operation: touche }
  - { regle: RG-topics-mqtt, operation: touche }
  - { regle: RG-historique-des-mesures, operation: touche }
  - { regle: RG-230v-hors-du-bac, operation: touche }
  - { regle: RG-relais-coupes-sans-commande, operation: touche }
---

## Objectif

L'air du bac ne tient pas sa consigne en hiver, et il chute dès que la coupure par le substrat arrête le chauffage. Les relevés du 12 au 13 novembre 2026 ont été pris avec une consigne de 18 °C, dans un garage à environ 12 °C :

- de 19 h à 3 h, le chauffage reste coupé le temps que le substrat redescende de 24 à 18 °C, et l'air tombe de 16,5 à 13,5 °C ;
- de 3 h à 15 h, le chauffage tourne presque sans arrêt : le substrat remonte de 18 à 23 °C, et l'air plafonne vers 16 °C ;
- la zone d'approche de [ssk-terrarium-cadrage#2026-018](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-018), en essai depuis 16 h, n'y change rien : l'air retombe aussitôt vers 14,5 °C.

Le câble chauffant est posé au niveau du terreau : sa chaleur va au substrat, et à peine à l'air. Le régler autrement ne fera pas monter l'air, puisque la chaleur ne lui arrive pas.

Ce cadrage veut que l'air soit chauffé même quand le substrat a atteint son seuil, sans retirer au substrat sa protection, et sans que l'historique perde le fil de ce que faisait le chauffage.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| S1 | Chauffer l'air pendant une coupure par le substrat | Le câble de l'air suit le mode sur l'air pendant que le câble du substrat est coupé |
| S2 | Ne laisser aucun câble sans borne de température | Le câble de l'air est coupé quand le substrat atteint 28 °C, coupure active |
| S3 | Garder la lecture de l'historique | `sorties.chauffage` et `terrarium_chauffage` désignent toujours le câble qui chauffait jusqu'ici ; le câble de l'air a sa propre série |
| S4 | Ne rien ajouter au boîtier | Le câble de l'air prend le relais de l'éclairage, qui ne commandait rien |

### Ce que le référentiel disait déjà

- **Le montage décrit n'était pas le montage réel.** La nomenclature de [ssk-terrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001) prévoit deux câbles sur le même relais, par une multiprise : 6 m / 50 W sur la vitre arrière, 4,5 m / 25 W sur une vitre latérale. Le propriétaire a précisé le 13 novembre 2026 que seul le câble de 50 W est posé, au niveau du terreau. Le câble de 25 W n'avait jamais été branché. Ce cadrage le pose, plus haut, sur sa propre sortie.
- **2026-001 prévoyait déjà ce renfort**, mais sur le même relais (section « Puissance de chauffe »). La décision `01-sortie-du-cable-de-l-air` dit pourquoi cela ne suffit pas.
- **2026-005 avait accepté que l'air reste sous la consigne pendant une coupure** (décision `01-combinaison-air-substrat`). 2026-005 et [ssk-terrarium-cadrage#2026-007](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-007) avaient posé qu'une seule mesure décide du chauffage. Ce cadrage revient sur le premier point et garde le second (décision `02-pilotage-des-deux-cables`).
- **2026-018 avait répondu au même symptôme par la zone d'approche.** Elle reste en place, et ne s'applique plus qu'au câble du substrat.
- **L'éclairage n'a jamais été piloté.** RG-sorties-par-mode le tient coupé dans tous les modes, jusqu'au cadrage de la phase 4, qui n'a pas été écrit.
- **Aucun cadrage, aucune décision n'avait écarté** un second élément chauffant sur sa propre sortie.

### Puissance et fusible

La puissance totale reste de 75 W, soit 0,33 A, celle sur laquelle 2026-001 a dimensionné le fusible de 1 A temporisé (décision `07-fusible-du-chauffage`, sskorupski/ssk-terrarium#10). Ce fusible se pose en amont des deux relais de chauffage, sur le départ 230 V commun. Il ne change pas de calibre.

### Cadrages en cours sur les mêmes règles

Aucun ne porte sur le même besoin. Plusieurs modifient des règles que celui-ci modifie ou touche. Le dernier livré devra reprendre ses énoncés sur le texte que l'autre aura livré :

- [ssk-terrarium-cadrage#2026-016](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-016), consignes de jour et de nuit en `ACTIF` : RG-chauffage-par-hysteresis et RG-topics-mqtt ;
- [ssk-terrarium-cadrage#2026-009](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009), alertes sur téléphone : RG-chauffe-continue-bornee, RG-capteur-en-defaut, RG-topics-mqtt ;
- [ssk-terrarium-cadrage#2026-010](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-010), mise à jour à distance : RG-sorties-coupees-au-demarrage, RG-regulation-sans-reseau.

## Parcours utilisateur

1. Le propriétaire sort le ruban LED du boîtier et le branche sur un programmateur horaire autonome.
2. Il câble le contact du relais de l'éclairage (GPIO 27) en 230 V, comme celui du chauffage. Il vérifie au multimètre qu'il reste ouvert carte en reset, au boot et sans firmware (RG-relais-coupes-sans-commande), puis y branche le câble de 4,5 m / 25 W.
3. Il pose ce câble à l'extérieur du bac, contre une vitre, au-dessus du câble du substrat et sous l'isolant, jamais dans le couvercle (RG-230v-hors-du-bac).
4. Il flashe le firmware. Au démarrage, les deux câbles sont coupés (RG-sorties-coupees-au-demarrage).
5. L'air descend sous la consigne : les deux câbles s'allument.
6. Le substrat atteint son seuil de coupure. Le câble du substrat s'arrête, ou ralentit dans la zone d'approche, et le câble de l'air continue jusqu'à ce que l'air atteigne la consigne plus l'hystérésis.
7. L'historique montre `chauffage` coupé et `chauffage_air` allumé pendant la coupure, et l'air qui ne chute plus.
8. **Si la sonde d'air se décroche dans un coin froid** et fait chauffer le câble de l'air sans fin, la pause de 15 minutes toutes les 2 heures s'applique. Le substrat ne dépasse pas 28 °C : le câble de l'air est coupé à ce plafond, et reprend sous 26 °C.
9. **Si la sonde du substrat se tait**, le câble du substrat suit le comportement réglé pour une sonde muette, et le câble de l'air suit l'air sans plafond, comme sans sonde.

## Énoncés

### RG-sorties-par-mode

Le chauffage a deux sorties, deux câbles chauffants posés à l'extérieur du bac :

- **le câble du substrat**, 6 m / 50 W, au niveau du terreau, publié `chauffage` ;
- **le câble de l'air**, 4,5 m / 25 W, plus haut sur une vitre, publié `chauffage_air`.

Le mode décide pour les deux ensemble, sur la mesure de l'air retenue. Ce que les règles disent « du chauffage » vaut pour les deux câbles, sauf mention contraire.

Le régulateur a quatre modes, et chacun dit ce que le chauffage et le ventilateur peuvent faire :

| Mode | Chauffage | Ventilateur | Usage |
| --- | --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Une aération par période (RG-ventilation-periodique) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Comme en `ACTIF`, en plage comme hors plage | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Une aération par jour (RG-ventilation-periodique) | Novembre à février |
| `MAINTENANCE` | Coupé | Coupé | Nettoyage, changement de substrat |

Dans `ACTIF`, `PLAGES` et `HIBERNATION`, la coupure par le substrat prime sur ce que dit le tableau (RG-coupure-par-le-substrat). Elle ne coupe que le câble du substrat ; le câble de l'air n'est coupé qu'à son plafond. La brumisation suit en `PLAGES` ce qu'elle fait en `ACTIF`. Elle reste coupée dans tous les modes jusqu'à ce que le cadrage de la phase 2 lui donne son comportement, en modifiant cette règle.

L'éclairage n'est plus une sortie du régulateur. Le ruban LED est allumé par un programmateur horaire autonome, non connecté, et son relais est devenu celui du câble de l'air ([ssk-terrarium-cadrage#2026-019](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-019)). Les mesures continuent dans tous les modes.

Ce que la règle protège :

- en hibernation, les escargots restent au frais et au sec, sans geler, et l'air du bac se renouvelle encore ;
- en maintenance, rien ne chauffe ni ne tourne pendant qu'on a les mains dans le bac ;
- l'air reste chauffé pendant que le substrat, qui a atteint son seuil, refroidit.

### RG-coupure-par-le-substrat

La coupure de sécurité par le substrat est active par défaut, et se désactive par réglage (RG-reglages-bornes). Elle porte sur le câble du substrat (RG-sorties-par-mode). Le câble de l'air n'en dépend que par le plafond décrit plus bas.

Active, quand la sonde du substrat rend une mesure valide qui atteint le seuil de coupure du moment, le câble du substrat est coupé, quel que soit le mode. Il reste coupé jusqu'à une mesure valide du substrat strictement sous le seuil de reprise du moment ; il suit alors de nouveau son mode, sur l'air. Pendant la coupure, le câble de l'air suit son mode, sur l'air.

Les seuils se règlent pour le jour et pour la nuit (RG-jour-et-nuit), et valent dans tous les modes qui chauffent : `ACTIF`, `PLAGES` et `HIBERNATION`. Tant que l'heure n'est pas connue, ce sont ceux du jour. Par défaut, la coupure est à 24 °C et la reprise à 18,5 °C, le jour comme la nuit. Le seuil de coupure va de 20 à 28 °C, et la reprise reste au moins 2 °C en dessous, sans descendre sous 15 °C. Les seuils ne dépendent pas de la consigne.

Au passage du jour à la nuit, ou de la nuit au jour, la coupure se juge sur les seuils du nouveau moment dès la mesure suivante. Une coupure en cours se lève si la mesure est déjà sous la nouvelle reprise, et une mesure qui atteint la nouvelle coupure coupe.

Sous le seuil de coupure, une zone d'approche ralentit le câble du substrat :

- sa largeur se règle de 0 à 4 °C, la même le jour et la nuit, et vaut 0 par défaut : la coupure reste alors franche ;
- quand une mesure valide du substrat est dans la zone, de `coupure − approche` inclus à `coupure` exclu, et que le mode demande de chauffer, le câble du substrat ne tourne qu'une part de chaque tranche de 10 minutes, en début de tranche : `(coupure − mesure) / approche`, arrondie à la minute. Cette part vaut 100 % à l'entrée de la zone et diminue jusqu'à 0 au seuil ;
- une tranche commence quand la mesure est dans la zone et que le mode demande de chauffer, la suivante à la fin de la précédente. Sortir de la zone, ou couper, met fin à la tranche ;
- la part se calcule au début de chaque tranche, sur la dernière mesure valide ;
- hors de la zone, le câble du substrat suit son mode sans ralentir. Sans mesure valide, désactivée ou pendant une coupure, l'approche ne s'applique pas ;
- l'approche ne ralentit pas le câble de l'air.

Une mesure est valide quand la sonde répond, hors de sa valeur de mise sous tension (85 °C), et qu'elle est comprise entre −20 et 60 °C. Sans sonde, la coupure ne s'applique jamais, ni le plafond.

Si la sonde se tait ou rend des mesures invalides pendant une coupure, le comportement réglé s'applique :

- **`reprise-air`**, par défaut : la coupure tient le délai réglé, 2 minutes par défaut, puis se lève, et l'air décide seul jusqu'au retour d'une mesure valide ;
- **`maintien`** : la coupure tient jusqu'à une mesure valide sous la reprise. Elle se lève pourtant dès que la mesure de l'air retenue pour réguler descend sous 4 °C, le bas du hors-gel de `HIBERNATION`, et l'air décide alors seul jusqu'au retour d'une mesure valide du substrat. Ce plancher n'est pas un réglage.

**Le plafond du câble de l'air.** Coupure active, le câble de l'air est coupé dès qu'une mesure valide du substrat atteint 28 °C, quel que soit le mode. Il reste coupé jusqu'à une mesure valide strictement sous 26 °C. Ces deux valeurs sont fixées à la compilation, et ne sont pas des réglages. Sans mesure valide, le plafond se lève, et le câble de l'air suit son mode. Son entrée et sa sortie sont annoncées sur la liaison série.

Désactivée, la coupure ne s'applique jamais, comme sans sonde, et le plafond non plus :

- une coupure en cours se lève à la désactivation, et les deux câbles suivent leur mode, sur l'air ;
- la sonde reste relevée et publiée ;
- la désactivation est enregistrée et survit à un redémarrage (RG-mode-au-demarrage) ;
- elle est annoncée sur la liaison série et sur `event`, et publiée sur `state` (RG-topics-mqtt).

La coupure en cours n'est pas gardée en mémoire, ni le plafond : après un redémarrage, ils ne reviennent que sur une mesure qui atteint leur seuil.

La coupure prime sur le mode et sur la reprise qui suit la pause de RG-chauffe-continue-bornee. Elle n'est pas un défaut, et n'allume pas la LED d'état. Son entrée et sa sortie sont annoncées sur la liaison série. Sur `state` (RG-topics-mqtt) sont publiés :

- son état, `coupure_substrat`, qui dit si le câble du substrat est coupé ;
- ses réglages, `securite_substrat` ;
- les seuils qui s'appliquent, `seuils_substrat` ;
- la part de chauffe que l'approche permet au câble du substrat, `part_substrat`.

Elle est historisée (RG-historique-des-mesures).

Le substrat se mesure côté chaud, près du câble du substrat. Il peut atteindre le seuil de coupure avant que l'air atteigne la consigne. Jusqu'à [ssk-terrarium-cadrage#2026-019](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-019), l'air restait alors sans chauffe jusqu'à ce que le substrat soit redescendu sous la reprise. C'est le câble de l'air qui le chauffe désormais.

Le propriétaire a fait passer le substrat avant l'air, a voulu en régler les seuils, de jour et de nuit, et pouvoir s'en passer ([ssk-terrarium-cadrage#2026-018](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-018)). La coupure et le plafond passent par le même firmware et les mêmes relais que la régulation. Ils ne remplacent pas le limiteur matériel reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001.

Ce que la règle protège :

- le chauffage ne cuit pas le substrat où vivent les escargots tant que la coupure est active ;
- un réglage ne peut ni porter la coupure au-delà de 28 °C, ni la faire osciller autour de son seuil ;
- l'approche laisse le substrat se stabiliser sous son seuil au lieu de le franchir ;
- l'air reste chauffé pendant une coupure ;
- aucun câble ne porte le substrat au-delà de 28 °C, même quand une sonde d'air trompée le fait chauffer ;
- une coupure désactivée se voit ;
- une sonde absente ou en panne n'empêche pas de chauffer l'air, et, même maintenue, une coupure ne laisse pas l'élevage geler.

### RG-chauffe-continue-bornee

Le chauffage ne reste pas allumé plus de 2 heures d'affilée. La durée court tant qu'au moins un de ses deux câbles est allumé (RG-sorties-par-mode). Le câble du substrat arrêté dans une tranche ralentie de l'approche ne l'interrompt donc que si le câble de l'air est lui aussi coupé.

Au-delà des 2 heures, les deux câbles sont coupés pendant 15 minutes. Le dépassement est signalé par la LED d'état et sur la liaison série ; l'alerte sur téléphone s'y ajoutera avec sa phase. Passé ces 15 minutes, chaque câble reprend sur la consigne du mode, sans intervention, sauf si la coupure par le substrat ou le plafond du câble de l'air le tient encore coupé (RG-coupure-par-le-substrat). Un verrou posé la nuit laisserait le bac refroidir jusqu'au matin, hors-gel compris.

La règle borne une durée, non une température. La coupure par le substrat et le plafond bornent la température du substrat, mais rien de matériel ne couvre une surchauffe en phase 1 (décision `06-protection-contre-la-surchauffe`). Des coupures qui se répètent signalent une chauffe sous-dimensionnée ou un relais collé.

Ce que la règle protège : une sonde décrochée ou un câble défaillant ne fait pas chauffer sans fin, et une seule pause, publiée dans `pause_chauffage`, se lit pour les deux câbles.

### RG-brochage

Le brochage de l'ESP32 est le suivant :

| Fonction | GPIO | Remarque |
| --- | --- | --- |
| I²C SDA (SHT45) | 21 | |
| I²C SCL | 22 | |
| 1-Wire DS18B20 | 4 | Pull-up 4,7 kΩ vers 3,3 V |
| Données DHT11 (KY-015) | 13 | Module alimenté en 3,3 V ; résistance de tirage du module |
| Relais du câble du substrat | 26 | Coupé au démarrage ; 230 V |
| Relais du câble de l'air | 27 | Coupé au démarrage ; 230 V. Ancien relais LED |
| Relais pompe | 25 | Coupé au démarrage |
| Relais ventilateur | 33 | Coupé au démarrage |
| LED d'état | 2 | LED externe + 330 Ω : la KS5016 n'en a pas sur cette broche |

Le niveau logique « coupé » des quatre sorties de relais dépend du niveau de déclenchement du module, à vérifier (RG-relais-coupes-sans-commande).

Les deux câbles chauffants ont chacun leur relais. Le fusible du chauffage, quand il sera posé, l'est en amont des deux, sur leur départ 230 V commun.

### RG-sorties-coupees-au-demarrage

À chaque démarrage, les deux câbles chauffants, la pompe et le ventilateur sont mis à l'état coupé avant toute autre opération. Avant même que le firmware ne s'exécute, RG-relais-coupes-sans-commande les tient coupés. Ce que la règle protège : un redémarrage — coupure, chien de garde, mise à jour — n'allume jamais une sortie au hasard.

### RG-regulation-sans-reseau

La régulation tourne entièrement sur le régulateur. L'absence du Wi-Fi, du broker ou de tout serveur n'a aucun effet sur la brumisation ni sur le chauffage, à une exception : en mode `PLAGES`, sans heure connue depuis le démarrage, le chauffage suit la consigne comme en plage, au lieu de suivre les plages. L'absence de réseau ne peut donc jamais abaisser le chauffage au plancher de 12 °C, ni l'éteindre. Le réseau ne sert qu'à superviser, et à donner l'heure. L'éclairage, sur son programmateur autonome, ne dépend pas plus du réseau que du régulateur. Ce que la règle protège : une panne de box ou de serveur ne met pas l'élevage en danger.

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
- `sorties.<nom>`, un tableau pour chaque sortie que l'état publie : `chauffage`, `chauffage_air`, `pompe` et `ventilateur`. Un régulateur antérieur à 2026-019 publie aussi `eclairage`, et ne publie pas `chauffage_air` ;
- `consigne_ventilation`, la part du temps d'aération que prévoit le rythme de ventilation en place (RG-historique-des-mesures), sous la même forme que `consigne` ;
- `coupure_substrat`, un tableau, sous la même forme qu'une sortie : la part des états reçus où la coupure par le substrat coupait le câble du substrat ;
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

Une série que le régulateur ne publie pas est absente du résumé, et non remplie de `null`. C'est le cas :

- d'un substrat sans sonde ;
- des sondes d'un firmware qui ne publie pas `sondes` ;
- de `chauffage_air` pour un firmware antérieur à 2026-019, et d'`eclairage` pour un firmware qui en est issu ;
- de `consigne_ventilation` pour un firmware qui ne publie pas `ventilation` sous la forme de RG-topics-mqtt ;
- de `seuils_substrat` pour un firmware qui ne le publie pas.

Une sortie présente dans une partie seulement de la période vaut `null` dans les fenêtres où elle n'était pas publiée. `coupure_substrat` est publié par tous les firmwares depuis 2026-005, mais sa série n'entre dans l'historique qu'avec 2026-018 : elle n'a pas de valeurs antérieures à sa mise en service, et ses premières fenêtres valent `null`. Les noms des sondes sont ceux de l'historique (RG-historique-des-mesures).

Un résumé est republié toutes les 5 minutes, même inchangé : son `calcule_le` dit que la supervision vit. Le courtier, sans volume, le perd à son redémarrage, et il revient à la publication suivante. Un résumé pèse de 50 à 70 Ko, avec deux sondes.

Les résumés sont publiés par l'historique, sous le compte `historique`, qui ne peut publier que sur `ssk-terrarium/+/historique/#` (RG-courtier-authentifie). Le régulateur ne lit pas ces sujets. L'application les lit sous son compte `sterrarium`, qui lit déjà tout `ssk-terrarium/#`. Ni sujet ni format ne change ce que le régulateur publie (RG-topics-mqtt).

Ce que la règle protège :

- l'application lit l'historique par le seul courtier, son seul adaptateur et son seul compte : aucun secret, aucun client HTTP, aucune origine à ouvrir de plus (décision `02-lecture-hors-du-cluster`) ;
- une fenêtre sans mesure se lit comme telle à toutes les échelles, sans dépendre de la façon dont un client interrogerait la base ;
- un silence du régulateur se distingue d'un rejet de mesure ;
- une nuit froide ne disparaît pas dans la moyenne d'un mois, puisque chaque fenêtre garde son minimum et son maximum ;
- un résumé ancien se reconnaît à l'heure de son calcul ;
- ce que le ventilateur a fait se lit en regard de ce que son rythme prévoyait, sans que l'application recopie la règle du régulateur ;
- une chauffe absente se lit comme une coupure par le substrat, et non comme une panne, et les seuils se lisent à côté de la température du substrat qu'ils jugent ;
- la chauffe de l'air se lit à côté de la coupure du câble du substrat : on voit que l'air est chauffé pendant que le substrat refroidit.

### ADR-commande-230v-par-relais-filaires

Les sorties sont commandées par un module de relais électromécaniques optocouplés, câblé à l'ESP32 dans un boîtier fermé :

- les deux câbles chauffants en 230 V ;
- la pompe en 12 V, qui garde sa diode de roue libre ;
- le ventilateur en 5 V.

Aucune sortie ne passe par une prise connectée.

Ce qui l'a décidé : une prise connectée rendrait la régulation dépendante du Wi-Fi, contraire à RG-regulation-sans-reseau. Entre relais statiques et module électromécanique, l'utilisateur a choisi le module pour son prix et la simplicité d'un seul module pour toutes les sorties, sous les garde-fous de RG-relais-coupes-sans-commande (2026-001, décision `02-commande-230v`).

Le ruban LED n'est plus une sortie du régulateur : il est allumé par un programmateur horaire autonome, non connecté, et son relais commande le câble de l'air ([ssk-terrarium-cadrage#2026-019](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-019), décision `01-sortie-du-cable-de-l-air`). Le programmateur, ne dépendant d'aucun réseau, ne contredit pas le motif qui a écarté la prise connectée.
