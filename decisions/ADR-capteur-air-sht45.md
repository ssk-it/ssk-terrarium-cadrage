---
id: ADR-capteur-air-sht45
statut: actif
cree_par: 2026-001
modifie_par: []
---

La température et l'humidité de l'air sont mesurées par un Sensirion SHT45 muni d'une membrane PTFE, sur le bus I²C. Ce qui l'a décidé : le bac vit entre 75 et 90 % HR, où le DHT22 dérive et où un BME280, sans membrane, sature — décision `03-capteur-air`.
