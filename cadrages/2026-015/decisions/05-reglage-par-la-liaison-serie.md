---
id: 05-reglage-par-la-liaison-serie
titre: Comment régler tout cela par la liaison série ?
statut: retenue
option_retenue: config-json
---

## Description

RG-reglages-bornes veut chaque réglage accessible aussi par la liaison série. 2026-013 y avait mis `VENTILATION DUREE|PERIODE|HEURE`. Avec le jour et la nuit, les saisons et l'option saturation, une commande par champ ferait une vingtaine de mots-clés.

## Options

### un-mot-cle-par-champ

`VENTILATION NUIT MODE RUBATO`, `SAISON 2 DEBUT 06-21`…

**Pour** — lisible au clavier.
**Contre** — une syntaxe de plus à écrire, tester et documenter, qui double celle de `cmd/config` et divergera.

### config-json

**Retenue.** `CONFIG` suivi d'un JSON règle exactement comme `cmd/config`, par le même analyseur. `JOUR` et `VENTILATION` seuls affichent les réglages en place. `VENTILATION DUREE|PERIODE|HEURE` disparaît.

**Pour** — une seule syntaxe, une seule vérification des bornes, pour le réseau et la liaison série.
**Contre** — moins agréable à taper ; la ligne série s'allonge à 256 caractères.

## Décision

`config-json`. Ce qui a tranché : les réglages ne se vérifient qu'à un seul endroit, et la liaison série ne peut pas diverger du contrat MQTT.
