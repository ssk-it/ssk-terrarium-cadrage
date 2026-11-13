---
id: 02-autorite-de-certification
titre: Qui signe les certificats clients, et où vivent leurs clés ?
statut: retenue
option_retenue: autorite-propre-scellee
---

## Description

Traefik doit savoir quels certificats admettre, et chaque client doit tenir le sien. Le dépôt du firmware est public, et la règle RG-configuration-wifi-sur-place interdit tout identifiant dans le dépôt ou dans l'image. Il faut aussi pouvoir retirer un client sans couper les autres.

## Options

### autorite-publique

Des certificats clients signés par une autorité publique.

**Pour** — rien à fabriquer.
**Contre** — Traefik admettrait n'importe quel certificat que cette autorité signe pour n'importe qui, ce qui n'arrête aucun scanner ; et une autorité publique ne garantit pas de signer des certificats clients.

### autorite-dans-cert-manager

Une autorité dans le cluster, un `Issuer` de type CA de cert-manager, qui signe et renouvelle des certificats clients en Secrets.

**Pour** — le renouvellement côté cluster est automatique.
**Contre** — la clé de l'autorité et celles des clients vivent en clair dans des Secrets du cluster ; un certificat renouvelé sur le cluster n'arrive pas pour autant au régulateur.

### certificat-partage

Une autorité propre, mais un seul certificat pour tous les clients.

**Pour** — un seul secret à remettre.
**Contre** — retirer un client oblige à remettre un nouveau certificat à tous les autres.

### autorite-propre-scellee

**Retenue.** Une autorité propre au courtier, et un certificat par compte (`terrarium`, `proprietaire`), en ECDSA P-256, fabriqués par `clusters/ssk-it-01/sceller-secrets.sh` et scellés dans `ssk-it-infra`, comme les mots de passe ; ce qui sert sur le Mac va dans son trousseau. Traefik ne reçoit que le certificat public de l'autorité.

**Pour** — n'admet que les clients qu'on a fait signer ; les clés ne sont jamais en clair dans un dépôt ; même outil, même geste que les mots de passe ; ECDSA P-256 allège la poignée de main de l'ESP32 par rapport à RSA.
**Contre** — Traefik ne lit pas de liste de révocation : retirer un certificat, c'est changer le mot de passe du compte, puis refaire l'autorité et les certificats des autres.

## Décision

`autorite-propre-scellee`. Ce qui a tranché : les secrets suivent le chemin déjà éprouvé des mots de passe, scellés dans `ssk-it-infra`, et le mot de passe gardé rend un certificat volé inutile à lui seul, ce qui compense l'absence de révocation.
