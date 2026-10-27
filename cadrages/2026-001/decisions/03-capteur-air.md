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

### sht45

**Retenue.** Un Sensirion SHT45 avec membrane PTFE, sur breakout I²C.

**Pour** — précis et stable en humidité haute ; la membrane le protège de la condensation et du substrat ; I²C partagé avec l'horloge.
**Contre** — 15-20 € au lieu de quelques euros.

## Décision

SHT45 à membrane PTFE. Ce qui a tranché : le DHT22 dérive au-dessus de 80 % HR, la plage même où le bac doit être tenu.
