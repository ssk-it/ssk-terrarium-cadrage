---
id: ADR-regulation-par-hysteresis
statut: actif
cree_par: 2026-001
modifie_par: []
---

Chauffage et brumisation se régulent en tout-ou-rien, par hystérésis autour d'une consigne ou par seuil, et non par PID. Ce qui l'a décidé : l'inertie forte d'un bac de 215 L isolé, sur laquelle un PID n'apporte rien et ajoute des réglages à tenir — décision `04-regulation`.
