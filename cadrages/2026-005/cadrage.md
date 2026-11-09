---
id: 2026-005
titre: Couper le chauffage quand le substrat atteint 24 °C
domaines: [regulation, securite, supervision]
liens:
  - { tag: issue_github, nom: 'ssk-terrarium#9', url: 'https://github.com/sskorupski/ssk-terrarium/issues/9' }
  - { tag: issue_github, nom: 'ssk-terrarium#18', url: 'https://github.com/sskorupski/ssk-terrarium/issues/18' }
  - { tag: pull_request, nom: 'ssk-terrarium#19', url: 'https://github.com/sskorupski/ssk-terrarium/pull/19' }
impacts:
  - { regle: RG-coupure-par-le-substrat, operation: cree }
  - { regle: RG-mesures-periodiques, operation: modifie }
  - { regle: RG-chauffage-par-hysteresis, operation: modifie }
  - { regle: RG-chauffage-par-plages, operation: modifie }
  - { regle: RG-sorties-par-mode, operation: modifie }
  - { regle: RG-chauffe-continue-bornee, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-capteur-en-defaut, operation: touche }
  - { regle: RG-mode-au-demarrage, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
---

## Objectif

Aujourd'hui, seule la température de l'air décide du chauffage, dans tous les modes. La sonde du substrat (DS18B20, côté chaud, près des câbles chauffants) est mesurée et publiée, mais ne commande rien. Le substrat peut donc chauffer bien au-delà de l'air sans que rien ne le voie, alors que c'est là que vivent les escargots.

Ce qu'on cherche : que le substrat ne dépasse pas 24 °C du fait du chauffage, quand la sonde est présente, sans que son absence ou sa panne empêche de chauffer l'air.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| S1 | Le chauffage ne porte pas le substrat au-delà de 24 °C | Dès qu'une mesure valide du substrat atteint 24 °C, le chauffage est coupé, dans tous les modes, et le reste jusqu'à une mesure valide sous 18,5 °C |
| S2 | Une sonde absente ou muette n'empêche pas de chauffer | Sans sonde, rien ne change ; une sonde muette plus de 2 minutes lève la coupure, et l'air reprend la main |
| S3 | La coupure se voit | Son entrée et sa sortie sont annoncées sur la liaison série, et son état est publié sur `state` |

### Arbitrage d'élevage

Le substrat est mesuré côté chaud, près des câbles. S'il atteint 24 °C avant que l'air atteigne la consigne, l'air reste sous la consigne, et pour longtemps : la reprise attend que le substrat soit redescendu sous 18,5 °C. Le substrat l'emporte alors sur l'objectif O1 de [ssk-terrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001) (air à 18-20 °C). C'est un choix du propriétaire, fait en connaissance de cause le 2026-11-09.

### Ce que ce cadrage n'est pas

La coupure passe par le même ESP32, le même firmware et le même relais que la régulation. Elle ne couvre ni un relais collé, ni un firmware qui se trompe : ce n'est pas le limiteur matériel de NF2, toujours reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001, et l'issue [ssk-terrarium#9](https://github.com/sskorupski/ssk-terrarium/issues/9) reste ouverte.

### Ce que le référentiel disait déjà

- **RG-mesures-periodiques** : la sonde du substrat est optionnelle, et « son absence n'empêche pas la régulation de l'air ». Ce cadrage garde ce principe, et dit ce que fait la sonde quand elle est là.
- **RG-chauffage-par-hysteresis**, **RG-chauffage-par-plages** et **RG-sorties-par-mode** disent ce que fait le chauffage dans chaque mode, sur l'air seul. La coupure par le substrat s'ajoute au-dessus d'eux.
- **RG-chauffe-continue-bornee** fait reprendre le chauffage « sur la consigne du mode » après sa pause de 15 minutes ; la reprise cède désormais à la coupure par le substrat.
- **RG-reglages-bornes** énumère ce qui n'est pas un réglage. Les seuils du substrat s'y ajoutent, comme le plancher de `PLAGES` (décision `02-plancher-hors-plage` de 2026-003) et pour le même motif que la décision `04-reglages-a-distance` de 2026-002 : un seuil réglable à distance se règlerait aussi par erreur.
- **RG-reglages-bornes** nomme déjà 24 °C : c'est le seuil d'alerte haute **de l'air**, que consigne plus hystérésis ne doit pas atteindre. Les 24 °C de ce cadrage portent sur le **substrat**. Le chiffre est le même, les grandeurs sont deux.
- **RG-topics-mqtt**, dans l'énoncé que 2026-004 lui a donné, fixe le contenu de `state` ; ce cadrage y ajoute l'état de la coupure.
- **RG-capteur-en-defaut** ne vise que le capteur d'air : la sonde du substrat n'a pas de défaut à elle, et une sonde muette ne coupe rien.
- **ADR-regulation-par-hysteresis** : la coupure est une bande de tout-ou-rien, 24 / 18,5 °C, dans le cadre de cette décision.
- Aucun cadrage n'était en cours sur une branche du référentiel le 2026-11-09.

## Parcours utilisateur

1. La sonde du substrat est branchée, le régulateur en `ACTIF`. L'air est à 17 °C, le substrat à 20 °C : le chauffage s'allume, comme aujourd'hui.
2. Le substrat atteint 24,0 °C, l'air n'est qu'à 18,8 °C. Le chauffage se coupe. La liaison série écrit `COUPURE chauffage : substrat a 24.0 C` ; `state` publie `"coupure_substrat":true`.
3. L'air redescend à 17 °C : le chauffage reste coupé, le substrat est encore à 21 °C.
4. Le substrat passe sous 18,5 °C. La coupure se lève, la liaison série écrit `REPRISE chauffage : substrat a 18.4 C`, et l'air reprend la main : il est sous 18,5 °C, le chauffage se rallume.
5. Quand ça se passe mal :
   - La sonde n'est pas branchée : rien ne change, l'air décide seul.
   - La sonde se tait pendant la coupure : la coupure tient 2 minutes, puis se lève (`REPRISE chauffage : sonde substrat muette`), et l'air décide seul jusqu'au retour de la sonde.
   - La carte redémarre pendant la coupure : rien n'en est gardé ; la première mesure du substrat la remet en place si elle atteint 24 °C.
   - Le chauffage tourne 2 h d'affilée : la pause de 15 minutes s'applique ; à sa fin, le chauffage ne reprend pas si la coupure par le substrat tient.

## Exigences

- **F2** Mesurer la température du substrat côté chaud (sonde optionnelle). *(inchangée)*
- **F13** Couper le chauffage quand le substrat atteint 24 °C, et ne le rendre qu'à l'air sous 18,5 °C au substrat, dans tous les modes. *(ce cadrage)*

## Hors périmètre

- Une consigne de substrat, ou une régulation sur le substrat : il ne fait que couper.
- Des seuils réglables : ils sont fixés à la compilation (décision `02-seuil-fixe`).
- Le limiteur matériel (NF2, [ssk-terrarium#9](https://github.com/sskorupski/ssk-terrarium/issues/9)).
- Une alerte sur téléphone : elle viendra avec sa phase, comme pour les autres protections.

## Énoncés

### RG-coupure-par-le-substrat

Quand la sonde du substrat rend une mesure valide qui atteint 24 °C, le chauffage est coupé, quel que soit le mode. Il reste coupé jusqu'à une mesure valide du substrat strictement sous 18,5 °C ; le chauffage suit alors de nouveau son mode, sur l'air. Ces deux seuils sont fixés à la compilation, et ne dépendent pas de la consigne.

Une mesure est valide quand la sonde répond, hors de sa valeur de mise sous tension (85 °C), et qu'elle est comprise entre −20 et 60 °C. Sans sonde, la coupure ne s'applique jamais. Si la sonde se tait ou rend des mesures invalides pendant une coupure, celle-ci tient 2 minutes, puis se lève : l'air décide seul jusqu'au retour d'une mesure valide. La coupure n'est pas gardée en mémoire : après un redémarrage, elle ne revient que sur une mesure qui atteint 24 °C.

La coupure prime sur le mode et sur la reprise qui suit la pause de RG-chauffe-continue-bornee ; elle n'est pas un défaut, et n'allume pas la LED d'état. Son entrée et sa sortie sont annoncées sur la liaison série, son état publié sur `state` (RG-topics-mqtt).

Le substrat se mesure côté chaud, près des câbles : il peut atteindre 24 °C avant que l'air atteigne la consigne, et l'air reste alors sous la consigne jusqu'à ce que le substrat soit redescendu sous 18,5 °C. Le propriétaire a fait passer le substrat avant l'air. La coupure passe par le même firmware et le même relais que la régulation : elle ne remplace pas le limiteur matériel reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001. Ce que la règle protège : le chauffage ne cuit pas le substrat où vivent les escargots, et une sonde absente ou en panne n'empêche pas de chauffer l'air.

### RG-mesures-periodiques

Le régulateur mesure la température et l'humidité de l'air toutes les 30 secondes. Il mesure aussi la température du substrat côté chaud quand la sonde est présente ; son absence n'empêche pas la régulation de l'air. Quand elle est présente, la mesure du substrat peut couper le chauffage (RG-coupure-par-le-substrat).

### RG-chauffage-par-hysteresis

En mode `ACTIF`, le chauffage s'allume quand la température de l'air descend sous la consigne moins l'hystérésis, et s'éteint quand elle dépasse la consigne plus l'hystérésis ; entre les deux, il garde son état. Par défaut, la consigne vaut 19 °C et l'hystérésis 0,5 °C. RG-coupure-par-le-substrat prime sur cette règle. Ce que la règle protège : l'air reste dans 18-20 °C sans que le relais batte à chaque mesure.

### RG-chauffage-par-plages

En mode `PLAGES`, le chauffage suit jusqu'à 4 plages horaires quotidiennes. Une plage s'écrit `HH:MM-HH:MM`, à la minute, dans le fuseau réglé (ADR-heure-par-ntp) ; son début est inclus, sa fin exclue ; elle peut passer minuit (`22:00-02:00`) ; son début ne peut pas égaler sa fin. Les plages peuvent se recouvrir : on est en plage dès qu'on est dans l'une d'elles. Sans aucune plage, on n'est jamais en plage. Le firmware fournit deux plages par défaut : `01:35-06:30` et `14:05-17:05`.

- **En plage**, le chauffage suit RG-chauffage-par-hysteresis, avec la consigne et l'hystérésis réglées.
- **Hors plage**, le chauffage s'allume quand l'air descend sous 12 °C et s'éteint quand il atteint 14 °C ; entre les deux, il garde son état. Ces seuils sont fixés à la compilation.
- **Tant que l'heure n'est pas connue** depuis le démarrage (ADR-heure-par-ntp), le mode se comporte comme en plage.

RG-capteur-en-defaut, RG-chauffe-continue-bornee et RG-coupure-par-le-substrat s'appliquent en plage comme hors plage ; après la coupure de 15 minutes, le chauffage reprend sur la cible du moment, plage ou plancher, sauf coupure par le substrat. Chaque entrée et chaque sortie de plage est annoncée sur la liaison série. Ce que la règle protège : l'élevage est chauffé aux heures choisies sans que l'air passe sous 12 °C le reste du temps, et une heure inconnue ne le fait jamais descendre au plancher.

### RG-sorties-par-mode

Le régulateur a quatre modes, et chacun dit ce que le chauffage peut faire :

| Mode | Chauffage | Usage |
| --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Novembre à février |
| `MAINTENANCE` | Coupé | Nettoyage, changement de substrat |

Dans `ACTIF`, `PLAGES` et `HIBERNATION`, la coupure par le substrat prime sur ce que dit le tableau (RG-coupure-par-le-substrat). La brumisation, l'éclairage et la ventilation suivent en `PLAGES` ce qu'ils font en `ACTIF` ; ils restent coupés dans tous les modes jusqu'à ce que les cadrages des phases 2 et 4 leur donnent leur comportement, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler ; en maintenance, rien ne s'allume pendant qu'on a les mains dans le bac.

### RG-chauffe-continue-bornee

Le chauffage ne reste pas allumé plus de 2 heures d'affilée : au-delà, il est coupé pendant 15 minutes, et le dépassement est signalé par la LED d'état et sur la liaison série ; l'alerte sur téléphone s'y ajoutera avec sa phase. Passé ces 15 minutes, le chauffage reprend sur la consigne du mode, sans intervention, sauf si la coupure par le substrat tient encore (RG-coupure-par-le-substrat) : un verrou posé la nuit laisserait le bac refroidir jusqu'au matin, hors-gel compris. La règle borne une durée, non une température : la coupure par le substrat borne la température du substrat, mais rien de matériel ne couvre une surchauffe en phase 1 (décision `06-protection-contre-la-surchauffe`). Des coupures qui se répètent signalent une chauffe sous-dimensionnée ou un relais collé. Ce que la règle protège : une sonde décrochée ou un câble défaillant ne fait pas chauffer sans fin.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES` et le fuseau horaire sont réglables à distance et par la liaison série, dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer : consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ; de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ; un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j`. Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile. Le hors-gel de `HIBERNATION` (4-6 °C), le plancher hors plage de `PLAGES` (12-14 °C), les seuils de la coupure par le substrat (24 °C et 18,5 °C), la durée maximale de chauffe continue, la coupure sur capteur en défaut et le chien de garde ne sont pas des réglages : aucune commande ne les modifie. Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni lever la coupure par le substrat.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, coupure par le substrat ou non (`coupure_substrat`), temps depuis le démarrage, version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ) |

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…}`, où `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale ; consigne plus hystérésis doit rester strictement sous `somme_max` ; `plages_max` est le nombre maximal de plages et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. Elles ne se règlent par aucune commande.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode à la reconnexion suivante ; lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique.
