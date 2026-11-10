---
id: 05-portail-en-secours
titre: Comment un régulateur sans certificat valide reçoit-il le suivant ?
statut: retenue
option_retenue: portail-sans-certificat-valide
---

## Description

Un certificat expire si personne ne lance `appliquer.sh` à temps. Il peut aussi ne jamais être arrivé, ou être refusé après une relève d'autorité mal menée. Dans tous ces cas, le régulateur ne joint plus le courtier, et le renouvellement par MQTT ne peut plus rien. Le portail de 2026-011 sait recevoir un certificat. Mais RG-configuration-wifi-sur-place ne l'ouvre que sans Wi-Fi enregistré, sur un Wi-Fi injoignable pendant 5 minutes, ou par `WIFI CONFIGURER` sur la liaison série, donc par l'USB et un boîtier rouvert. Or un Wi-Fi qui marche, avec un certificat refusé, n'ouvre rien.

## Options

### liaison-serie

Le statu quo : `WIFI CONFIGURER`.

**Contre** — il faut l'USB, donc rouvrir le boîtier, ce que 2026-011 a écarté pour la remise (C3).

### couper-le-wifi-du-domicile

Éteindre la box 5 minutes pour que le régulateur ouvre son portail.

**Pour** — rien à écrire.
**Contre** — tout le domicile perd le réseau. Le geste est détourné et ne se devine pas.

### portail-toujours-ouvert

Le portail reste ouvert en permanence, à côté du Wi-Fi du domicile.

**Pour** — rien à juger.
**Contre** — un réseau de plus, ouvert sans raison, à la portée de tout voisin qui tenterait le mot de passe.

### portail-sans-certificat-valide

**Retenue.** Le régulateur ouvre aussi son portail dans trois cas : il n'a aucun certificat, le sien a expiré d'après l'heure NTP, ou Traefik l'a refusé pendant 5 minutes. Le portail se ferme une fois le Wi-Fi rejoint et le certificat admis.

**Pour** — le secours s'ouvre de lui-même, sans USB, au moment où on en a besoin, et seulement à ce moment-là. Le geste au garage est celui de 2026-011.
**Contre** — le firmware doit distinguer un certificat refusé d'un courtier injoignable : l'alerte TLS de Traefik le permet, mais il faut l'éprouver. Une longue panne du cluster qui ferait refuser les certificats ouvrirait le portail pour rien. Il resterait protégé en WPA2, et ne commande aucune sortie.

## Décision

`portail-sans-certificat-valide`. Ce qui a tranché : sans lui, le secours que promet 2026-011 demande de rouvrir le boîtier, alors que ce critère est exactement ce que la remise par le portail devait éviter.
