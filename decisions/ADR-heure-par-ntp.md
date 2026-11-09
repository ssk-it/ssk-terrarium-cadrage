---
id: ADR-heure-par-ntp
statut: actif
cree_par: 2026-003
modifie_par: []
---

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Il se synchronise dès que le Wi-Fi est joint après un démarrage, puis une fois par jour. L'heure est tenue pour connue dès la première synchronisation depuis le démarrage, puis avance sur l'horloge interne de l'ESP32 même si le réseau tombe ; elle se perd à chaque redémarrage. Elle est lue dans un fuseau horaire réglable, écrit comme une chaîne POSIX TZ ; par défaut celui de Paris, heure d'été comprise (`CET-1CEST,M3.5.0,M10.5.0/3`) — décision `05-fuseau`. Seul le chauffage du mode `PLAGES` en dépend aujourd'hui, et il ne descend jamais au plancher hors plage sur une heure inconnue (RG-chauffage-par-plages). Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC (2026-001), et le Wi-Fi est déjà là pour la supervision (2026-002).
