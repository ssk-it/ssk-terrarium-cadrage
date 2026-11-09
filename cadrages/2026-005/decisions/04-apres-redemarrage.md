---
id: 04-apres-redemarrage
titre: La coupure survit-elle à un redémarrage ?
statut: retenue
option_retenue: recalculee
---

## Description

Un redémarrage pendant une coupure, avec un substrat entre 18,5 et 24 °C : faut-il retrouver la coupure ?

## Options

### recalculee

**Retenue.** Rien n'est gardé : la coupure ne revient que si une mesure atteint 24 °C.

**Pour** — rien de plus en mémoire non volatile ; même comportement qu'au premier démarrage.
**Contre** — après un redémarrage, l'air peut rechauffer un substrat encore à 23 °C.

### gardee-en-memoire

L'état de la coupure s'enregistre en mémoire non volatile et se reprend au démarrage.

**Pour** — la reprise sous 18,5 °C est tenue même à travers un redémarrage.
**Contre** — une écriture en mémoire à chaque entrée et sortie de coupure, et un état de plus à valider au démarrage.

## Décision

`recalculee`, choisie par le propriétaire le 2026-11-09. Ce qui a tranché : la simplicité ; le substrat qui remonte à 24 °C remet la coupure en place.
