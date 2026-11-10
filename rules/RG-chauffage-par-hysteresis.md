---
id: RG-chauffage-par-hysteresis
fonctionnalites: [chauffage]
statut: actif
cree_par: 2026-001
modifie_par: [2026-005]
---

En mode `ACTIF`, le chauffage s'allume quand la température de l'air descend sous la consigne moins l'hystérésis, et s'éteint quand elle dépasse la consigne plus l'hystérésis ; entre les deux, il garde son état. Par défaut, la consigne vaut 19 °C et l'hystérésis 0,5 °C. RG-coupure-par-le-substrat prime sur cette règle. Ce que la règle protège : l'air reste dans 18-20 °C sans que le relais batte à chaque mesure.
