---
id: RG-sorties-par-mode
fonctionnalites: [modes, chauffage, brumisation, eclairage]
statut: actif
cree_par: 2026-001
modifie_par: [2026-003]
---

Le régulateur a quatre modes, et chacun dit ce que le chauffage peut faire :

| Mode | Chauffage | Usage |
| --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Novembre à février |
| `MAINTENANCE` | Coupé | Nettoyage, changement de substrat |

La brumisation, l'éclairage et la ventilation suivent en `PLAGES` ce qu'ils font en `ACTIF` ; ils restent coupés dans tous les modes jusqu'à ce que les cadrages des phases 2 et 4 leur donnent leur comportement, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler ; en maintenance, rien ne s'allume pendant qu'on a les mains dans le bac.
