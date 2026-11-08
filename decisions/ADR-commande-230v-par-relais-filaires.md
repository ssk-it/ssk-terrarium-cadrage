---
id: ADR-commande-230v-par-relais-filaires
statut: actif
cree_par: 2026-001
modifie_par: []
---

Les sorties — chauffage en 230 V, ruban LED et pompe en 12 V, ventilateur en 5 V — sont commandées par un module de relais électromécaniques optocouplés, câblé à l'ESP32 dans un boîtier fermé ; la pompe garde sa diode de roue libre. Aucune sortie ne passe par une prise connectée. Ce qui l'a décidé : une prise connectée rendrait la régulation dépendante du Wi-Fi, contraire à RG-regulation-sans-reseau ; entre relais statiques et module électromécanique, l'utilisateur a choisi le module pour son prix et la simplicité d'un seul module pour toutes les sorties, sous les garde-fous de RG-relais-coupes-sans-commande — décision `02-commande-230v`.
