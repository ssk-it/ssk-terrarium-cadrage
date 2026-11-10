---
id: ADR-capteur-air-sht45
statut: actif
cree_par: 2026-001
modifie_par: [2026-007]
---

La température et l'humidité de l'air du bac sont mesurées par une Sensirion SHT45 munie d'une membrane PTFE, sur le bus I²C : c'est la sonde de référence, la seule intérieure par défaut. Le choix vient de la décision `03-capteur-air` de 2026-001 : le bac vit entre 75 et 90 % HR, plage où le DHT22 dérive et où une BME280, sans membrane, sature.

Un DHT11 (module KY-015) peut s'y ajouter en seconde sonde d'air, sur sa propre broche, avec un rôle intérieur ou extérieur qui se règle (RG-sondes-d-air). Déclaré intérieur, il peut régler le chauffage et, une fois la brumisation câblée, la pompe, avec ses limites :

- son humidité n'est garantie que de 20 à 90 % HR, à ±5 % ;
- sa température n'est garantie que de 0 à 50 °C, à ±2 °C, par pas de 1 °C ;
- son protocole propriétaire à un fil est sensible à la longueur du câble.

Le propriétaire a accepté ces limites le 2026-11-10 (2026-007, décisions `01-role-des-sondes` et `03-brumisation-sur-la-mesure-retenue`), pour qu'une panne de la SHT45 n'oblige plus à choisir entre refroidir et chauffer à l'aveugle.
