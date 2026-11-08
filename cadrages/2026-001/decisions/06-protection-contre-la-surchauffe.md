---
id: 06-protection-contre-la-surchauffe
titre: Qu'est-ce qui coupe le chauffage si son relais colle ou si le firmware se trompe ?
statut: retenue
option_retenue: aucune-en-phase-1
---

## Description

Le firmware coupe le chauffage quand le capteur d'air se tait, quand la carte se bloque (chien de garde) et après 2 heures de chauffe continue. Il ne peut rien dans trois cas : le contact du relais de chauffage reste collé, le firmware décide mal, ou le capteur d'air donne une mesure fausse mais plausible — décroché dans un coin froid, par exemple. Le plafond de 2 heures n'y change rien : il reprend seul après 15 minutes, il borne une durée et non une température. Le cadrage prévoyait pour ces cas un limiteur matériel à 24 °C (NF2), qualifié de non négociable. Au montage, le 08/11/2026, le propriétaire ne l'avait pas.

## Options

### limiteur-exo-terra

Le thermostat Exo Terra 300 W Dimming & Pulse, réglé à 24 °C en mode Pulse, branché entre le relais de chauffage et les câbles, sa sonde dans le bac contre la vitre arrière.

**Pour** — un produit fini, indépendant du firmware et du capteur d'air : il couvre les trois cas.
**Contre** — 65 € ; pas acheté au moment du montage.

### second-regulateur-nano

Un Arduino Nano, avec sa propre sonde DS18B20 étanche et son propre module relais 1 voie, en série après le relais de chauffage : relais ouvert à 24,0 °C ou plus, refermé sous 22,0 °C sans intervention, ouvert si la sonde est absente ou aberrante, chien de garde.

**Pour** — couvre les trois cas, l'ESP32 et le Nano ne partageant ni capteur, ni programme, ni relais ; le propriétaire a déjà le Nano et trois modules relais 1 voie.
**Contre** — un programme de plus, à écrire, tester et vérifier sur le matériel ; une sonde DS18B20 à acheter (9,95 €), le capteur d'air et la sonde du substrat ne pouvant pas se partager — un bus I²C ou 1-Wire n'a qu'un maître, et un capteur partagé recréerait la panne commune ; un module relais sans optocoupleur ni fente d'isolement, dont l'isolement 230 V n'est pas vérifié.

### deux-relais-commandes-par-l-esp32

Deux relais en série sur la phase, commandés ensemble par l'ESP32, avec ou sans détection d'un contact collé par la mesure du courant.

**Pour** — couvre un contact collé.
**Contre** — ne couvre ni le firmware qui se trompe ni le capteur d'air décroché, puisque les deux relais obéissent au même programme et au même capteur. Basculer le relais à intervalles réguliers ne détecte rien sans mesure après lui, et avec un seul relais, détecter ne coupe rien.

### aucune-en-phase-1

**Retenue.** Le montage de la phase 1 n'a pas de protection matérielle contre la surchauffe : le chauffage ne passe que par son relais.

**Pour** — rien à acheter ni à programmer de plus ; le montage reste simple.
**Contre** — un relais collé, un firmware qui se trompe ou un capteur d'air décroché font chauffer sans fin, et rien ne le signale hors de la LED d'état et de la liaison série. NF2 n'est pas tenue, et O6 ne l'est qu'en partie.

## Décision

Aucune protection matérielle en phase 1. Ce qui a tranché : le propriétaire préfère un montage simple, qui suppose qu'aucune de ces pannes ne survient, à un second régulateur à concevoir maintenant. Le sujet est repris par [sskorupski/ssk-terrarium#9](https://github.com/sskorupski/ssk-terrarium/issues/9), avec `second-regulateur-nano` pour hypothèse de départ, et son buzzer d'alerte par [sskorupski/ssk-terrarium#8](https://github.com/sskorupski/ssk-terrarium/issues/8).
