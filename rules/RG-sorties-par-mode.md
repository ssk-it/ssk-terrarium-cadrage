---
id: RG-sorties-par-mode
fonctionnalites: [modes, chauffage, brumisation, eclairage, ventilation]
statut: actif
cree_par: 2026-001
modifie_par: [2026-003, 2026-005, 2026-013]
---

Le régulateur a quatre modes, et chacun dit ce que le chauffage et le ventilateur peuvent faire :

| Mode | Chauffage | Ventilateur | Usage |
| --- | --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Une aération par période (RG-ventilation-periodique) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Comme en `ACTIF`, en plage comme hors plage | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Une aération par jour (RG-ventilation-periodique) | Novembre à février |
| `MAINTENANCE` | Coupé | Coupé | Nettoyage, changement de substrat |

Dans `ACTIF`, `PLAGES` et `HIBERNATION`, la coupure par le substrat prime sur ce que dit le tableau pour le chauffage (RG-coupure-par-le-substrat). La brumisation et l'éclairage suivent en `PLAGES` ce qu'ils font en `ACTIF` ; ils restent coupés dans tous les modes jusqu'à ce que les cadrages des phases 2 et 4 leur donnent leur comportement, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler, et l'air du bac se renouvelle encore ; en maintenance, rien ne s'allume ni ne tourne pendant qu'on a les mains dans le bac.
