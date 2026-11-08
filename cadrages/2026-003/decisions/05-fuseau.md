---
id: 05-fuseau
titre: Comment s'écrit le fuseau horaire réglable ?
statut: retenue
option_retenue: chaine-posix-validee
---

## Description

Le propriétaire veut un fuseau réglable par la liaison série et MQTT, Paris par défaut. L'ESP32 n'embarque pas la base des fuseaux : il lit une chaîne POSIX TZ (`CET-1CEST,M3.5.0,M10.5.0/3`). Sur une chaîne qu'elle ne comprend pas, la bibliothèque C passe en UTC sans le signaler : les plages glisseraient d'une ou deux heures sans que rien ne le dise.

## Options

### chaine-posix-validee

**Retenue.** Le réglage est la chaîne POSIX TZ elle-même, refusée si un analyseur strict du firmware ne la reconnaît pas : nom de 3 lettres ou plus ou entre chevrons, décalage de −24 à +24 h, heure d'été facultative réglée par des dates `Mm.s.j[/h]`, 47 caractères au plus.

**Pour** — tout fuseau est exprimable, sans table à tenir ; la validation empêche la bascule muette en UTC.
**Contre** — la syntaxe est obscure ; il faut la copier depuis une référence.

### liste-de-noms

Une table de noms IANA (`Europe/Paris`, `UTC`…) convertis en chaînes POSIX par le firmware.

**Pour** — lisible.
**Contre** — une table à tenir dans le firmware ; un fuseau absent demande de recompiler.

## Décision

`chaine-posix-validee`. Ce qui a tranché : le refus explicite d'un fuseau mal écrit, sans table à tenir. Un nom lisible pourra s'ajouter plus tard comme alias, sans changer le réglage enregistré.
