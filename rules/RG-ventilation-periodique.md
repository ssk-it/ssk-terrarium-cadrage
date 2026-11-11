---
id: RG-ventilation-periodique
fonctionnalites: [ventilation, modes, reglages]
statut: actif
cree_par: 2026-013
modifie_par: []
---

Le ventilateur renouvelle l'air du bac selon trois réglages :

- `duree` : combien de minutes dure une aération ;
- `periode` : en `ACTIF` et en `PLAGES`, toutes les combien de minutes une aération commence ;
- `heure` : en `HIBERNATION`, l'heure de l'aération quotidienne, écrite `HH:MM` dans le fuseau réglé (ADR-heure-par-ntp).

Par défaut, 5 minutes toutes les 60 minutes, et l'aération d'hibernation à 13:00. Les trois se règlent dans les bornes de RG-reglages-bornes.

Ce que fait le ventilateur selon le mode :

| Mode | Ventilateur |
| --- | --- |
| `ACTIF`, `PLAGES` | Les périodes se comptent depuis le démarrage ou le dernier changement de mode. Le ventilateur tourne les `duree` premières minutes de chaque période |
| `HIBERNATION` | Une aération de `duree` minutes par jour. Heure connue : elle commence à `heure`. Heure inconnue : 24 h après le début de la précédente, ou 24 h après le démarrage ou l'entrée dans le mode s'il n'y en a pas eu. Une aération ne commence jamais moins de 12 h après le début de la précédente |
| `MAINTENANCE` | Coupé, y compris au milieu d'une aération |

Un réglage accepté s'applique dès la mesure suivante, sans relancer le décompte : une aération en cours s'arrête dès qu'elle a atteint la durée réglée. Le ventilateur ne dépend d'aucune mesure : le défaut d'une sonde, la mise en sécurité et la coupure par le substrat n'y changent rien. Chaque mise en marche et chaque arrêt sont annoncés sur la liaison série, `VENTILATION marche` et `VENTILATION arret`.

Ce que la règle protège : l'air confiné et saturé du bac se renouvelle, sans se dessécher, y compris pendant les mois d'hibernation ; une heure perdue ne fait pas sauter l'aération quotidienne ; rien ne tourne pendant qu'on a les mains dans le bac.
