---
id: 01-portee-du-jour-et-de-la-nuit
titre: Où la consigne de jour et de nuit s'applique-t-elle, et comment le contrat la porte-t-il ?
statut: retenue
option_retenue: actif-seul-consigne-de-jour-conservee
---

## Description

Le mode `PLAGES` fait déjà varier le chauffage selon l'heure : consigne en plage, plancher de 12 à 14 °C hors plage. Une consigne de nuit le recoupe. Et `consigne` et `hysteresis` sont déjà lues et réglées par l'application sterrarium.

## Options

### plages-absorbe

`PLAGES` disparaît au profit du jour et de la nuit : le jour, la consigne de jour ; la nuit, celle de nuit.

**Pour** — un seul mécanisme horaire pour le chauffage.
**Contre** — `PLAGES` chauffe aux heures creuses de l'électricité, sans rapport avec le jour ; ses plusieurs plages ne tiennent pas dans un jour et une nuit. Un mode livré qui disparaît.

### deux-paires-renommees

`consigne_jour` et `consigne_nuit` remplacent `consigne` dans le contrat.

**Pour** — un contrat symétrique.
**Contre** — l'application sterrarium, qui règle `consigne`, cesserait de fonctionner au déploiement du firmware.

### actif-seul-consigne-de-jour-conservee

**Retenue.** La consigne de nuit ne vaut qu'en `ACTIF`. `PLAGES` garde son comportement, avec la consigne de jour en plage. `consigne` et `hysteresis` restent les valeurs de jour ; la nuit s'ajoute dans `chauffage_nuit`.

**Pour** — rien ne casse : ni `PLAGES`, ni l'application ; la nuit par défaut égale au jour.
**Contre** — un contrat asymétrique : le jour au premier niveau, la nuit dans un objet.

## Décision

`actif-seul-consigne-de-jour-conservee`, au choix du propriétaire. Ce qui a tranché : ajouter la nuit sans rien retirer à ce qui est livré, ni au firmware ni à l'application.
