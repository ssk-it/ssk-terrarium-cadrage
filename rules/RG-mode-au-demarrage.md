---
id: RG-mode-au-demarrage
fonctionnalites: [modes, protections]
statut: actif
cree_par: 2026-001
modifie_par: []
---

Le mode en cours est enregistré en mémoire non volatile à chaque changement. Au démarrage, le régulateur reprend le mode enregistré ; s'il n'en trouve aucun de valide — premier démarrage, mémoire effacée ou corrompue —, il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode. Les consignes et seuils, eux, sont ceux du firmware jusqu'à ce qu'ils deviennent réglables. Ce que la règle protège : une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel, et un régulateur qui ne sait pas où il en est ne chauffe pas au hasard.
