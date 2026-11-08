---
id: ADR-portail-wifi-maison
statut: actif
cree_par: 2026-002
modifie_par: []
---

Le Wi-Fi et le courtier se configurent par un portail captif écrit dans le firmware : un point d'accès WPA2 propre au régulateur, une page servie par ESPAsyncWebServer, déjà retenu pour la page web locale, et le `DNSServer` du cœur Arduino. Aucune bibliothèque n'est ajoutée. Ce qui l'a décidé : WiFiManager ajoutait une bibliothèque et un second serveur web, synchrone, à côté de celui que la page web locale emploiera — décision `01-portail-de-configuration`.
