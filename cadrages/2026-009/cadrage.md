---
id: 2026-009
titre: Prévenir le téléphone quand le terrarium demande attention, selon des alertes réglées depuis l'application
domaines: [supervision, securite]
liens:
  - { tag: piste, nom: '#14', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/issues/14' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-001', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-002', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-006', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-006' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-007', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-007' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-006', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-006' }
  - { tag: pull_request, nom: 'sterrarium-cadrage#13', url: 'https://github.com/sskorupski/sterrarium-cadrage/pull/13' }
  - { tag: issue_github, nom: 'ssk-terrarium#28', url: 'https://github.com/sskorupski/ssk-terrarium/issues/28' }
  - { tag: issue_github, nom: 'ssk-it-infra#49', url: 'https://github.com/ssk-it/ssk-it-infra/issues/49' }
  - { tag: pull_request, nom: 'ssk-it-infra#53', url: 'https://github.com/ssk-it/ssk-it-infra/pull/53' }
  - { tag: issue_github, nom: 'sterrarium#18', url: 'https://github.com/sskorupski/sterrarium/issues/18' }
impacts:
  - { regle: RG-alertes-sur-telephone, operation: cree }
  - { regle: RG-reglage-des-alertes, operation: cree }
  - { adr: ADR-alertes-par-la-supervision, operation: cree }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-capteur-en-defaut, operation: modifie }
  - { regle: RG-chauffe-continue-bornee, operation: modifie }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { regle: RG-courtier-authentifie, operation: touche }
  - { regle: RG-sondes-d-air, operation: touche }
  - { regle: RG-coupure-par-le-substrat, operation: touche }
  - { adr: ADR-courtier-mosquitto-sur-ssk-it-01, operation: touche }
---

## Objectif

Le régulateur signale ses défauts par sa LED d'état et sa liaison série : il faut être au garage pour les voir. L'application sterrarium montre l'état à distance, mais seulement quand on l'ouvre. Le 9 novembre 2026, la SHT45 trempée a coupé le chauffage et le bac est descendu à 15,2 °C (2026-006) : rien n'a prévenu le propriétaire. L'objectif O5 de 2026-001 demande des « alertes sur téléphone », l'exigence F9 en donne la liste, et NF3 veut qu'un capteur en défaut entraîne une alerte. Les règles RG-capteur-en-defaut et RG-chauffe-continue-bornee les annoncent depuis la phase 1 : « l'alerte sur téléphone s'y ajoutera avec sa phase ».

Ce qu'on cherche :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| A1 | Être prévenu sans ouvrir l'application | Une alerte arrive sur le téléphone en veille, application sterrarium fermée |
| A2 | Être prévenu aussi quand le régulateur ne peut plus rien dire | Un régulateur hors ligne, ou dont l'état ne parvient plus, déclenche une alerte |
| A3 | N'être dérangé que pour ce qui le mérite | Chaque alerte se règle : activée ou non, ses seuils, son délai ; les réglages par défaut ne sonnent pas tout l'hiver |
| A4 | Ne rien changer à la régulation | Ni l'envoi des alertes ni leur absence ne modifient ce que fait le régulateur |

### Ce que le référentiel disait déjà

