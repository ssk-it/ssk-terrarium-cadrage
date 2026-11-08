---
id: RG-sorties-par-mode
fonctionnalites: [modes, chauffage, brumisation, eclairage]
statut: actif
cree_par: 2026-001
modifie_par: []
---

Le régulateur a trois modes, et chacun dit ce que le chauffage peut faire :

| Mode | Chauffage | Usage |
| --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Printemps-été, ou hiver chauffé |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Novembre à février |
| `MAINTENANCE` | Coupé | Nettoyage, changement de substrat |

La brumisation, l'éclairage et la ventilation restent coupés dans tous les modes : les cadrages des phases 2 et 4 leur donneront leur comportement par mode, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler ; en maintenance, rien ne s'allume pendant qu'on a les mains dans le bac.
