---
id: 06-heure
titre: D'où le régulateur tient-il l'heure ?
statut: retenue
option_retenue: rtc-et-ntp
---

## Description

La photopériode dépend de l'heure. Après une coupure de courant, le régulateur doit la retrouver, que le réseau soit là ou non.

## Options

### ntp-seul

L'heure demandée à un serveur NTP au démarrage.

**Pour** — aucun composant de plus.
**Contre** — après une coupure sans réseau, le régulateur ignore l'heure : l'éclairage s'allume au mauvais moment, ou pas du tout.

### rtc-et-ntp

**Retenue.** Une horloge DS3231 sauvegardée par pile CR2032, resynchronisée en NTP quand le réseau est là.

**Pour** — l'heure survit à une coupure sans réseau ; NTP corrige la dérive.
**Contre** — 4 € et une pile à changer tous les quelques ans.

## Décision

RTC DS3231 et NTP. Ce qui a tranché : la photopériode doit rester correcte même après une coupure sans réseau.
