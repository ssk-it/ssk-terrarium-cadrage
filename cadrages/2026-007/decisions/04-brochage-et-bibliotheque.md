---
id: 04-brochage-et-bibliotheque
titre: Sur quelle broche, et avec quelle bibliothèque, lire le DHT11 ?
statut: retenue
option_retenue: gpio-13-adafruit-dht
---

## Description

RG-brochage n'avait aucune broche pour une seconde sonde. Le DHT11 parle un protocole à un fil qui lui est propre : il ne peut partager ni le bus I²C de la SHT45, ni le 1-Wire du DS18B20. Il lui faut une broche à lui, libre, et qui ne serve pas au démarrage de l'ESP32.

## Options

### gpio-32-adafruit-dht

Données sur GPIO 32, lues par `adafruit/DHT sensor library` 1.4.6, avec `adafruit/Adafruit Unified Sensor`, versions épinglées.

**Pour** — la broche est libre et n'a aucun rôle au démarrage, ni en débogage.
**Contre** — aucun relevé.

### gpio-13-adafruit-dht

**Retenue.** Données sur GPIO 13, même bibliothèque. Le module KY-015 est alimenté en 3,3 V, et sa résistance de tirage suffit.

**Pour** — la broche est libre, et ce n'est pas une broche de démarrage.
**Contre** — elle sert au JTAG (MTCK), qu'un débogage matériel ne pourra plus employer.

## Décision

`gpio-13-adafruit-dht`, choisie par le propriétaire le 2026-11-10. La bibliothèque est la plus répandue pour ce composant. Elle bloque environ 20 ms par lecture, une fois toutes les 30 s, ce qui reste loin du chien de garde de 10 s. Elle rend une valeur non numérique en cas d'échec, ce qui se traite comme une sonde muette (RG-capteur-en-defaut). Le câble du DHT11 reste court : le protocole y est sensible (ADR-capteur-air-sht45).
