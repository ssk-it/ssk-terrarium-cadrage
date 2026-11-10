---
id: 02-livraison
titre: Par quel service l'alerte atteint-elle le téléphone ?
statut: retenue
option_retenue: ntfy-auto-heberge
---

## Description

Alertmanager ne parle pas au téléphone : il lui faut un service de notification push. ntfy en est un, libre, avec une application Android. La question est de savoir lequel de ses serveurs employer, et ce que chacun coûte au téléphone.

## Options

### ntfy-sh-public

Le serveur public ntfy.sh.

**Pour** — rien à héberger ; l'application Play passe par Firebase Cloud Messaging pour ntfy.sh, sans connexion à tenir ni batterie de plus.
**Contre** — les messages passent par un tiers ; un sujet y est public par son nom tant qu'il n'est pas réservé.

### ntfy-auto-heberge

**Retenue.** Un serveur ntfy sur ssk-it-01, sous l'entrée HTTPS existante, au sujet fermé à l'anonyme.

**Pour** — les messages restent sur le cluster ; l'accès se règle par comptes, scellés dans ssk-it-infra, comme ceux du courtier.
**Contre** — un service de plus à tenir. L'application ntfy n'emploie pas Firebase pour un serveur auto-hébergé, sauf à recompiler son APK. Elle garde donc une connexion ouverte, par un service au premier plan et sa notification permanente, qu'on peut masquer. Selon la FAQ de ntfy, cela consomme « about 0-1% of battery in 17h ». Le keepalive du serveur vaut 45 s par défaut, sous la coupure à 50 s du Load Balancer. Il faut exempter ntfy de l'optimisation de batterie sur le téléphone, un Pixel 8 Pro sous Android 17.

## Décision

`ntfy-auto-heberge`, choisi par le propriétaire le 11 novembre 2026, après avoir pesé le coût en batterie. Ce qui a tranché : garder les alertes du terrarium sur le cluster, fermées par comptes comme le courtier, plutôt que sur un serveur tiers.
