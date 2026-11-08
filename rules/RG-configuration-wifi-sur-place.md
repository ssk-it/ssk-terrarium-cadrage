---
id: RG-configuration-wifi-sur-place
fonctionnalites: [configuration-wifi]
statut: actif
cree_par: 2026-002
modifie_par: []
---

Le régulateur ouvre son propre réseau Wi-Fi, `ssk-terrarium-` suivi des quatre derniers chiffres hexadécimaux de son adresse MAC, quand il n'a aucun Wi-Fi enregistré, ou quand le Wi-Fi enregistré reste injoignable 5 minutes ; il continue alors d'essayer ce dernier. Ce réseau est protégé en WPA2 par un mot de passe tiré au hasard au premier démarrage, enregistré en mémoire non volatile, et affiché sur la liaison série à chaque démarrage. Sa page de configuration demande le Wi-Fi du domicile, son mot de passe, l'adresse et le port du courtier, l'identifiant et le mot de passe MQTT du régulateur, et les enregistre en mémoire non volatile. Le réseau se ferme dès que le régulateur a rejoint le Wi-Fi du domicile. La commande série `WIFI CONFIGURER` le rouvre à la demande. La page ne commande aucune sortie et ne change ni le mode ni les réglages ; ni elle ni la connexion n'interrompent la régulation, qui n'attend jamais le réseau. Aucun identifiant ne figure dans le dépôt ni dans l'image du firmware. Ce que la règle protège : on configure le réseau sans outil ni recompilation, sans qu'un voisin puisse le faire, et sans que cette configuration puisse rien allumer.
