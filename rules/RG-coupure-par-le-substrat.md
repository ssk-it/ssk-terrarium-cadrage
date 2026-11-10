---
id: RG-coupure-par-le-substrat
fonctionnalites: [chauffage, protections]
statut: actif
cree_par: 2026-005
modifie_par: []
---

Quand la sonde du substrat rend une mesure valide qui atteint 24 °C, le chauffage est coupé, quel que soit le mode. Il reste coupé jusqu'à une mesure valide du substrat strictement sous 18,5 °C ; le chauffage suit alors de nouveau son mode, sur l'air. Ces deux seuils sont fixés à la compilation, et ne dépendent pas de la consigne.

Une mesure est valide quand la sonde répond, hors de sa valeur de mise sous tension (85 °C), et qu'elle est comprise entre −20 et 60 °C. Sans sonde, la coupure ne s'applique jamais. Si la sonde se tait ou rend des mesures invalides pendant une coupure, celle-ci tient 2 minutes, puis se lève : l'air décide seul jusqu'au retour d'une mesure valide. La coupure n'est pas gardée en mémoire : après un redémarrage, elle ne revient que sur une mesure qui atteint 24 °C.

La coupure prime sur le mode et sur la reprise qui suit la pause de RG-chauffe-continue-bornee ; elle n'est pas un défaut, et n'allume pas la LED d'état. Son entrée et sa sortie sont annoncées sur la liaison série, son état publié sur `state` (RG-topics-mqtt).

Le substrat se mesure côté chaud, près des câbles : il peut atteindre 24 °C avant que l'air atteigne la consigne, et l'air reste alors sous la consigne jusqu'à ce que le substrat soit redescendu sous 18,5 °C. Le propriétaire a fait passer le substrat avant l'air. La coupure passe par le même firmware et le même relais que la régulation : elle ne remplace pas le limiteur matériel reporté par la décision `06-protection-contre-la-surchauffe` de 2026-001. Ce que la règle protège : le chauffage ne cuit pas le substrat où vivent les escargots, et une sonde absente ou en panne n'empêche pas de chauffer l'air.