- La fonctionnalité `alertes` existe dans le domaine supervision, sans aucune règle. La piste [#14](https://github.com/ssk-it/ssk-terrarium-cadrage/issues/14) proposait un RG-alertes où « le régulateur envoie une alerte », vers ntfy. L'architecture cible de 2026-001 trace aussi l'ESP vers ntfy en HTTPS. Ce n'était pas une décision : ce cadrage la prend autrement (décision `01-emetteur-des-alertes`).
- RG-topics-mqtt publie déjà dans `state` tout ce qu'il faut pour fonder les alertes : `defaut_capteur`, `sondes.<nom>.defaut` (2026-007), `mise_en_securite` (2026-006), la mesure de l'air, le mode, `en_plage`, `uptime_s`. Le firmware publie aussi `pause_chauffage` (`lib/supervision/state_message.cpp`), que l'énoncé de RG-topics-mqtt omettait : ce cadrage l'y écrit.
- Le firmware n'envoie aucun événement de démarrage sur `event`, contrairement à ce que dit RG-topics-mqtt, et ne publie pas la cause d'un redémarrage. « Redémarrage inattendu » (F9) ne se distingue donc pas d'un redémarrage voulu : l'alerte dit qu'il a redémarré, sans dire pourquoi.
- `lib/alerts` existe dans le firmware, mais ne contient que des fonctions vides (« TODO phase 3 ntfy »), appelées depuis `src/main.cpp`. Ce cadrage les rend inutiles.
- Les décisions `02-protocole-de-publication` et `03-hebergement-du-courtier` de 2026-002 ont retenu un courtier Mosquitto seul sur ssk-it-01, « sans rien y ajouter que le courtier lui-même ». Le dépôt ssk-it-infra porte pourtant depuis un historique, Telegraf et VictoriaMetrics, gardé cinq ans (ssk-it-infra `f156d56`), sans qu'aucun cadrage l'ait décidé : la piste [#18](https://github.com/ssk-it/ssk-terrarium-cadrage/issues/18) est restée ouverte. Ce cadrage s'appuie sur cet historique tel qu'il est déployé, et le dit, sans le cadrer à la place de la piste #18.
- Côté application, [sterrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-001) range les alertes hors périmètre. L'écran de réglage des alertes est cadré dans [sterrarium-cadrage#2026-006](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-006), à partir du contrat que ce cadrage fixe.
- Les cadrages 2026-008, 2026-013 et 2026-015, livrés pendant sa relecture, ont modifié RG-topics-mqtt, RG-reglages-bornes et RG-mode-au-demarrage : ce cadrage part de leurs énoncés après la livraison de 2026-015. 2026-010 (mise à jour à distance), encore en cours, modifie aussi RG-topics-mqtt : celui des deux qui se livre en second reprend l'énoncé de l'autre.

## Parcours utilisateur

1. Le propriétaire installe l'application ntfy sur son téléphone, s'abonne au sujet du terrarium sur le serveur ntfy de ssk-it-01 avec son compte, et exempte ntfy de l'optimisation de batterie.
2. Dans sterrarium, sur le bureau ou sur le téléphone, il ouvre le réglage des alertes. Il y voit chaque alerte, activée ou non, ses seuils et son délai, tels que le régulateur les publie. Il en coupe une, ou change un seuil ; l'application envoie la commande, et le réglage accepté apparaît dans l'état suivant, sur ses deux appareils.
3. Un réglage hors bornes est refusé en entier par le régulateur, avec sa raison sur `event`, et l'application la montre.
4. La nuit, la SHT45 se tait. Deux minutes plus tard, la DHT11 prend le relais : son téléphone, en veille, reçoit « Sonde sht45 (intérieure) en défaut : muet. La régulation continue sur l'autre sonde ». Les deux sondes tombent : il reçoit « Défaut capteur : chauffage et pompe coupés ».
5. Le Wi-Fi de la maison tombe. 90 secondes sans état déclenchent le silence, et il reçoit « Le terrarium ne donne plus de nouvelles » deux minutes et demie à trois minutes après le dernier état : la supervision ajoute sa propre latence au délai. Tant que dure le silence, rien d'autre ne lui est dit de ce régulateur. Quand l'état revient, un message dit que c'est fini.
6. En mode `HIBERNATION`, le bac est à 5 °C : rien ne sonne. En mode `ACTIF`, il reste sous 15 °C pendant 10 minutes : il reçoit une alerte de température basse.
7. Il a désactivé la mise en sécurité. Il en reçoit un rappel, puis un toutes les 12 heures tant qu'elle reste désactivée. Le rappel ne réarme rien.
8. Le cluster ssk-it-01 tombe : aucune alerte ne part, pas même celle du silence. C'est la limite de ce cadrage (voir l'ADR).

## Énoncés

### RG-alertes-sur-telephone

Le téléphone du propriétaire reçoit une alerte quand le terrarium demande son attention, application sterrarium fermée et téléphone en veille. L'alerte part de la supervision, sur le cluster ssk-it-01, jamais du régulateur (ADR-alertes-par-la-supervision). Elle se déduit de l'état publié par le régulateur toutes les 30 s (RG-topics-mqtt), tel que l'historique le garde. Rien n'en revient vers le régulateur (RG-regulation-sans-reseau).

Chaque alerte nomme le régulateur concerné. Elle part si elle est activée, avec les seuils et le délai que publie le dernier état reçu (RG-reglage-des-alertes). Un régulateur qui ne publie aucun réglage d'alertes, avec un firmware antérieur à ce cadrage, se voit appliquer les valeurs par défaut. Les alertes sont :

- **Silence** : aucun état reçu depuis le délai réglé, 90 s par défaut, soit trois publications manquées. Régulateur hors tension, Wi-Fi coupé, courtier ou historique en panne : la supervision ne distingue pas ces causes, et l'alerte ne prétend pas trancher. Le réglage appliqué est celui du dernier état reçu.
- **Défaut capteur** : `defaut_capteur` vrai. Aucune sonde intérieure n'est acceptée depuis 2 minutes, et le chauffage et la pompe sont coupés (RG-capteur-en-defaut).
- **Défaut d'une sonde** : `sondes.<nom>.defaut` vrai alors que `defaut_capteur` est faux. L'alerte donne la sonde, son rôle et sa cause, et dit que la régulation continue, pour qu'on ne la prenne pas pour une coupure (RG-sondes-d-air).
- **Température de l'air hors plage**, pendant plus que le délai réglé, 10 minutes par défaut. Elle part au-dessus du seuil haut, 24 °C par défaut, dans tous les modes. Elle part aussi au-dessous du seuil bas du mode, réglé par défaut à :
  - 15 °C en `ACTIF`, et en `PLAGES` en plage ou sans heure connue ;
  - 11 °C en `PLAGES` hors plage ;
  - 3 °C en `HIBERNATION` et en `MAINTENANCE`.
- **Humidité de l'air hors plage**, pendant plus que le délai réglé, 30 minutes par défaut, dans tous les modes. Les seuils par défaut sont de 60 et 95 %.
- **Mise en sécurité désactivée** : `mise_en_securite.air` faux. C'est un rappel du risque que le propriétaire a accepté (2026-006, décision `03-lever-la-mise-en-securite`). Il ne réarme rien, et ne propose aucun réarmement automatique.
- **Pause de chauffe** : `pause_chauffage` vrai. Le chauffage est resté allumé 2 heures d'affilée, et le régulateur le coupe 15 minutes (RG-chauffe-continue-bornee). Des pauses répétées signalent une chauffe sous-dimensionnée ou un relais collé.
- **Redémarrage** : `uptime_s` est plus petit que dans l'état précédent. Le régulateur ne publie pas la cause d'un redémarrage : l'alerte ne dit pas s'il était attendu.

Une mesure rejetée, publiée à `null`, n'est jamais hors plage : c'est le défaut de sonde qui la signale. La coupure par le substrat n'est pas une panne et ne déclenche aucune alerte (RG-coupure-par-le-substrat).

Une alerte part une fois quand sa condition apparaît. Elle se rappelle toutes les 12 heures tant que la condition dure, et un message dit quand elle a cessé. Le redémarrage n'a pas de durée : il part une fois. Entre une condition et son message s'écoulent une à deux minutes, la latence de l'historique et de l'envoi.

Un régulateur silencieux ne dit plus rien de son état : tant que dure son silence, ses autres alertes gardent le dernier état connu et se taisent, leur fin comprise, sauf le redémarrage. Au retour des états, une alerte encore vraie et pas encore annoncée part ; une alerte qui a cessé pendant le silence s'achève sans message. De même, quand le défaut d'une sonde devient un défaut capteur, la fin du premier se tait : la sonde n'est pas rétablie.

Les alertes passent par un serveur ntfy hébergé sur ssk-it-01, sur un sujet que seul un compte autorisé peut lire, sans accès anonyme. L'application ntfy du téléphone les reçoit par une connexion qu'elle tient ouverte.

La supervision ne surveille pas sa propre panne. Si le cluster, l'historique ou l'évaluateur des alertes s'arrête, aucune alerte ne part, pas même celle du silence.

Ce que la règle protège :

- le propriétaire apprend un défaut, une dérive ou un silence quand il survient, et non à sa prochaine visite ;
- les alertes font les mêmes distinctions que l'application : coupure ou non, sonde seule ou air intérieur entier ;
- un régulateur qui ne peut plus rien dire est quand même signalé.

### RG-reglage-des-alertes

Ce que chaque alerte de RG-alertes-sur-telephone envoie se règle à distance, par `cmd/config` (RG-topics-mqtt), depuis l'application sterrarium sur le bureau comme sur le téléphone. Le régulateur valide chaque réglage, l'enregistre en mémoire non volatile et le republie dans `state` : c'est la seule source du réglage, la même pour tous les appareils, et il survit à un redémarrage du courtier. Le régulateur n'évalue aucune alerte, et aucun réglage d'alerte ne change ce qu'il régule.

Les réglages, leurs valeurs par défaut et leurs bornes :

- **chaque alerte** — silence, défaut capteur, défaut d'une sonde, température, humidité, mise en sécurité désactivée, pause de chauffe, redémarrage — est activée ou désactivée. Elle est activée par défaut.
- **le délai du silence** se choisit parmi 90 s, 5, 15, 30 et 60 minutes. Il vaut 90 s par défaut.
- **les seuils de température de l'air**, en °C à une décimale, vont de 0 à 30 °C. Les valeurs par défaut sont :
  - un seuil haut de 24 °C ;
  - un seuil bas de 15 °C pour `ACTIF` et `PLAGES` en plage ;
  - un seuil bas de 11 °C pour `PLAGES` hors plage ;
  - un seuil bas de 3 °C pour `HIBERNATION` et `MAINTENANCE`.

  Chaque seuil bas reste strictement sous le seuil haut.
- **les seuils d'humidité de l'air**, en % entiers, vont de 0 à 100 %. Ils valent 60 et 95 % par défaut, et le seuil bas reste strictement sous le seuil haut.
- **le délai de la température et celui de l'humidité** se choisissent chacun parmi 5, 10, 15, 30, 60 et 120 minutes. Ils valent 10 et 30 minutes par défaut.

Les délais se choisissent dans une liste fermée, pas dans un intervalle. Pour la température et l'humidité, l'évaluateur des alertes fixe la durée d'une condition à l'écriture de la règle : il y a une règle par délai admis, et un délai libre n'en aurait aucune. Le silence, lui, compare le temps écoulé depuis le dernier état à son délai réglé : une seule règle couvre sa liste. Un délai publié hors de sa liste vaut le délai par défaut. Le rappel de 12 heures n'est pas un réglage.

Une commande partielle ne change que ce qu'elle nomme. Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, avec sa raison sur `event`, et rien n'en est appliqué. Les bornes sont des constantes du firmware, publiées dans `state` (RG-topics-mqtt).

Désactiver une alerte est la décision du propriétaire, comme désactiver la mise en sécurité. L'application montre les alertes désactivées.

Ce que la règle protège :

- le propriétaire choisit ce qui le dérange, sans reflasher la carte ni toucher à l'infrastructure ;
- ses appareils ne se contredisent pas ;
- un seuil bas placé au-dessus du seuil haut ne rend pas une alerte muette par mégarde ;
- un réglage ne disparaît pas quand le courtier redémarre sans mémoire.

### ADR-alertes-par-la-supervision

Les alertes sur téléphone sont évaluées sur le cluster ssk-it-01, à côté de l'historique que ssk-it-infra y déploie : Telegraf, abonné à `ssk-terrarium/+/state` sous le compte `historique`, et VictoriaMetrics. Trois composants s'y ajoutent, tous configurés, aucun écrit :

- vmalert évalue les règles d'alerte sur l'historique, en lisant dans l'état historisé les seuils, les délais et l'activation de chaque alerte ;
- Alertmanager regroupe les alertes, les rappelle et annonce leur fin ;
- un serveur ntfy, sur un nom à lui sous l'entrée HTTPS existante, les pousse vers le téléphone.

Telegraf historise aussi ce qu'il ignorait et dont les alertes ont besoin : le mode, `mise_en_securite.air`, `sondes.<nom>.defaut` et le réglage des alertes. Ni vmalert ni Alertmanager ne parlent au courtier : il n'y a aucun compte MQTT de plus. Le sujet ntfy est fermé à l'anonyme, et ses comptes se scellent dans ssk-it-infra, comme ceux du courtier.

Ce qui a tranché :

- seul un tiers peut signaler un régulateur qui ne peut plus rien dire ;
- l'historique déployé lit déjà l'état de chaque régulateur ;
- évaluer les alertes sur le serveur laisse le firmware tel qu'il régule, sans dépendre de la mise à jour à distance pour changer une alerte (décision `01-emetteur-des-alertes`).

Ce cadrage s'écarte en connaissance de cause du motif de 2026-002/03, « sans rien y ajouter que le courtier lui-même ». Le courtier, lui, reste un Mosquitto seul (ADR-courtier-mosquitto-sur-ssk-it-01).

Ce que l'architecture ne couvre pas : une panne du cluster, de VictoriaMetrics ou de vmalert fait taire toutes les alertes. Une veille de la veille, hors de ssk-it-01, est hors de ce cadrage. Avec un serveur ntfy auto-hébergé, l'application ntfy du téléphone garde une connexion ouverte, signalée par une notification permanente qu'on peut masquer (décision `02-livraison`).

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, le jour et la nuit (`jour_nuit`), le jour d'aujourd'hui (`jour_aujourdhui`) et le moment de la journée (`moment`), les réglages de la ventilation (`ventilation`) et l'aération de saturation en cours ou non (`aeration_saturation`), l'heure connue ou non, en plage ou non, le défaut capteur, la pause de chauffe (`pause_chauffage`, RG-chauffe-continue-bornee), la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, le réglage des alertes (`alertes`), et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, chauffe de la SHT45 |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide`. `jour_nuit` : objet complet, qui remplace celui en place. `ventilation` : objet partiel à deux niveaux, `{"jour":{…},"nuit":{…},"hibernation":{…},"saturation":{…}}`, chacun partiel. `alertes` : objet partiel du réglage des alertes (ci-dessous) |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

`jour_nuit` publie le réglage de RG-jour-et-nuit : `{"mode":"metronome","jour":"08:00-21:00"}`, ou `{"mode":"saisons","saisons":[{"debut":"03-20","jour":"07:00-21:00"},…]}`, saisons rangées par date. `jour_aujourdhui` est le jour calculé pour la date du jour, `"HH:MM-HH:MM"`, ou `null` tant que l'heure n'est pas connue. `moment` vaut `jour` ou `nuit` ; il vaut `jour` tant que l'heure n'est pas connue.

`ventilation` publie les réglages en place de RG-ventilation-periodique : `{"jour":{"mode":…,"duree":…,"periode":…,"ecart":…},"nuit":{…},"hibernation":{"heure":"HH:MM","duree":…},"saturation":{"active":…,"comportement":…,"humidite":…,"attente":…,"duree":…,"pause":…}}`. Ce que fait le ventilateur à l'instant se lit dans `sorties.ventilateur`, et `aeration_saturation` dit si c'est l'option saturation qui le fait tourner.

`alertes` publie le réglage de RG-reglage-des-alertes, entier, dans la forme que `cmd/config` accepte partielle : `{"silence":{"active":true,"delai_s":90},"defaut_capteur":{"active":true},"defaut_sonde":{"active":true},"temperature":{"active":true,"haute":24.0,"basse":{"actif":15.0,"hors_plage":11.0,"hibernation":3.0},"delai_s":600},"humidite":{"active":true,"basse":60,"haute":95,"delai_s":1800},"securite_desactivee":{"active":true},"pause_chauffage":{"active":true},"redemarrage":{"active":true}}`. `basse.actif` vaut pour `ACTIF` et pour `PLAGES` en plage ou sans heure connue, `basse.hors_plage` pour `PLAGES` hors plage, `basse.hibernation` pour `HIBERNATION` et `MAINTENANCE`. Les délais sont en secondes. Le régulateur n'en fait rien d'autre que de le publier : la supervision le lit pour évaluer les alertes (RG-alertes-sur-telephone).

Les bornes publiées dans `state` sont celles de RG-reglages-bornes et de RG-reglage-des-alertes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…],"saisons_max":…,"ventilation":{"duree":[min,max],"periode":[min,max],"ecart":[min,max],"humidite":[min,max],"attente":[min,max],"pause":[min,max]},"alertes":{"temperature":[min,max],"humidite":[min,max],"delais_s":[…],"delais_silence_s":[…]}}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. `saisons_max` est le nombre maximal de saisons. `alertes.temperature` et `alertes.humidite` sont les intervalles admis des seuils d'alerte, bornes comprises ; `alertes.delais_s` et `alertes.delais_silence_s` sont les listes des délais admis, en secondes. Les intervalles de `ventilation` sont admis bornes comprises, en minutes ou en pour cent entiers ; `duree` vaut pour la ventilation de jour et de nuit, l'aération d'hibernation et l'option saturation ; une durée de ventilation doit rester strictement sous sa période. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`. Une commande `ventilation` hors bornes, mal formée, ou qui laisserait une durée au moins égale à sa période, l'est avec la raison `ventilation invalide` ; une commande `jour_nuit` hors bornes ou mal formée, avec la raison `jour_nuit invalide`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité, le rôle des sondes ni la ventilation à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série ;
- les réglages de la ventilation, le moment de la journée et l'aération de saturation se lisent dans le même message que l'état du ventilateur qu'ils expliquent ;
- le réglage des alertes se lit au même endroit que ce qu'il surveille, et revient de lui-même après un redémarrage du courtier.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air, la combinaison des sondes intérieures, le jour et la nuit (RG-jour-et-nuit), et les réglages de la ventilation (RG-ventilation-periodique) sont réglables à distance et par la liaison série. Le réglage des alertes l'est à distance, dans les bornes de RG-reglage-des-alertes. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air par défaut ;
- de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ;
- un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j` ;
- pour chaque sonde, le rôle `interieure` ou `exterieure`, avec au moins une sonde intérieure ;
- pour la combinaison, l'une des valeurs de RG-sondes-d-air ;
- pour le jour et la nuit, un jour `HH:MM-HH:MM` qui ne passe pas minuit, d'au moins une heure, et laissant une nuit d'au moins une heure ; en mode `saisons`, de 1 à 6 saisons, aux dates `MM-JJ` valides et toutes différentes, le 29 février exclu, chacune avec un tel jour ;
- pour la ventilation de jour et de nuit, le mode `metronome` ou `rubato`, une durée de 1 à 30 minutes et une période de 15 à 240 minutes, la durée strictement sous la période, et un écart de 10 à 50 % ;
- pour l'aération d'hibernation, une heure `HH:MM` et une durée de 1 à 30 minutes ;
- pour l'option saturation, le comportement `aeration` ou `continu`, une humidité de 80 à 100 % HR, une attente de 1 à 60 minutes, une durée de 1 à 30 minutes et une pause de 15 à 240 minutes ;
- pour les alertes, les bornes de RG-reglage-des-alertes.

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
- le chien de garde ;
- le rappel de 12 heures d'une alerte qui dure (RG-alertes-sur-telephone).

La mise en sécurité se désactive par commande, comme RG-capteur-en-defaut le prévoit, mais rien ne règle ce qu'elle fait quand elle est active.

La borne de 24 °C sur la consigne ne suit pas le seuil haut d'alerte réglé : elle reste une constante de compilation. Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni lever la coupure par le substrat, ni laisser le régulateur sans sonde pour réguler, ni faire tourner le ventilateur sans arrêt ou jamais, même par l'option saturation ou par le hasard du mode `rubato`.

Sur la liaison série, `CONFIG` suivi d'un JSON règle exactement comme `cmd/config` (décision `05-reglage-par-la-liaison-serie`).

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures ;
- le jour et la nuit ;
- les réglages de la ventilation : jour, nuit, hibernation et option saturation ;
- le réglage des alertes.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau, rôles et combinaison ensemble, jour et nuit, réglages de la ventilation ensemble, réglage des alertes — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis ;
- les plages `01:35-06:30` et `14:05-17:05` ;
- le fuseau de Paris ;
- `sht45` intérieure, `dht11` extérieure et la combinaison `priorite-sht45` ;
- le mode `metronome` et le jour `08:00-21:00` ;
- pour la ventilation de jour comme de nuit, le mode `metronome`, 5 minutes toutes les 60 minutes, un écart de 30 % ; l'aération d'hibernation à 13:00 pendant 5 minutes ; l'option saturation inactive, en `aeration`, à 95 % HR, 10 minutes d'attente, 5 minutes d'aération et 60 minutes de pause ;
- les valeurs par défaut de RG-reglage-des-alertes, toutes les alertes activées.

Un réglage de ventilation enregistré sous la forme de 2026-013 (durée, période et heure seules) n'est pas repris : le régulateur prend celui du firmware, qui lui est égal par défaut. Le décompte des aérations, l'heure de la dernière et l'attente de l'option saturation ne sont pas enregistrés : ils repartent du démarrage (RG-ventilation-periodique). Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables.

Ce que la règle protège :

- une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel ;
- un régulateur qui ne sait pas où il en est ne chauffe pas au hasard ;
- un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant ;
- des rôles illisibles ne laissent pas le régulateur sans sonde intérieure ;
- un réglage de ventilation illisible ne laisse pas le bac sans aération ;
- un réglage d'alertes illisible ne fait taire aucune alerte : elles repartent toutes activées.

### RG-capteur-en-defaut

Une mesure d'une sonde d'air est rejetée quand la sonde ne répond pas (muette), ou quand elle est impossible dans le terrarium : température hors de −20 à 60 °C, ou humidité relative hors de 0 à 100 %, bornes comprises, une valeur non numérique comptant comme hors plage. Température et humidité venant du même composant (ADR-capteur-air-sht45), une mesure rejetée l'est entière. La cause d'un rejet se dit par l'une de ces valeurs, la première qui s'applique : `muet`, `temperature-hors-plage`, `humidite-hors-plage`. Les mêmes plages valent pour les deux sondes : elles écartent ce qu'aucun terrarium ne peut connaître, non ce qu'un composant ne sait pas mesurer.

Une sonde dont les mesures sont rejetées pendant plus de 2 minutes est en défaut. Ce défaut de sonde est signalé sur la liaison série avec sa cause, et sur le courtier (RG-topics-mqtt). Pour une sonde intérieure, il est aussi signalé par la LED d'état. À lui seul, il ne coupe rien : tant qu'une autre sonde intérieure est acceptée, la régulation continue sur elle (RG-sondes-d-air).

La mise en sécurité porte sur l'air intérieur, c'est-à-dire sur l'ensemble des sondes intérieures. Elle est active par défaut. Active, elle déclare un défaut capteur quand aucune sonde intérieure n'a rendu de mesure acceptée depuis plus de 2 minutes : chauffage et pompe sont coupés, et le défaut est signalé par la LED d'état, sur la liaison série avec la cause de chaque sonde intérieure, et sur le courtier. La supervision en alerte aussi le téléphone (RG-alertes-sur-telephone), comme d'un défaut de sonde. Pendant ces 2 minutes, aucune décision nouvelle n'est prise sans mesure de l'air : les sorties gardent l'état décidé sur la dernière mesure de l'air. Une erreur passagère ne coupe donc rien. Les sorties ne reprennent que lorsqu'une sonde intérieure rend de nouveau une mesure acceptée.

La mise en sécurité se désactive et se réactive par commande (`cmd/config`, RG-topics-mqtt), et le choix est conservé en mémoire non volatile, au-delà d'une coupure de courant. Désactivée, aucun défaut capteur n'est déclaré : quand aucune sonde intérieure n'est acceptée, la régulation se poursuit sur la mesure rejetée de la sonde intérieure prioritaire, si elle en rend une. Quand toutes sont muettes, les sorties gardent la dernière décision prise, sans limite. La sonde prioritaire est celle que nomme une combinaison `priorite-…`, et la SHT45 pour `moyenne` et `plus-froide`, si elle est intérieure. Les rejets et les défauts de sonde restent signalés, LED d'état et liaison série comprises. La désactivation est elle-même signalée sur la liaison série au démarrage et publiée dans `state`, pour qu'aucun lecteur ne la croie active. La durée maximale de chauffe continue (RG-chauffe-continue-bornee) s'applique dans tous les cas.

Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle sans que son propriétaire l'ait décidé, et la panne d'une sonde ne le prive pas de régulation quand une autre la remplace. Celui qui le supervise sait, sans lire le code, quelle sonde a lâché, et s'il faut vérifier le câblage ou le capteur lui-même. Une mesure fausse mais plausible, d'une sonde décrochée dans un coin froid, n'est pas détectée (2026-001, décision 06). Avec deux sondes intérieures, elle peut l'emporter selon la combinaison : `plus-froide` retient une sonde décrochée dans un coin froid, et `moyenne` en retient la moitié de l'écart. Désactiver la mise en sécurité est un risque accepté par le propriétaire (2026-006, décision `03-lever-la-mise-en-securite`).

### RG-chauffe-continue-bornee

Le chauffage ne reste pas allumé plus de 2 heures d'affilée : au-delà, il est coupé pendant 15 minutes, et le dépassement est signalé par la LED d'état, sur la liaison série, et dans `state` par `pause_chauffage` (RG-topics-mqtt), d'où la supervision en alerte le téléphone (RG-alertes-sur-telephone). Passé ces 15 minutes, le chauffage reprend sur la consigne du mode, sans intervention, sauf si la coupure par le substrat tient encore (RG-coupure-par-le-substrat) : un verrou posé la nuit laisserait le bac refroidir jusqu'au matin, hors-gel compris. La règle borne une durée, non une température : la coupure par le substrat borne la température du substrat, mais rien de matériel ne couvre une surchauffe en phase 1 (décision `06-protection-contre-la-surchauffe`). Des coupures qui se répètent signalent une chauffe sous-dimensionnée ou un relais collé. Ce que la règle protège : une sonde décrochée ou un câble défaillant ne fait pas chauffer sans fin.
