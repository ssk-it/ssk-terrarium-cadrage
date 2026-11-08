---
id: RG-relais-coupes-sans-commande
fonctionnalites: [protections, boitier-de-commande]
statut: actif
cree_par: 2026-001
modifie_par: []
---

Une broche que l'ESP32 ne pilote pas — reset, boot, plantage — laisse chaque relais du module ouvert. Pour le garantir :

- le module a un cavalier JD-VCC séparable ; le cavalier est retiré : VCC, côté optocoupleurs, sur le 3,3 V de la carte ESP32, et JD-VCC, côté bobines, sur le 5 V du LM2596, pour que la logique 3,3 V commute franchement. Une entrée flottante ne fait alors passer aucun courant dans l'optocoupleur, et une carte ESP32 hors tension coupe aussi l'alimentation des optocoupleurs : tous les relais retombent ;
- le niveau de déclenchement du module (actif haut ou actif bas) est vérifié et consigné, et décide du niveau « coupé » des sorties — avec un module à déclenchement bas, « coupé » est le niveau haut ;
- ce comportement est vérifié au multimètre, carte en reset, au boot et sans firmware, avant tout raccordement du 230 V.

Ce que la règle protège : un module électromécanique, contrairement à un MOSFET tenu par sa résistance de rappel, peut coller sur une broche flottante ou une logique trop faible ; rien ne chauffe ni ne brumise tant que le firmware n'a pas décidé.
