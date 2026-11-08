---
id: RG-mode-au-demarrage
fonctionnalites: [modes, protections]
statut: actif
cree_par: 2026-001
modifie_par: [2026-002]
---

Le mode en cours, la consigne et l'hystérésis du chauffage sont enregistrés en mémoire non volatile à chaque changement. Au démarrage, le régulateur reprend le mode enregistré ; s'il n'en trouve aucun de valide — premier démarrage, mémoire effacée ou corrompue —, il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode. Il reprend la consigne et l'hystérésis enregistrées si elles respectent RG-reglages-bornes, et sinon celles du firmware. Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables. Ce que la règle protège : une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel, un régulateur qui ne sait pas où il en est ne chauffe pas au hasard, et un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant.
