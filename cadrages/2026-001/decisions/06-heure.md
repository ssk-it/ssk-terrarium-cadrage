---
id: 06-heure
titre: D'où le régulateur tient-il l'heure ?
statut: retenue
option_retenue: ntp-seul
---

## Description

L'éclairage et les cycles de ventilation dépendent de l'heure. Après une coupure de courant, le régulateur doit la retrouver ; le chauffage, le hors-gel et les protections, eux, n'en ont pas besoin.

## Options

### rtc-et-ntp

Une horloge DS3231 sauvegardée par pile CR2032, resynchronisée en NTP quand le réseau est là.

**Pour** — l'heure survit à une coupure sans réseau ; la photopériode reste juste même hors ligne.
**Contre** — un module, une pile à changer, un composant de plus sur le bus I²C.

### ntp-seul

**Retenue.** L'heure demandée à un serveur NTP, par le Wi-Fi de l'ESP32, sans module d'horloge.

**Pour** — aucun composant de plus ; l'heure est juste dès que le réseau est là.
**Contre** — après une coupure sans réseau, le régulateur ignore l'heure : l'éclairage reste alors coupé (à valider) jusqu'au retour du réseau, et le critère « à l'heure même sans réseau » de O3 tombe.

## Décision

NTP seul. Ce qui a tranché : l'utilisateur a écarté l'horloge RTC ; l'heure ne sert qu'à l'éclairage et à la ventilation, si bien que la régulation du chauffage et les protections restent indépendantes du réseau (NF1 intacte).
