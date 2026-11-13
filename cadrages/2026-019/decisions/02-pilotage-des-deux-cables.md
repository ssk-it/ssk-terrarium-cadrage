---
id: 02-pilotage-des-deux-cables
titre: Sur quelle mesure chaque câble chauffe-t-il, et qu'est-ce que la coupure par le substrat coupe ?
statut: retenue
option_retenue: le-mode-pour-les-deux-le-substrat-pour-le-bas
---

## Description

Avec deux sorties de chauffage, il faut dire ce qui allume chacune. 2026-005 (décision `01-combinaison-air-substrat`) et 2026-007 (décision `02-combinaison-des-sondes`) avaient posé un principe, pour une seule sortie : une seule mesure décide, jamais deux déclencheurs, pour que ce que fait le chauffage se lise sur une seule courbe. 2026-005 avait aussi fait accepter au propriétaire que l'air reste sous la consigne pendant une coupure.

Les relevés du 12 au 13 novembre 2026 montrent ce que coûte ce compromis. Ils ont été pris avec une consigne de 18 °C, dans un garage à environ 12 °C :

- de 19 h à 3 h, la coupure tient le temps que le substrat redescende de 24 à 18 °C, et l'air tombe de 16,5 à 13,5 °C ;
- de 3 h à 15 h, la chauffe tourne presque sans arrêt : le substrat remonte à 23 °C, et l'air ne dépasse pas 16 °C ;
- la zone d'approche, en essai depuis 16 h, laisse l'air retomber aussitôt vers 14,5 °C.

Le câble du bas chauffe le terreau, pas l'air. Le propriétaire revient sur le compromis de 2026-005 : l'air ne doit plus rester sans chauffe pendant une coupure.

## Options

### le-mode-pour-les-deux-le-substrat-pour-le-bas

**Retenue.** Le mode décide pour les deux câbles ensemble, sur la mesure de l'air retenue : consigne et hystérésis, plages, hors-gel, comme aujourd'hui. La coupure par le substrat, avec son approche, ne coupe que le câble du substrat. Le câble de l'air n'a pour borne propre que le plafond de la décision `03-plafond-du-cable-de-l-air`.

**Pour** — une seule mesure, l'air, décide encore de chauffer ; le substrat ne fait que borner le câble qui le chauffe. Aucun réglage nouveau. Le câble du substrat garde exactement son comportement actuel, approche comprise. Le principe de 2026-005 et de 2026-007 tient : il y a toujours un seul déclencheur par sortie, et c'est le même pour les deux.
**Contre** — le substrat n'a pas de consigne à lui : il reste chauffé « en passant » quand l'air a froid.

### une-consigne-par-cable

Le câble du substrat suit une consigne du substrat, et le câble de l'air la consigne de l'air.

**Pour** — chaque zone tenue à sa température.
**Contre** — de nouveaux réglages, avec leurs bornes, leur publication et leur historique. Aucun besoin d'une température de substrat à tenir n'a été exprimé : la coupure et l'approche le bornent déjà par le haut. Le câble du substrat chaufferait aussi quand l'air est déjà à la consigne, au risque de la dépasser.

### coupure-commune

Les deux câbles suivent l'air, et la coupure par le substrat les coupe tous les deux.

**Pour** — rien ne change dans les règles de la coupure.
**Contre** — l'air reste sans chauffe pendant chaque coupure : le défaut constaté reste entier.

## Décision

`le-mode-pour-les-deux-le-substrat-pour-le-bas`. Ce qui a tranché : c'est le plus petit changement qui fasse chauffer l'air pendant une coupure. Il ne demande aucun réglage nouveau, et chaque sortie reste lisible sur la mesure qui la commande : l'air pour l'une, l'air borné par le substrat pour l'autre.
