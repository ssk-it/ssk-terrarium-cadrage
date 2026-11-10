---
id: 03-remise-au-regulateur
titre: Comment le certificat et sa clé arrivent-ils dans le régulateur ?
statut: retenue
option_retenue: script-vers-le-portail
---

## Description

Le certificat du régulateur et sa clé sont scellés dans `ssk-it-infra`. Ils doivent arriver dans sa mémoire non volatile sans entrer dans l'image du firmware (décision `01-portail-de-configuration` de 2026-002), sans rouvrir le boîtier, et y compris quand il n'a encore aucun certificat : il ne peut alors pas joindre le courtier.

## Options

### compiles-dans-le-firmware

**Contre** — déjà écartée par la décision `01-portail-de-configuration` de 2026-002 : l'image porterait la clé, et le dépôt est public.

### liaison-serie

Une commande série qui reçoit le certificat et la clé.

**Pour** — aucun réseau en jeu.
**Contre** — il faut l'USB, donc rouvrir le boîtier.

### par-mqtt

Le certificat publié sur un sujet que le régulateur écoute.

**Pour** — sans se déplacer.
**Contre** — impossible pour un régulateur qui n'a pas encore de certificat, ou dont le certificat a expiré ; c'est une voie de renouvellement, laissée à un cadrage à part.

### application-de-bureau

L'application sterrarium remet le certificat au régulateur.

**Contre** — elle tiendrait la clé du régulateur, dont elle n'a aucun besoin, et un client de plus aurait de quoi se faire passer pour lui.

### copier-coller-dans-le-portail

Deux champs de plus sur la page du portail, remplis à la main.

**Pour** — rien à écrire côté `ssk-it-infra`.
**Contre** — la clé passe par le presse-papiers et l'écran ; une erreur de copie ne se voit qu'au refus du courtier.

### script-vers-le-portail

**Retenue.** Le portail gagne deux champs, certificat et clé, qu'il accepte aussi seuls. Un script de `ssk-it-infra`, lancé quand le Mac a rejoint le réseau du portail, lit le certificat et la clé scellés sur le cluster et les envoie au portail.

**Pour** — rien à copier ; le geste est celui de la configuration du Wi-Fi, sur place ; il marche sans certificat préalable.
**Contre** — il faut aller au garage avec le Mac ; le Mac quitte son Wi-Fi le temps de la remise.

## Décision

`script-vers-le-portail`. Ce qui a tranché : c'est la seule voie qui marche pour un régulateur sans certificat, sans USB et sans que la clé passe par un écran.
