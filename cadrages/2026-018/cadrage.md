---
id: 2026-018
titre: 'La coupure par le substrat, réglable de jour et de nuit, et désactivable'
domaines: [regulation, securite, supervision]
liens:
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-005', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-005' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-016', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-016' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-017', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-017' }
impacts:
  - { regle: RG-coupure-par-le-substrat, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-historique-des-mesures, operation: modifie }
  - { regle: RG-resumes-de-l-historique, operation: modifie }
  - { regle: RG-jour-et-nuit, operation: touche }
  - { regle: RG-sorties-par-mode, operation: touche }
  - { regle: RG-chauffage-par-plages, operation: touche }
  - { regle: RG-chauffe-continue-bornee, operation: touche }
---

## Objectif

La coupure par le substrat protège le substrat où vivent les escargots : sa sonde, côté chaud, coupe le chauffage à 24 °C et ne le rend que sous 18,5 °C. Ces deux seuils sont des constantes du firmware ([ssk-terrarium-cadrage#2026-005](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-005)), et la changer demande de recompiler. Le propriétaire veut la régler depuis l'application, comme la consigne : des seuils pour le jour et pour la nuit, le comportement quand la sonde se tait, et la possibilité de s'en passer. Il veut aussi voir dans l'historique quand elle a coupé, et sous quels seuils.

Cela rouvre ce que 2026-005 et 2026-002 avaient fermé : en phase 1, sans limiteur matériel (sskorupski/ssk-terrarium#9, reporté), la coupure est la seule borne de température du substrat, et RG-reglages-bornes la mettait hors de portée de toute commande. Ce cadrage la rend réglable **avec des garde-fous**, choisis par le propriétaire le 13 novembre 2026 : des bornes compilées que rien ne déplace, un écart de reprise qui empêche l'oscillation, un plancher qui empêche le gel, et une désactivation qui se voit toujours. Les relevés des 24 heures précédant le 13 novembre ont ajouté une demande : ralentir la chauffe à l'approche du seuil, plutôt que de couper net et laisser l'air sans chauffe pendant des heures (décision `06-zone-d-approche`).

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| S1 | Régler la coupure sans recompiler | Activation, seuils de jour et de nuit, comportement sur sonde muette se règlent par `cmd/config` et par la liaison série, dans des bornes publiées |
| S2 | Ne pas perdre la protection par erreur | Aucun réglage n'admet une coupure au-delà de 28 °C, une reprise à moins de 2 °C sous la coupure, ni un maintien qui laisse l'air sous 4 °C ; une désactivation se publie, s'annonce et s'historise |
| S3 | Ne rien changer pour qui ne règle rien | Sans réglage, le régulateur fait exactement ce que fait 2026-005 |
| S4 | Lire la coupure dans l'historique | Les résumés portent la part du temps coupée et les seuils qui s'appliquaient, sans que l'application recalcule rien |
| S5 | Lisser les pics du substrat sans laisser l'air chuter | Une zone d'approche réglable ralentit la chauffe avant le seuil de coupure, au lieu de la couper net |

### Ce que le référentiel disait déjà

- **RG-coupure-par-le-substrat** (2026-005) : coupure à 24 °C, reprise strictement sous 18,5 °C, constantes de compilation ; sonde muette : la coupure tient 2 minutes puis se lève ; tous les modes ; pas gardée après un redémarrage ; pas un défaut. Ce cadrage la **modifie**, et rouvre les décisions `01-combinaison-air-substrat`, `02-seuil-fixe`, `03-sonde-muette` et `06-modes` de 2026-005 — voir ses décisions 01 à 05, qui disent ce qui a changé.
- **RG-reglages-bornes** (2026-002, décision `04-reglages-a-distance`) : les seuils de la coupure n'y sont pas des réglages, pour qu'« une erreur de saisie ou un compte compromis » ne puisse pas lever la coupure. Ce cadrage la **modifie** : la protection devient des bornes et une désactivation visible, et non plus une constante.
- **RG-jour-et-nuit** (2026-015) : la frontière du jour et de la nuit, et le jour tant que l'heure n'est pas connue. Les seuils de nuit la suivent sans la changer.
- **RG-sorties-par-mode**, **RG-chauffage-par-plages**, **RG-chauffe-continue-bornee** : elles renvoient à la coupure, qui prime sur le mode et sur la reprise après la pause de chauffe. Rien n'y change : elles nomment la règle, non ses seuils.
- **RG-historique-des-mesures** et **RG-resumes-de-l-historique**, dans leur texte de [ssk-terrarium-cadrage#2026-017](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-017), livré le 12 novembre 2026 : ni la coupure ni ses seuils n'y sont. Ce cadrage les y ajoute.

### Cadrages en cours qu'il côtoie

- **[ssk-terrarium-cadrage#2026-016](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-016)** (consigne de jour et de nuit, PR sskorupski/ssk-terrarium#37) réécrit RG-reglages-bornes, RG-mode-au-demarrage et RG-topics-mqtt, et garde les seuils de la coupure hors des réglages. Il limite la consigne de nuit au mode `ACTIF` ; ce cadrage applique au contraire les seuils de nuit dans tous les modes (décision `04-portee-du-jour-et-de-la-nuit`). Les deux ne se contredisent pas : la consigne dit quoi viser, la coupure dit quoi ne pas dépasser.
- **[ssk-terrarium-cadrage#2026-009](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-009)** (alertes) et **[ssk-terrarium-cadrage#2026-010](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-010)** (mise à jour à distance) réécrivent eux aussi RG-reglages-bornes, RG-topics-mqtt ou l'historique.

Les énoncés ci-dessous partent du référentiel livré. **Le cadrage qui se livre le dernier reprend les énoncés de ceux livrés avant lui** : si 2026-016 se livre d'abord, ce cadrage reprendra sa consigne de nuit dans RG-reglages-bornes, RG-mode-au-demarrage et RG-topics-mqtt avant sa propre fusion, et inversement.

### Hors périmètre

L'application sterrarium a son propre référentiel : l'interrupteur en tête de la carte du chauffage, les champs des seuils de jour et de nuit et du comportement sur sonde muette, les seuils dans le tableau de synthèse et le graphique Global, et la zone à motif de la coupure dans le couloir Chauffage s'y cadrent à part, dans `sskorupski/sterrarium-cadrage`. Ce cadrage leur fournit ce qu'elles lisent : `securite_substrat`, `seuils_substrat` et les bornes dans l'état, `coupure_substrat` et `seuils_substrat` dans les résumés.

Une alerte sur téléphone à la désactivation relève de 2026-009, encore en cours : elle n'est pas décidée ici (voir Questions ouvertes).

## Parcours utilisateur

1. Le régulateur passe au nouveau firmware. Sans réglage enregistré, il prend la coupure active, 24 °C et 18,5 °C le jour comme la nuit, `reprise-air` après 2 minutes : rien ne change pour l'élevage.
2. Le propriétaire règle la nuit à 22 °C et 18 °C. Le régulateur accepte, enregistre, et publie `securite_substrat` et, la nuit venue, `"seuils_substrat":{"coupure":22.0,"reprise":18.0}`.
3. À 23 h, le substrat atteint 22,1 °C : le chauffage est coupé, `coupure_substrat` passe à `true`. À 8 h, le jour revient : la coupure se juge sur 24 °C et 18,5 °C ; le substrat est à 20 °C, au-dessus de 18,5 : elle tient.
4. Il essaie une reprise à 23 °C pour une coupure à 24 °C : refusé en entier, `securite_substrat invalide`, rien n'est appliqué.
5. Il passe la sonde muette en `maintien`. La sonde se débranche pendant une coupure : la coupure tient. En janvier, l'air descend à 3,9 °C : la coupure se lève, et le chauffage reprend sur l'air ; l'élevage ne gèle pas.
6. Il désactive la coupure pour changer le substrat. Le régulateur publie `"active":false`, `"seuils_substrat":null`, un `event` `securite-substrat`, l'annonce sur la liaison série. Après une coupure de courant, elle est toujours désactivée, et toujours affichée comme telle.
7. Il règle une approche de 2 °C et une reprise de jour à 22 °C. L'après-midi, le substrat passe 22 °C : l'air demande toujours de la chauffe, mais le chauffage ne tourne plus qu'une part de chaque tranche de 10 minutes, la moitié à 23 °C. Le substrat se stabilise vers 23 °C sans toucher 24 °C, et l'air reçoit encore de la chaleur quand le garage se refroidit.
8. Dans l'historique, la nuit de l'étape 3 montre une part de coupure par fenêtre, et les seuils de 22 et 18 °C ; les fenêtres où la coupure était désactivée n'ont pas de seuils.

## Questions ouvertes

Ces valeurs sont des propositions de ce cadrage, à confirmer par le propriétaire avant le développement :

- **Les bornes** : coupure de 20 à 28 °C, reprise au moins 2 °C sous la coupure et pas sous 15 °C, délai de sonde muette de 1 à 30 minutes. 28 °C est la proposition : 2026-005 tenait 24 °C pour le seuil sûr, et 2026-002 tenait 24 °C pour l'alerte haute de l'air.
- **Le plancher de `maintien`** : 4 °C, le bas du hors-gel. Le haut du hors-gel, 6 °C, lèverait la coupure plus tôt.
- **La désactivation au redémarrage** : enregistrée (décision `01-interrupteur`). Une désactivation qui se lève d'elle-même au redémarrage, ou au bout d'un temps, est l'option écartée la plus proche.
- **L'approche** : de 0 à 4 °C, 0 par défaut pour que rien ne change sans réglage, avec des tranches de 10 minutes. Une approche de 2 °C par défaut lisserait d'emblée, mais changerait le comportement des régulateurs déjà en place.
- **Une alerte à la désactivation**, si 2026-009 se livre : la coupure n'y est pas une panne ; une coupure désactivée pourrait en être une.

## Énoncés

### RG-coupure-par-le-substrat

La coupure de sécurité par le substrat est active par défaut, et se désactive par réglage (RG-reglages-bornes).

Active, quand la sonde du substrat rend une mesure valide qui atteint le seuil de coupure du moment, le chauffage est coupé, quel que soit le mode. Il reste coupé jusqu'à une mesure valide du substrat strictement sous le seuil de reprise du moment ; le chauffage suit alors de nouveau son mode, sur l'air.

Les seuils se règlent pour le jour et pour la nuit (RG-jour-et-nuit), et valent dans tous les modes qui chauffent : `ACTIF`, `PLAGES` et `HIBERNATION`. Tant que l'heure n'est pas connue, ce sont ceux du jour. Par défaut, la coupure est à 24 °C et la reprise à 18,5 °C, le jour comme la nuit. Le seuil de coupure va de 20 à 28 °C, et la reprise reste au moins 2 °C en dessous, sans descendre sous 15 °C. Les seuils ne dépendent pas de la consigne. Au passage du jour à la nuit, ou de la nuit au jour, la coupure se juge sur les seuils du nouveau moment dès la mesure suivante : une coupure en cours se lève si la mesure est déjà sous la nouvelle reprise, et une mesure qui atteint la nouvelle coupure coupe.

Sous le seuil de coupure, une zone d'approche ralentit la chauffe. Sa largeur se règle de 0 à 4 °C, la même le jour et la nuit, et vaut 0 par défaut : la coupure reste alors franche. Quand une mesure valide du substrat est dans la zone, de `coupure − approche` inclus à `coupure` exclu, et que le mode demande de chauffer, le chauffage ne tourne qu'une part de chaque tranche de 10 minutes, en début de tranche : `(coupure − mesure) / approche`, arrondie à la minute. Cette part vaut 100 % à l'entrée de la zone et diminue jusqu'à 0 au seuil. Elle se calcule au début de chaque tranche, sur la dernière mesure valide. Hors de la zone, le chauffage suit son mode sans ralentir. Sans mesure valide, désactivée ou pendant une coupure, l'approche ne s'applique pas. Une tranche ralentie ne compte pas comme une chauffe continue au sens de RG-chauffe-continue-bornee : le chauffage s'y arrête.

Une mesure est valide quand la sonde répond, hors de sa valeur de mise sous tension (85 °C), et qu'elle est comprise entre −20 et 60 °C. Sans sonde, la coupure ne s'applique jamais.

Si la sonde se tait ou rend des mesures invalides pendant une coupure, le comportement réglé s'applique :

- **`reprise-air`**, par défaut : la coupure tient le délai réglé, 2 minutes par défaut, puis se lève, et l'air décide seul jusqu'au retour d'une mesure valide ;
- **`maintien`** : la coupure tient jusqu'à une mesure valide sous la reprise. Elle se lève pourtant dès que la mesure de l'air retenue pour réguler descend sous 4 °C, le bas du hors-gel de `HIBERNATION`, et l'air décide alors seul jusqu'au retour d'une mesure valide du substrat. Ce plancher n'est pas un réglage.

Désactivée, la coupure ne s'applique jamais, comme sans sonde : une coupure en cours se lève à la désactivation, et le chauffage suit son mode, sur l'air. La sonde reste relevée et publiée. La désactivation est enregistrée et survit à un redémarrage (RG-mode-au-demarrage) ; elle est annoncée sur la liaison série et sur `event`, et publiée sur `state` (RG-topics-mqtt).

La coupure en cours n'est pas gardée en mémoire : après un redémarrage, elle ne revient que sur une mesure qui atteint le seuil de coupure du moment.

La coupure prime sur le mode et sur la reprise qui suit la pause de RG-chauffe-continue-bornee ; elle n'est pas un défaut, et n'allume pas la LED d'état. Son entrée et sa sortie sont annoncées sur la liaison série, son état publié sur `state` (`coupure_substrat`), avec ses réglages (`securite_substrat`), les seuils qui s'appliquent (`seuils_substrat`) et la part de chauffe que permet l'approche (`part_substrat`) ; elle est historisée (RG-historique-des-mesures).

Le substrat se mesure côté chaud, près des câbles : il peut atteindre le seuil de coupure avant que l'air atteigne la consigne, et l'air reste alors sous la consigne jusqu'à ce que le substrat soit redescendu sous la reprise. Le propriétaire a fait passer le substrat avant l'air, et a voulu en régler les seuils, de jour et de nuit, et pouvoir s'en passer ([ssk-terrarium-cadrage#2026-018](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-018)). La coupure passe par le même firmware et le même relais que la régulation : elle ne remplace pas le limiteur matériel reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001.

Ce que la règle protège : le chauffage ne cuit pas le substrat où vivent les escargots tant que la coupure est active ; un réglage ne peut ni porter la coupure au-delà de 28 °C ni la faire osciller autour de son seuil ; l'approche laisse le substrat se stabiliser sous son seuil au lieu de le franchir, et l'air garder une chauffe réduite ; une coupure désactivée se voit ; une sonde absente ou en panne n'empêche pas de chauffer l'air, et, même maintenue, une coupure ne laisse pas l'élevage geler.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES`, le fuseau horaire, le rôle de chaque sonde d'air, la combinaison des sondes intérieures, le jour et la nuit (RG-jour-et-nuit), les réglages de la ventilation (RG-ventilation-periodique), et la coupure de sécurité par le substrat (RG-coupure-par-le-substrat) — son activation, ses seuils de jour et de nuit, son approche et son comportement quand la sonde se tait — sont réglables à distance et par la liaison série. Ils le sont dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer :

- consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute de l'air ;
- de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ;
- un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j` ;
- pour chaque sonde, le rôle `interieure` ou `exterieure`, avec au moins une sonde intérieure ;
- pour la combinaison, l'une des valeurs de RG-sondes-d-air ;
- pour le jour et la nuit, un jour `HH:MM-HH:MM` qui ne passe pas minuit, d'au moins une heure, et laissant une nuit d'au moins une heure ; en mode `saisons`, de 1 à 6 saisons, aux dates `MM-JJ` valides et toutes différentes, le 29 février exclu, chacune avec un tel jour ;
- pour la ventilation de jour et de nuit, le mode `metronome` ou `rubato`, une durée de 1 à 30 minutes et une période de 15 à 240 minutes, la durée strictement sous la période, et un écart de 10 à 50 % ;
- pour l'aération d'hibernation, une heure `HH:MM` et une durée de 1 à 30 minutes ;
- pour l'option saturation, le comportement `aeration` ou `continu`, une humidité de 80 à 100 % HR, une attente de 1 à 60 minutes, une durée de 1 à 30 minutes et une pause de 15 à 240 minutes ;
- pour la coupure par le substrat, l'activation `true` ou `false` ; pour le jour et pour la nuit, un seuil de coupure de 20 à 28 °C et un seuil de reprise de 15 °C au seuil de coupure moins 2 °C, au dixième de degré ; pour la sonde muette, le comportement `reprise-air` ou `maintien`, et un délai de 1 à 30 minutes ; une approche de 0 à 4 °C, au dixième de degré.

Les durées, périodes, attentes et pauses sont en minutes entières, l'écart et l'humidité en pour cent entiers.

Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Cela vaut aussi pour une commande qui, appliquée, ne laisserait aucune sonde intérieure, laisserait une durée de ventilation qui n'est pas strictement sous sa période, ou laisserait un seuil de reprise à moins de 2 °C sous son seuil de coupure. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile.

Ne sont pas des réglages, et aucune commande ne les modifie :

- le hors-gel de `HIBERNATION` (4-6 °C) ;
- le plancher hors plage de `PLAGES` (12-14 °C) ;
- les bornes des seuils de la coupure par le substrat (20-28 °C, 15 °C, l'écart de 2 °C) le plancher de 4 °C qui lève une coupure maintenue, et la tranche de 10 minutes de l'approche (RG-coupure-par-le-substrat) ;
- la durée maximale de chauffe continue ;
- les plages de rejet d'une mesure et le délai de 2 minutes avant un défaut (RG-capteur-en-defaut) ;
- l'écart minimal de 12 heures et le repli de 24 heures de l'aération d'hibernation (RG-ventilation-periodique) ;
- le tirage au hasard du mode `rubato`, qui ne sort jamais des bornes ci-dessus ;
- le chien de garde.

La mise en sécurité se désactive par commande, comme RG-capteur-en-defaut le prévoit, mais rien ne règle ce qu'elle fait quand elle est active.

Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne, ni laisser le substrat monter au-delà de 28 °C tant que la coupure est active, ni désactiver la coupure sans que cela se voie — sa désactivation se publie, s'annonce sur `event` et s'historise —, ni faire osciller le chauffage autour du seuil du substrat, ni laisser le régulateur sans sonde pour réguler, ni faire tourner le ventilateur sans arrêt ou jamais, même par l'option saturation ou par le hasard du mode `rubato`.

Sur la liaison série, `CONFIG` suivi d'un JSON règle exactement comme `cmd/config` (décision `05-reglage-par-la-liaison-serie`).

### RG-mode-au-demarrage

Sont enregistrés en mémoire non volatile, à chaque changement :

- le mode en cours ;
- la consigne et l'hystérésis ;
- les plages horaires et le fuseau ;
- le rôle de chaque sonde d'air et la combinaison des sondes intérieures ;
- le jour et la nuit ;
- les réglages de la ventilation : jour, nuit, hibernation et option saturation ;
- les réglages de la coupure par le substrat : activation, seuils de jour et de nuit, approche, comportement sur sonde muette.

Au démarrage, le régulateur reprend le mode enregistré. S'il n'en trouve aucun de valide (premier démarrage, mémoire effacée ou corrompue), il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode.

Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau, rôles et combinaison ensemble, jour et nuit, réglages de la ventilation ensemble, réglages de la coupure par le substrat ensemble — s'il respecte RG-reglages-bornes. Sinon, il prend celui du firmware :

- 19 °C ± 0,5 pour la consigne et l'hystérésis ;
- les plages `01:35-06:30` et `14:05-17:05` ;
- le fuseau de Paris ;
- `sht45` intérieure, `dht11` extérieure et la combinaison `priorite-sht45` ;
- le mode `metronome` et le jour `08:00-21:00` ;
- pour la ventilation de jour comme de nuit, le mode `metronome`, 5 minutes toutes les 60 minutes, un écart de 30 % ; l'aération d'hibernation à 13:00 pendant 5 minutes ; l'option saturation inactive, en `aeration`, à 95 % HR, 10 minutes d'attente, 5 minutes d'aération et 60 minutes de pause ;
- la coupure par le substrat active, à 24 °C et 18,5 °C le jour comme la nuit, sans approche, avec le comportement `reprise-air` et un délai de 2 minutes : ce qu'elle faisait avant de devenir réglable.

Un réglage de ventilation enregistré sous la forme de 2026-013 (durée, période et heure seules) n'est pas repris : le régulateur prend celui du firmware, qui lui est égal par défaut. Le décompte des aérations, l'heure de la dernière et l'attente de l'option saturation ne sont pas enregistrés : ils repartent du démarrage (RG-ventilation-periodique). Une coupure par le substrat en cours n'est pas enregistrée (RG-coupure-par-le-substrat). Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables.

Ce que la règle protège :

- une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel ;
- un régulateur qui ne sait pas où il en est ne chauffe pas au hasard ;
- un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant ;
- des rôles illisibles ne laissent pas le régulateur sans sonde intérieure ;
- un réglage de ventilation illisible ne laisse pas le bac sans aération ;
- un réglage de la coupure illisible remet la coupure active, sur ses seuils d'origine, plutôt que de la laisser désactivée.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, le jour et la nuit (`jour_nuit`), le jour d'aujourd'hui (`jour_aujourdhui`) et le moment de la journée (`moment`), les réglages de la ventilation (`ventilation`) et l'aération de saturation en cours ou non (`aeration_saturation`), l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), ses réglages (`securite_substrat`), les seuils qui s'appliquent à l'instant (`seuils_substrat`) et la part de chauffe que permet l'approche (`part_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45, activation ou désactivation de la coupure par le substrat |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide`. `jour_nuit` : objet complet, qui remplace celui en place. `ventilation` : objet partiel à deux niveaux, `{"jour":{…},"nuit":{…},"hibernation":{…},"saturation":{…}}`, chacun partiel. `securite_substrat` : objet partiel à deux niveaux, `{"active":…,"approche":…,"jour":{…},"nuit":{…},"sonde_muette":{…}}`, chacun partiel |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

`jour_nuit` publie le réglage de RG-jour-et-nuit : `{"mode":"metronome","jour":"08:00-21:00"}`, ou `{"mode":"saisons","saisons":[{"debut":"03-20","jour":"07:00-21:00"},…]}`, saisons rangées par date. `jour_aujourdhui` est le jour calculé pour la date du jour, `"HH:MM-HH:MM"`, ou `null` tant que l'heure n'est pas connue. `moment` vaut `jour` ou `nuit` ; il vaut `jour` tant que l'heure n'est pas connue.

`ventilation` publie les réglages en place de RG-ventilation-periodique : `{"jour":{"mode":…,"duree":…,"periode":…,"ecart":…},"nuit":{…},"hibernation":{"heure":"HH:MM","duree":…},"saturation":{"active":…,"comportement":…,"humidite":…,"attente":…,"duree":…,"pause":…}}`. Ce que fait le ventilateur à l'instant se lit dans `sorties.ventilateur`, et `aeration_saturation` dit si c'est l'option saturation qui le fait tourner.

`securite_substrat` publie les réglages de RG-coupure-par-le-substrat : `{"active":true,"approche":0.0,"jour":{"coupure":24.0,"reprise":18.5},"nuit":{"coupure":24.0,"reprise":18.5},"sonde_muette":{"comportement":"reprise-air","delai":2}}`, seuils et approche en °C à une décimale, délai en minutes. `seuils_substrat` publie ceux du moment de la journée, `{"coupure":…,"reprise":…}`, ou `null` quand la coupure est désactivée : c'est la seule valeur à lire pour savoir ce qui s'applique. `part_substrat` est la part de chaque tranche de 10 minutes où l'approche laisse chauffer, de 0 à 1 au centième : 1 hors de la zone, 0 pendant une coupure, et `null` quand la coupure est désactivée ou qu'aucune mesure valide du substrat n'existe. Le chauffage ne tourne que si le mode le demande : `part_substrat` dit ce que le substrat permet, `sorties.chauffage` ce qui se passe. `coupure_substrat` reste le booléen qu'il était, toujours `false` quand la coupure est désactivée.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…],"saisons_max":…,"ventilation":{"duree":[min,max],"periode":[min,max],"ecart":[min,max],"humidite":[min,max],"attente":[min,max],"pause":[min,max]},"substrat":{"coupure":[min,max],"reprise_min":…,"ecart_min":…,"delai":[min,max],"approche":[min,max],"comportements":[…]}}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. `saisons_max` est le nombre maximal de saisons. Les intervalles de `ventilation` sont admis bornes comprises, en minutes ou en pour cent entiers ; `duree` vaut pour la ventilation de jour et de nuit, l'aération d'hibernation et l'option saturation ; une durée de ventilation doit rester strictement sous sa période. Dans `substrat`, `coupure` est l'intervalle admis d'un seuil de coupure, en °C à une décimale, `reprise_min` le plus bas seuil de reprise, et `ecart_min` l'écart minimal entre la coupure et la reprise d'un même moment : la reprise doit rester au plus à `coupure − ecart_min`. `delai` est en minutes entières, `approche` en °C à une décimale. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Chaque activation ou désactivation de la coupure par le substrat, par commande ou par la liaison série, publie sur `event` : `{"evenement":"securite-substrat","active":…}`. Elle s'ajoute à la réponse de la commande, pour qu'un abonné aux seuls événements la voie sans lire les réglages.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`. Une commande `ventilation` hors bornes, mal formée, ou qui laisserait une durée au moins égale à sa période, l'est avec la raison `ventilation invalide` ; une commande `jour_nuit` hors bornes ou mal formée, avec la raison `jour_nuit invalide` ; une commande `securite_substrat` hors bornes, mal formée, ou qui laisserait une reprise à moins de `ecart_min` sous sa coupure, avec la raison `securite_substrat invalide`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité, le rôle des sondes, la ventilation ni la coupure par le substrat à la reconnexion suivante ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série ;
- les réglages de la ventilation, le moment de la journée et l'aération de saturation se lisent dans le même message que l'état du ventilateur qu'ils expliquent ;
- les seuils de la coupure qui s'appliquent se lisent dans le même message que la mesure du substrat et la coupure qu'ils expliquent, sans que personne ne recalcule le moment de la journée ;
- une coupure désactivée ne passe pas inaperçue.

### RG-historique-des-mesures

L'état que chaque régulateur publie sur `state` (RG-topics-mqtt) est historisé sur le cluster ssk-it-01, et gardé cinq ans. Au-delà, ses points s'effacent.

Telegraf lit l'état sous le compte `historique`, qui ne peut rien commander (RG-courtier-authentifie). Il en écrit les valeurs numériques dans VictoriaMetrics, une série par champ et par régulateur, `terrarium_<champ>{id="<MAC>"}` :

- la température et l'humidité de l'air retenues pour réguler, et la température du substrat ;
- la température et l'humidité de chaque sonde d'air, sous le nom que l'état publie, dans `terrarium_sonde_temperature{id, sonde}` et `terrarium_sonde_humidite{id, sonde}`. Le nom vient de l'état, et aucune liste de sondes n'est figée : une sonde que l'historique ne connaît pas encore y entre d'elle-même. Le rôle d'une sonde n'est pas une étiquette de sa série : changer son rôle ne coupe pas sa courbe en deux ;
- l'état de chaque sortie, à 1 quand elle est allumée et à 0 sinon ;
- la consigne et l'hystérésis ;
- la consigne de ventilation, `terrarium_consigne_ventilation{id}` : la part du temps d'aération que prévoit le rythme en place (RG-ventilation-periodique), de 0 à 1, calculée à chaque état reçu — `ventilation.<moment>.duree / ventilation.<moment>.periode` en `ACTIF` et en `PLAGES`, selon le `moment`, `jour` ou `nuit` ; `ventilation.hibernation.duree / 1440` en `HIBERNATION` ; 0 en `MAINTENANCE`. Le mode d'un rythme, métronome ou rubato, n'y change rien : le rubato aère en moyenne comme le métronome. L'option saturation n'y entre pas : c'est l'écart à cette consigne qui la montre. Aucun point quand `ventilation` manque, qu'un de ces champs manque ou n'est pas un nombre, que la période vaut 0, ou que le mode ou le moment est inconnu ;
- le défaut capteur, la pause de chauffe, l'heure connue et la plage en cours, à 1 ou 0 ;
- la coupure par le substrat, `terrarium_coupure_substrat{id}`, à 1 quand elle coupe le chauffage et à 0 sinon, et son activation, `terrarium_securite_substrat_active{id}`, à 1 ou 0 ;
- les seuils de coupure et de reprise qui s'appliquent, tels que l'état les publie dans `seuils_substrat`, `terrarium_substrat_coupure{id}` et `terrarium_substrat_reprise{id}`, en °C. Aucun point quand la coupure est désactivée : `seuils_substrat` vaut alors `null` ;
- la part de chauffe que permet l'approche, `terrarium_part_substrat{id}`, de 0 à 1, telle que l'état la publie dans `part_substrat` ; aucun point quand elle vaut `null` ;
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
- on voit quand le substrat a coupé le chauffage, sous quels seuils, et depuis quand la coupure était désactivée ;
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

Les mesures s'arrondissent au centième. Les parts — sorties, `coupure_substrat` et `consigne_ventilation` — s'arrondissent au millième : la part prévue se compare à celle du ventilateur, et au centième, 2 minutes par heure vaudraient 0,03 quand le ventilateur en fait 0,033, un écart qui n'existe pas.

Une série que le régulateur ne publie pas est absente du résumé, et non remplie de `null`. C'est le cas d'un substrat sans sonde, des sondes d'un firmware qui ne publie pas `sondes`, de `consigne_ventilation` pour un firmware qui ne publie pas `ventilation` sous la forme de RG-topics-mqtt, ou de `seuils_substrat` pour un firmware qui ne le publie pas. `coupure_substrat` est publié par tous les firmwares depuis 2026-005 : sa série existe avant ce cadrage. Elle n'a pas de valeurs antérieures à sa mise en service : ses premières fenêtres valent `null`. Les noms des sondes sont ceux de l'historique (RG-historique-des-mesures).

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
