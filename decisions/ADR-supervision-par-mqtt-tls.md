---
id: ADR-supervision-par-mqtt-tls
statut: actif
cree_par: 2026-002
modifie_par: []
---

Le régulateur publie son état et reçoit ses commandes en MQTT, chiffré par TLS, avec PubSubClient et le `WiFiClientSecure` du cœur Arduino ; il vérifie le certificat du courtier, et son nom, contre les racines ISRG Root X1 et ISRG Root YR de Let's Encrypt, embarquées dans le firmware. Ce qui l'a décidé : MQTT porte à la fois la publication et les commandes sur une connexion que le régulateur ouvre lui-même, sans service à écrire côté serveur, et le chiffrement est indispensable dès lors que le courtier est joint par Internet — décision `02-protocole-de-publication`.
