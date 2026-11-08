---
id: 02-protocole-de-publication
titre: Par quel protocole publier les mesures et recevoir les commandes ?
statut: retenue
option_retenue: mqtt-tls
---

## Description

Le régulateur est derrière la box du domicile : il ne peut qu'ouvrir des connexions sortantes. Il doit publier son état toutes les 30 s et recevoir des commandes sans délai, à travers Internet, sans service à écrire côté serveur.

## Options

### http-maison

Le régulateur envoie son état par une requête HTTPS à un service à écrire, qui l'enregistre dans le PostgreSQL du cluster ; il interroge le même service pour ses commandes.

**Pour** — passe par l'entrée HTTPS existante, sans nouveau port ; un historique d'emblée.
**Contre** — un service à écrire, construire et maintenir ; des commandes reçues seulement au sondage suivant ; un format maison que rien d'autre ne lit.

### mqtt-clair

MQTT sur le port 1883, sans chiffrement.

**Pour** — le plus léger pour l'ESP32.
**Contre** — mots de passe et commandes en clair sur Internet.

### mqtt-tls

**Retenue.** MQTT sur TLS (8883), avec PubSubClient, déjà épinglé, et `WiFiClientSecure` ; certificat vérifié contre ISRG Root X1.

**Pour** — publication et commandes sur une seule connexion sortante ; aucun code serveur ; lisible par tout client MQTT ; les sujets de la piste #13 s'y appliquent tels quels.
**Contre** — la poignée de main TLS prend quelques dizaines de kilo-octets de mémoire et une à deux secondes ; la racine embarquée devra suivre Let's Encrypt.

## Décision

MQTT sur TLS. Ce qui a tranché : publication et commandes passent par la même connexion, sans aucun service à écrire côté serveur.
