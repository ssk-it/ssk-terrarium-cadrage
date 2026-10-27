---
id: 01-microcontroleur
titre: Sur quel microcontrôleur faire tourner le régulateur ?
statut: retenue
option_retenue: esp32
---

## Description

Le régulateur doit tourner seul, des années, dans un garage, repartir sans intervention après une coupure de courant, et pourtant se superviser à distance.

## Options

### arduino-uno

Une carte AVR, sans réseau.

**Pour** — simple, robuste, redémarrage instantané.
**Contre** — aucun Wi-Fi : la supervision (O5) demanderait un module de plus ; mémoire trop étroite pour une page web et MQTT.

### raspberry-pi

Un ordinateur monocarte sous Linux.

**Pour** — tout l'outillage d'un système complet.
**Contre** — un démarrage de plusieurs dizaines de secondes, une carte SD qui s'use et se corrompt aux coupures, un système à tenir à jour.

### esp32

**Retenue.** Un ESP32-WROOM-32 sur carte DevKit V1.

**Pour** — Wi-Fi intégré, redémarrage instantané, pas de carte SD, deux cœurs et assez de mémoire pour la page web et MQTT, pour quelques euros.
**Contre** — un réseau qu'il faut tenir à l'écart de la régulation (RG-regulation-sans-reseau).

## Décision

ESP32. Ce qui a tranché : c'est la seule option qui supervise sans module de plus tout en repartant instantanément après une coupure, sans carte SD à user.
