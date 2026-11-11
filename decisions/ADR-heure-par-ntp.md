---
id: ADR-heure-par-ntp
statut: actif
cree_par: 2026-003
modifie_par: [2026-013, 2026-015]
---

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Il se synchronise dès que le Wi-Fi est joint après un démarrage, puis une fois par jour. L'heure est tenue pour connue dès la première synchronisation depuis le démarrage, puis avance sur l'horloge interne de l'ESP32 même si le réseau tombe ; elle se perd à chaque redémarrage. Elle est lue dans un fuseau horaire réglable, écrit comme une chaîne POSIX TZ ; par défaut celui de Paris, heure d'été comprise (`CET-1CEST,M3.5.0,M10.5.0/3`) — décision `05-fuseau`. En dépendent le jour et la nuit (RG-jour-et-nuit), qui lisent aussi la date, et qui retiennent le jour tant que l'heure n'est pas connue ; le chauffage du mode `PLAGES`, qui ne descend jamais au plancher hors plage sur une heure inconnue (RG-chauffage-par-plages), et l'aération quotidienne du mode `HIBERNATION`, qui retombe sur un décompte de 24 heures tant que l'heure n'est pas connue (RG-ventilation-periodique). Les cycles de ventilation d'`ACTIF` et de `PLAGES` se comptent en durée écoulée ; seuls leurs réglages, de jour ou de nuit, dépendent de l'heure. Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC (2026-001), et le Wi-Fi est déjà là pour la supervision (2026-002).
