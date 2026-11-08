---
id: RG-changement-de-mode-manuel
fonctionnalites: [modes]
statut: actif
cree_par: 2026-001
modifie_par: [2026-002]
---

On passe d'un mode à l'autre seulement par une commande explicite, reçue par la liaison série USB ou par MQTT (`cmd/mode`) ; la page web locale s'y ajoutera avec sa phase. Le régulateur ne change jamais de mode de lui-même, ni selon la date, ni selon une mesure, ni à la perte ou au retour du réseau. Ce que la règle protège : aucun réveil intempestif d'un élevage en hibernation.
