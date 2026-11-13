---
id: RG-historique-des-mesures
fonctionnalites: [historique, mesures]
statut: actif
cree_par: 2026-014
modifie_par: [2026-017]
---

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
