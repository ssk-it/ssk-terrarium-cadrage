---
id: 01-definir-le-jour
titre: Comment le régulateur sait-il s'il fait jour ou nuit ?
statut: retenue
option_retenue: metronome-ou-saisons
---

## Description

La ventilation de jour et de nuit, puis la consigne de jour et de nuit, demandent une frontière entre les deux. Aucune règle ne la posait : l'éclairage, qui en aurait donné une, n'est pas cadré (piste #8). Le propriétaire veut un rythme qui suive l'année.

## Options

### heures-fixes

Un seul jour `HH:MM-HH:MM`, tous les jours de l'année.

**Pour** — un réglage, rien à calculer.
**Contre** — le jour d'hiver dure autant que celui d'été. C'est le mode `metronome` de l'option retenue, pas tout le besoin.

### lever-et-coucher-du-soleil

Le régulateur calcule le lever et le coucher du soleil à partir d'une latitude et d'une longitude.

**Pour** — le rythme réel du lieu, sans rien régler d'autre que la position.
**Contre** — le bac vit dans un garage : le propriétaire veut choisir son rythme, pas le subir ; un calcul astronomique pour un réglage qu'on voudra de toute façon décaler.

### suivre-l-eclairage

Le jour est la plage où l'éclairage est allumé.

**Pour** — une seule source pour la lumière et le rythme.
**Contre** — l'éclairage n'est pas cadré ; la ventilation attendrait un chantier sans rapport.

### metronome-ou-saisons

**Retenue.** Deux modes : `metronome`, un jour fixe ; `saisons`, de 1 à 6 saisons datées, chacune avec son jour, entre lesquelles le début et la fin du jour glissent en ligne droite, jour après jour.

**Pour** — le rythme de l'année, sans saut, aux horaires que choisit le propriétaire ; le métronome reste pour qui n'en veut pas. L'éclairage pourra suivre ce même jour quand il sera cadré.
**Contre** — un réglage plus riche à valider et à publier : 6 saisons allongent `state`.

## Décision

`metronome-ou-saisons`, à la demande du propriétaire, avec 6 saisons au plus, à son choix. Ce qui a tranché : un rythme qui s'allonge et se raccourcit avec l'année, sans dépendre ni d'un calcul astronomique ni d'un éclairage pas encore cadré. Sans heure, c'est le jour : le comportement le plus proche de celui d'aujourd'hui.
