---
id: RG-jour-et-nuit
fonctionnalites: [reglages, ventilation, chauffage]
statut: actif
cree_par: 2026-015
modifie_par: []
---

Le régulateur distingue le jour et la nuit selon l'un de deux modes, réglables :

- **`metronome`** : le même jour tous les jours, écrit `HH:MM-HH:MM`.
- **`saisons`** : de 1 à 6 saisons, chacune avec sa date de début, `MM-JJ`, et son jour, `HH:MM-HH:MM`. Rangées par date, elles se suivent en boucle sur l'année. Entre le début d'une saison et celui de la suivante, le début et la fin du jour glissent jour après jour, en ligne droite, de ceux de la saison vers ceux de la suivante, arrondis à la minute ; ils les atteignent le jour où la suivante commence. Avec une seule saison, son jour vaut toute l'année. Les jours se comptent sur une année de 365 jours : le 29 février prend le jour du 28.

Le jour commence à l'heure de début, incluse, et finit à l'heure de fin, exclue ; il ne passe pas minuit, dure au moins une heure, et laisse une nuit d'au moins une heure. Le reste est la nuit. Date et heure se lisent dans le fuseau réglé (ADR-heure-par-ntp). Tant que l'heure n'est pas connue, c'est le jour.

Par défaut : `metronome`, `08:00-21:00`.

Ce que la règle protège : un rythme de jour et de nuit qui suit l'année sans saut d'un jour à l'autre, et qui ne bascule jamais dans la nuit faute d'heure.
