---
id: 05-firmware
titre: Avec quoi écrire le firmware ?
statut: retenue
option_retenue: platformio-arduino
---

## Description

La logique de sécurité — sorties coupées au démarrage, coupures sur défaut, durées bornées — doit être exactement celle qu'on a voulue, et le régulateur doit vivre sans serveur domotique.

## Options

### esphome

Un firmware décrit en YAML, généré et intégré à Home Assistant.

**Pour** — très peu de code, intégration domotique immédiate.
**Contre** — la logique de sécurité s'exprime dans les limites du YAML et des composants fournis ; le régulateur tend à dépendre de Home Assistant.

### platformio-arduino

**Retenue.** Un firmware C++ avec PlatformIO et le framework Arduino, dans un dépôt à lui.

**Pour** — un contrôle total de la logique de sécurité ; un cœur de régulation testable en natif, sans carte ; autonome.
**Contre** — tout le code à écrire, page web et MQTT compris.

## Décision

PlatformIO et le framework Arduino, en C++. Ce qui a tranché : le contrôle total de la logique de sécurité, et un régulateur autonome sans Home Assistant.
