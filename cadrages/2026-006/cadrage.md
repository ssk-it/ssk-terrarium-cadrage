---
id: 2026-006
titre: Dire pourquoi la mesure de l'air est rejetée, et permettre de lever la mise en sécurité d'une sonde
domaines: [securite, supervision]
liens:
  - { tag: issue_github, nom: 'ssk-terrarium#20', url: 'https://github.com/sskorupski/ssk-terrarium/issues/20' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-003', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-003' }
impacts:
  - { regle: RG-capteur-en-defaut, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-chauffe-continue-bornee, operation: touche }
---

## Objectif

Le 9 novembre 2026, l'application sterrarium affichait « Défaut capteur — le chauffage est coupé tant qu'une mesure fiable manque » : le terrarium, en mode ACTIF avec une consigne de 19 °C, était à 15,2 °C selon le capteur, chauffage coupé. Rien ne disait pourquoi la mesure était refusée. Il a fallu lire l'état retenu sur le courtier, puis le code du firmware, pour comprendre : le capteur d'air rendait 102 % d'humidité, une valeur impossible, vraisemblablement un SHT45 trempé de condensation. La température, elle, restait plausible, et le terrarium a refroidi sans que rien ne puisse le réchauffer à distance.

Deux besoins en découlent :

- **savoir pourquoi.** Celui qui regarde son terrarium à distance doit savoir, sans lire le code, si le capteur ne répond plus ou s'il répond une valeur impossible, et laquelle : ce n'est pas le même geste qui le rétablit (vérifier un câble, sécher ou déplacer le capteur) ;
- **pouvoir passer outre.** Le propriétaire veut pouvoir, depuis l'application, désactiver la mise en sécurité d'une sonde, et la réactiver, pour que le chauffage reprenne quand il juge le défaut sans danger.

L'incident a montré deux autres écarts :

- **une mesure rejetée était publiée telle quelle.** RG-topics-mqtt veut `null` pour une mesure invalide, mais le firmware ne mettait à `null` que la mesure illisible sur le bus, non celle qu'il rejette comme impossible : `"air":{"temperature":15.2,"humidite":102}` côtoyait `"defaut_capteur":true` ;
- **les plages de plausibilité ne figuraient que dans le code** (`sensor_watch.cpp`). RG-capteur-en-defaut parlait d'une « valeur aberrante » sans dire laquelle.

Ce que le référentiel disait déjà : RG-capteur-en-defaut (délai de 2 minutes, chauffage et pompe coupés), RG-topics-mqtt (`null` si invalides, `defaut_capteur` booléen), RG-chauffe-continue-bornee (qui borne une durée, non une température), ADR-capteur-air-sht45 et la décision `06-protection-contre-la-surchauffe` de 2026-001 (aucune protection matérielle contre la surchauffe en phase 1), non rouvertes. Le cadrage 2026-005, en cours sur sa branche, modifie aussi RG-topics-mqtt pour y ajouter `coupure_substrat` : celui des deux qui est livré en second reprend dans son énoncé le champ de l'autre. La sonde du substrat n'a pas de défaut à elle (2026-005) : l'interrupteur ne porte aujourd'hui que sur la sonde d'air.

## Parcours utilisateur

1. Le capteur d'air rend une humidité de 102 %.
2. Dès la mesure suivante, le régulateur publie dans `state` l'air à `null` et `cause_mesure_air` à `humidite-hors-plage` ; `defaut_capteur` reste à `false` pendant les 2 minutes de tolérance, les sorties gardent leur état.
3. Passé 2 minutes, `defaut_capteur` passe à `true`, chauffage et pompe sont coupés ; la cause reste publiée, et la liaison série la nomme.
4. L'application de supervision affiche le défaut avec sa cause, en clair, et propose de désactiver la mise en sécurité de la sonde d'air, en disant ce que cela coûte.
5. Le propriétaire la désactive : l'application publie `{"mise_en_securite":{"air":false}}` sur `cmd/config`. Le régulateur l'enregistre, répond sur `event`, et publie `"mise_en_securite":{"air":false}` dans `state`. `defaut_capteur` repasse à `false` ; le chauffage reprend sur la valeur de la mesure rejetée, ici 15,2 °C. `cause_mesure_air` reste publiée tant que la mesure est rejetée.
6. Le capteur sèche : `cause_mesure_air` revient à `null`. La mise en sécurité reste désactivée tant que le propriétaire ne la réactive pas, coupure de courant comprise ; l'application le rappelle en permanence.
7. Le propriétaire la réactive par `{"mise_en_securite":{"air":true}}`.
8. Si le capteur se tait (câble débranché, bus I2C bloqué), la cause est `muet`. Mise en sécurité active, le défaut est déclaré au bout de 2 minutes. Désactivée, le chauffage garde indéfiniment la dernière décision prise, que seule la durée maximale de chauffe continue interrompt.

