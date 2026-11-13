---
id: 01-filtrer-avant-le-courtier
titre: Comment empêcher un client inconnu d'atteindre le courtier ?
statut: retenue
option_retenue: tls-mutuel-chez-traefik
---

## Description

Des scanners ouvrent des connexions TLS à `mq.ssk-it.fr:443` et les referment sans rien envoyer. Les comptes ne craignent rien, mais chaque connexion atteint Mosquitto, qui ne sait ni freiner les échecs d'authentification ni refuser une rafale, et remplit son journal. Ce qui rend la question difficile : le régulateur et MQTT Explorer doivent rester joignables de partout, et le régulateur est un ESP32 sans réserve de mémoire.

## Options

### plafond-de-connexions-seul

Le `MiddlewareTCP inFlightConn` de ssk-it/ssk-it-infra#47, qui ferme au-delà de 8 connexions simultanées par adresse, et rien de plus.

**Pour** — déjà fait, sans effet sur les clients.
**Contre** — une connexion sous le plafond atteint toujours le courtier : le scan continue, borné.

### liste-d-adresses

Un `MiddlewareTCP ipAllowList` qui n'admet que l'adresse du domicile.

**Pour** — rien à installer sur les clients.
**Contre** — plus de MQTT Explorer hors du domicile ; un changement d'adresse de la box coupe le régulateur sans prévenir.

### masquer-le-nom

Un certificat générique `*.ssk-it.fr`, pour que `mq` n'apparaisse plus dans les journaux de transparence des certificats.

**Pour** — rien à changer chez les clients.
**Contre** — le nom est déjà publié et connu des scanners ; un défi DNS-01 à mettre en place pour cert-manager.

### tls-mutuel-dans-mosquitto

Traefik passe le TLS sans le terminer, et Mosquitto exige le certificat client.

**Pour** — Mosquitto voit le certificat, et pourrait en tirer le compte.
**Contre** — la connexion atteint quand même Mosquitto avant d'être refusée ; le certificat du serveur et son renouvellement passent de cert-manager à Mosquitto, ce que la décision `03-hebergement-du-courtier` de 2026-002 voulait éviter.

### tls-mutuel-chez-traefik

**Retenue.** La `TLSOption mqtt` de la route TCP de `mq.ssk-it.fr` exige un certificat client signé par l'autorité du courtier (`clientAuth`, `RequireAndVerifyClientCert`). Le compte et son mot de passe restent exigés par Mosquitto.

**Pour** — une connexion sans certificat échoue dans la poignée de main, chez Traefik, et n'atteint jamais Mosquitto ; rien ne change pour le TLS du serveur ni pour cert-manager.
**Contre** — chaque client doit recevoir un certificat et sa clé ; la poignée de main du régulateur s'alourdit d'une signature ECDSA ; Mosquitto ne voit pas le certificat et ne peut pas en tirer le compte, d'où le mot de passe gardé.

## Décision

`tls-mutuel-chez-traefik`. Ce qui a tranché : c'est la seule option qui refuse un client inconnu avant le courtier, sans le priver d'être joint de partout, et elle loge la vérification là où le TLS est déjà terminé.
