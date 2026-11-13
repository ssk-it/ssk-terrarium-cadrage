---
id: RG-coupure-par-le-substrat
fonctionnalites: [chauffage, protections]
statut: actif
cree_par: 2026-005
modifie_par: [2026-018]
---

La coupure de sécurité par le substrat est active par défaut, et se désactive par réglage (RG-reglages-bornes).

Active, quand la sonde du substrat rend une mesure valide qui atteint le seuil de coupure du moment, le chauffage est coupé, quel que soit le mode. Il reste coupé jusqu'à une mesure valide du substrat strictement sous le seuil de reprise du moment ; le chauffage suit alors de nouveau son mode, sur l'air.

Les seuils se règlent pour le jour et pour la nuit (RG-jour-et-nuit), et valent dans tous les modes qui chauffent : `ACTIF`, `PLAGES` et `HIBERNATION`. Tant que l'heure n'est pas connue, ce sont ceux du jour. Par défaut, la coupure est à 24 °C et la reprise à 18,5 °C, le jour comme la nuit. Le seuil de coupure va de 20 à 28 °C, et la reprise reste au moins 2 °C en dessous, sans descendre sous 15 °C. Les seuils ne dépendent pas de la consigne. Au passage du jour à la nuit, ou de la nuit au jour, la coupure se juge sur les seuils du nouveau moment dès la mesure suivante : une coupure en cours se lève si la mesure est déjà sous la nouvelle reprise, et une mesure qui atteint la nouvelle coupure coupe.

Sous le seuil de coupure, une zone d'approche ralentit la chauffe. Sa largeur se règle de 0 à 4 °C, la même le jour et la nuit, et vaut 0 par défaut : la coupure reste alors franche. Quand une mesure valide du substrat est dans la zone, de `coupure − approche` inclus à `coupure` exclu, et que le mode demande de chauffer, le chauffage ne tourne qu'une part de chaque tranche de 10 minutes, en début de tranche : `(coupure − mesure) / approche`, arrondie à la minute. Une tranche commence quand la mesure est dans la zone et que le mode demande de chauffer, la suivante à la fin de la précédente ; sortir de la zone, ou couper, met fin à la tranche. Cette part vaut 100 % à l'entrée de la zone et diminue jusqu'à 0 au seuil. Elle se calcule au début de chaque tranche, sur la dernière mesure valide. Hors de la zone, le chauffage suit son mode sans ralentir. Sans mesure valide, désactivée ou pendant une coupure, l'approche ne s'applique pas. Une tranche ralentie ne compte pas comme une chauffe continue au sens de RG-chauffe-continue-bornee : le chauffage s'y arrête.

Une mesure est valide quand la sonde répond, hors de sa valeur de mise sous tension (85 °C), et qu'elle est comprise entre −20 et 60 °C. Sans sonde, la coupure ne s'applique jamais.

Si la sonde se tait ou rend des mesures invalides pendant une coupure, le comportement réglé s'applique :

- **`reprise-air`**, par défaut : la coupure tient le délai réglé, 2 minutes par défaut, puis se lève, et l'air décide seul jusqu'au retour d'une mesure valide ;
- **`maintien`** : la coupure tient jusqu'à une mesure valide sous la reprise. Elle se lève pourtant dès que la mesure de l'air retenue pour réguler descend sous 4 °C, le bas du hors-gel de `HIBERNATION`, et l'air décide alors seul jusqu'au retour d'une mesure valide du substrat. Ce plancher n'est pas un réglage.

Désactivée, la coupure ne s'applique jamais, comme sans sonde : une coupure en cours se lève à la désactivation, et le chauffage suit son mode, sur l'air. La sonde reste relevée et publiée. La désactivation est enregistrée et survit à un redémarrage (RG-mode-au-demarrage) ; elle est annoncée sur la liaison série et sur `event`, et publiée sur `state` (RG-topics-mqtt).

La coupure en cours n'est pas gardée en mémoire : après un redémarrage, elle ne revient que sur une mesure qui atteint le seuil de coupure du moment.

La coupure prime sur le mode et sur la reprise qui suit la pause de RG-chauffe-continue-bornee ; elle n'est pas un défaut, et n'allume pas la LED d'état. Son entrée et sa sortie sont annoncées sur la liaison série, son état publié sur `state` (`coupure_substrat`), avec ses réglages (`securite_substrat`), les seuils qui s'appliquent (`seuils_substrat`) et la part de chauffe que permet l'approche (`part_substrat`) ; elle est historisée (RG-historique-des-mesures).

Le substrat se mesure côté chaud, près des câbles : il peut atteindre le seuil de coupure avant que l'air atteigne la consigne, et l'air reste alors sous la consigne jusqu'à ce que le substrat soit redescendu sous la reprise. Le propriétaire a fait passer le substrat avant l'air, et a voulu en régler les seuils, de jour et de nuit, et pouvoir s'en passer ([ssk-terrarium-cadrage#2026-018](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-018)). La coupure passe par le même firmware et le même relais que la régulation : elle ne remplace pas le limiteur matériel reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001.

Ce que la règle protège : le chauffage ne cuit pas le substrat où vivent les escargots tant que la coupure est active ; un réglage ne peut ni porter la coupure au-delà de 28 °C ni la faire osciller autour de son seuil ; l'approche laisse le substrat se stabiliser sous son seuil au lieu de le franchir, et l'air garder une chauffe réduite ; une coupure désactivée se voit ; une sonde absente ou en panne n'empêche pas de chauffer l'air, et, même maintenue, une coupure ne laisse pas l'élevage geler.
