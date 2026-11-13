---
id: RG-ventilation-periodique
fonctionnalites: [ventilation, modes, reglages]
statut: actif
cree_par: 2026-013
modifie_par: [2026-015]
---

Le ventilateur renouvelle l'air du bac selon le mode :

| Mode | Ventilateur |
| --- | --- |
| `ACTIF`, `PLAGES` | Il suit les réglages du moment de la journée, `jour` ou `nuit` (RG-jour-et-nuit) |
| `HIBERNATION` | Une aération par jour, de jour comme de nuit, réglée par `hibernation` |
| `MAINTENANCE` | Coupé, même au milieu d'une aération, option saturation comprise |

**En `ACTIF` et en `PLAGES`**, `jour` et `nuit` portent chacun un mode, une durée, une période et un écart :

- **`metronome`** : chaque aération dure `duree` minutes, et la suivante commence `periode` minutes après le début de la précédente.
- **`rubato`** : chaque aération tire au hasard sa durée entre `duree` × (1 − `ecart`) et `duree` × (1 + `ecart`), et l'intervalle jusqu'au début de la suivante entre `periode` × (1 − `ecart`) et `periode` × (1 + `ecart`), arrondis à la minute, puis ramenés dans les bornes de RG-reglages-bornes, la durée strictement sous l'intervalle. En moyenne, l'air se renouvelle comme en métronome ; jamais deux fois au même rythme.

La première aération commence au démarrage et à chaque changement de mode. La durée d'une aération et l'intervalle jusqu'à la suivante se fixent à son début, avec les réglages du moment de la journée à cet instant : un réglage accepté, ou le passage du jour à la nuit, vaut à partir de l'aération suivante.

**En `HIBERNATION`**, une aération de `hibernation.duree` minutes par jour. Heure connue : elle commence à `hibernation.heure`, dans le fuseau réglé. Heure inconnue : 24 h après le début de la précédente, ou après le démarrage ou l'entrée dans le mode s'il n'y en a pas eu. Une aération ne commence jamais moins de 12 h après le début de la précédente.

**L'option `saturation`**, inactive par défaut, vaut en `ACTIF`, `PLAGES` et `HIBERNATION`. Elle se déclenche quand toutes les mesures de l'air (RG-sondes-d-air) depuis `attente` minutes ont une humidité d'au moins `humidite` % HR ; une mesure en dessous, ou une mesure de l'air manquante, recommence l'attente. Déclenchée, elle fait tourner le ventilateur selon son `comportement` :

- **`aeration`** : pendant `duree` minutes ;
- **`continu`** : tant que l'humidité reste d'au moins `humidite` % HR, et au plus `duree` minutes ; une mesure en dessous, ou manquante, l'arrête.

Puis l'attente ne reprend qu'après `pause` minutes. Pendant qu'elle tourne, l'option saturation l'emporte sur le jour, la nuit et l'hibernation, qui continuent leur décompte. Le ventilateur ne dépend d'aucune autre mesure : le défaut d'une sonde, la mise en sécurité et la coupure par le substrat n'y changent rien.

Par défaut, `jour` et `nuit` valent `metronome`, 5 minutes toutes les 60 minutes, avec un écart de 30 % ; `hibernation` vaut 13:00 et 5 minutes ; `saturation` est inactive, en `aeration`, à 95 % HR, avec 10 minutes d'attente, 5 minutes d'aération et 60 minutes de pause. Chaque mise en marche et chaque arrêt sont annoncés sur la liaison série, `VENTILATION marche` et `VENTILATION arret`, suivis de `(saturation)` quand c'est l'option qui les cause.

Ce que la règle protège : l'air confiné et saturé du bac se renouvelle sans se dessécher, plus le jour que la nuit si on le veut, et sans régularité mécanique ; une heure perdue ne fait pas sauter l'aération d'hibernation ; un air saturé ne le reste pas, sans que le ventilateur tourne sans fin ; rien ne tourne pendant qu'on a les mains dans le bac.
