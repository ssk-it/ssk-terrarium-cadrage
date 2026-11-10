---
id: 01-reglage-de-la-ventilation
titre: La ventilation se règle-t-elle, et sous quelle forme ?
statut: retenue
option_retenue: bloc-commun
---

## Description

F10 fixe 5 minutes par heure en `ACTIF` et 5 minutes par jour en `HIBERNATION`, et la piste #9 les recopie sans les rendre réglables. Le firmware les porte en constantes, avec la mention « à valider » : personne n'a mesuré ce qu'il faut à ce bac pour renouveler son air sans le dessécher. Il fallait dire si ces valeurs restent figées, et, sinon, sous quelle forme l'application sterrarium les règle.

## Options

### valeurs-fixes

Les valeurs de F10 restent des constantes de compilation, comme les seuils du hors-gel. L'application ne fait qu'afficher l'état du ventilateur.

**Pour** — aucune commande ni aucune borne nouvelle, un contrat MQTT inchangé à `sorties.ventilateur` près.
**Contre** — chaque essai demande un téléversement par câble, et l'application n'a rien à régler. Le propriétaire a écarté cette option : les valeurs sont précisément celles qu'il veut ajuster en observant l'élevage.

### par-mode

`{"ventilation":{"actif":{"duree":…,"periode":…},"hibernation":{"duree":…}}}` : la durée d'hibernation se règle à part de celle d'activité.

**Pour** — l'aération d'hibernation peut être plus courte, ou plus longue, que celle d'activité.
**Contre** — deux blocs à borner, à enregistrer et à afficher, pour un besoin que rien n'a encore montré. F10 donne la même durée aux deux modes.

### bloc-commun

**Retenue.** Un seul objet `ventilation`, `{"duree":…,"periode":…,"heure":"HH:MM"}`. La durée vaut pour tous les modes ventilés ; la période règle `ACTIF` et `PLAGES` ; l'heure place l'aération quotidienne de `HIBERNATION` (décision `03-calage-de-l-aeration-quotidienne`). La commande est partielle, comme `sondes`, et le firmware vérifie le bloc tel qu'il serait une fois appliqué.

**Pour** — un réglage, un formulaire côté application, un enregistrement d'un seul tenant, comme le formulaire commun des sondes (sterrarium 2026-004, décision `01-un-formulaire-pour-les-sondes`). La contrainte qui lie durée et période se vérifie sur un seul objet.
**Contre** — la durée d'hibernation ne se distingue pas de celle d'activité. Si le besoin apparaît, un champ s'ajoutera à l'objet sans casser les commandes existantes.

## Décision

`bloc-commun`, au choix du propriétaire. Ce qui a tranché : les valeurs de F10 sont à éprouver, et ce qui s'éprouve doit se régler sans téléverser ; une durée commune suffit tant que rien ne montre qu'il en faut deux.
