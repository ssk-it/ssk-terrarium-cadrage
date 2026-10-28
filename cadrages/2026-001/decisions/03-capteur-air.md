---
id: 03-capteur-air
titre: Quel capteur pour la température et l'humidité de l'air ?
statut: retenue
option_retenue: sht45
---

## Description

L'air du bac vit entre 75 et 90 % HR, presque saturé, en permanence. Un capteur qui dérive dans cette zone fausse à la fois la brumisation et les alertes.

## Options

### dht22

Le capteur bon marché le plus répandu.

**Pour** — quelques euros, des bibliothèques partout.
**Contre** — il dérive au-dessus de 80 % HR, exactement là où le bac vit ; protocole propriétaire peu fiable sur un câble long.

### bme280

Un capteur Bosch combiné température, humidité et pression, présent dans la liste de départ.

**Pour** — très répandu, la pression en prime.
**Contre** — pas de membrane : la condensation et le substrat l'atteignent ; il sature en humidité haute, alors que le bac doit être tenu entre 75 et 90 % HR.

### sht45

**Retenue.** Un Sensirion SHT45 avec membrane PTFE, sur breakout I²C : la carte Adafruit n° 6174, STEMMA QT, adresse 0x44, alimentée en 3,3 ou 5 V.

**Pour** — précis et stable en humidité haute ; la membrane le protège de la condensation et du substrat ; I²C partagé avec l'horloge.
**Contre** — 15-20 € au lieu de quelques euros.

## Décision

SHT45 à membrane PTFE. Ce qui a tranché : le DHT22 dérive au-dessus de 80 % HR et le BME280, sans membrane, sature en humidité haute — la plage même où le bac doit être tenu.
