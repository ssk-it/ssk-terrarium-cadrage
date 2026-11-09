---
id: RG-reglages-bornes
fonctionnalites: [reglages, protections]
statut: actif
cree_par: 2026-002
modifie_par: [2026-003]
---

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES` et le fuseau horaire sont réglables à distance et par la liaison série, dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer : consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute ; de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ; un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j`. Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile. Le hors-gel de `HIBERNATION` (4-6 °C), le plancher hors plage de `PLAGES` (12-14 °C), la durée maximale de chauffe continue, la coupure sur capteur en défaut et le chien de garde ne sont pas des réglages : aucune commande ne les modifie. Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne.