## Énoncés

### RG-capteur-en-defaut

Une mesure de l'air est rejetée quand le capteur ne répond pas (muet), ou quand elle est impossible dans le terrarium : température hors de −20 à 60 °C, ou humidité relative hors de 0 à 100 %, bornes comprises, une valeur non numérique comptant comme hors plage. Température et humidité venant du même composant (ADR-capteur-air-sht45), une mesure rejetée l'est entière. La cause d'un rejet se dit par l'une de ces valeurs, la première qui s'applique : `muet`, `temperature-hors-plage`, `humidite-hors-plage`.

La mise en sécurité de la sonde d'air est active par défaut. Active, un capteur d'air dont les mesures sont rejetées pendant plus de 2 minutes est en défaut : chauffage et pompe sont coupés, et le défaut est signalé par la LED d'état, sur la liaison série avec sa cause, et sur le courtier (RG-topics-mqtt) ; l'alerte sur téléphone s'y ajoutera avec sa phase. Pendant ces 2 minutes, aucune décision nouvelle n'est prise sur une mesure rejetée : les sorties gardent l'état décidé sur la dernière mesure acceptée. Une erreur passagère ne coupe donc rien. Les sorties ne reprennent que lorsque le capteur rend de nouveau des mesures acceptées.

La mise en sécurité se désactive et se réactive par commande (`cmd/config`, RG-topics-mqtt), sonde par sonde, et le choix est conservé en mémoire non volatile, au-delà d'une coupure de courant. Désactivée, aucun défaut n'est déclaré pour cette sonde : la régulation se poursuit sur la mesure rejetée quand le capteur en rend une, et quand il est muet les sorties gardent la dernière décision prise, sans limite. Le rejet reste signalé, LED d'état et liaison série comprises, et la désactivation est elle-même signalée sur la liaison série au démarrage et publiée dans `state`, pour qu'aucun lecteur ne la croie active. La durée maximale de chauffe continue (RG-chauffe-continue-bornee) s'applique dans tous les cas.

Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle sans que son propriétaire l'ait décidé, et celui qui le supervise sait, sans lire le code, s'il faut vérifier le câblage ou le capteur lui-même. Les plages sont larges à dessein : elles écartent ce qu'aucun terrarium ne peut connaître, non ce qui serait seulement inhabituel ; une mesure fausse mais plausible, d'un capteur décroché dans un coin froid, n'est pas détectée (2026-001, décision 06). Désactiver la mise en sécurité est un risque accepté par le propriétaire (décision `03-lever-la-mise-en-securite`) : sans protection matérielle, une mesure fausse peut alors faire chauffer sans fin, à la seule coupure de 15 minutes toutes les 2 heures près.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides ou rejetées), cause du rejet de la mesure de l'air (`cause_mesure_air`), mise en sécurité de chaque sonde (`mise_en_securite`), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, temps depuis le démarrage, version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ), `mise_en_securite` (objet partiel `{"air":true\|false}`) |

`cause_mesure_air` vaut `null` quand la dernière mesure de l'air a été acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut : `muet`, `temperature-hors-plage` ou `humidite-hors-plage`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés par un défaut de sonde ; la cause, elle, se publie dès la première mesure rejetée. `mise_en_securite` publie l'état de chaque sonde qui en a une, aujourd'hui `{"air":true}` ou `{"air":false}`.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…}`, où `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale ; consigne plus hystérésis doit rester strictement sous `somme_max` ; `plages_max` est le nombre maximal de plages et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. Elles ne se règlent par aucune commande.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode ni la mise en sécurité à la reconnexion suivante ; lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ; une valeur rejetée n'est jamais lue comme une mesure courante, et la cause du rejet comme la mise en sécurité se lisent dans le même message que le défaut qu'elles expliquent.
