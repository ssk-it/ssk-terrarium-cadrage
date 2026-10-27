---
id: 02-commande-230v
titre: Comment commander le chauffage et l'éclairage en 230 V ?
statut: retenue
option_retenue: relais-ssr-filaires
---

## Description

Le câble chauffant et la réglette LED sont en 230 V. Leur commande doit rester sûre électriquement, et surtout ne pas faire dépendre la régulation du réseau.

## Options

### prises-shelly

Des prises connectées en Wi-Fi, commandées par l'ESP32 ou par un serveur.

**Pour** — aucun câblage 230 V à faire soi-même.
**Contre** — chaque commande passe par le Wi-Fi : une box en panne laisse le chauffage dans son dernier état, contraire à NF1.

### relais-ssr-filaires

**Retenue.** Un module de deux relais statiques Omron G3MB-202P, câblés à l'ESP32, dans un boîtier IP65 fermé avec fusible, masses reliées et presse-étoupes.

**Pour** — la commande ne dépend que d'un fil ; silencieux, sans usure mécanique.
**Contre** — un câblage 230 V à soigner ; un SSR peut rester collé, d'où le limiteur matériel en série (RG-limiteur-materiel).

## Décision

Relais SSR filaires. Ce qui a tranché : les prises connectées rendent la régulation dépendante du Wi-Fi, ce que NF1 interdit.
