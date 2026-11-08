---
id: RG-brochage
fonctionnalites: [boitier-de-commande]
statut: actif
cree_par: 2026-001
modifie_par: []
---

Le brochage de l'ESP32 est le suivant :

| Fonction | GPIO | Remarque |
| --- | --- | --- |
| I²C SDA (SHT45) | 21 | |
| I²C SCL | 22 | |
| 1-Wire DS18B20 | 4 | Pull-up 4,7 kΩ vers 3,3 V |
| Relais chauffage | 26 | Coupé au démarrage |
| Relais LED | 27 | Coupé au démarrage |
| Relais pompe | 25 | Coupé au démarrage |
| Relais ventilateur | 33 | Coupé au démarrage |
| LED d'état | 2 | LED externe + 330 Ω : la KS5016 n'en a pas sur cette broche |

Le niveau logique « coupé » des quatre sorties de relais dépend du niveau de déclenchement du module, à vérifier (RG-relais-coupes-sans-commande).
