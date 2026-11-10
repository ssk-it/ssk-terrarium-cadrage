---
id: 04-duree-de-validite
titre: Combien de temps valent l'autorité et les certificats ?
statut: retenue
option_retenue: cinq-ans
---

## Description

Tant qu'aucun renouvellement à distance n'existe (hors périmètre), chaque certificat qui expire coupe la supervision jusqu'à ce qu'on aille remettre le suivant au garage. Une durée courte limite ce que vaut une clé volée ; une durée longue rend la remise rare.

## Options

### un-an

**Pour** — une clé volée vaut un an au plus.
**Contre** — un passage au garage par an, et une supervision coupée si on l'oublie.

### deux-ans

**Pour** — compromis courant.
**Contre** — encore un passage tous les deux ans, sans renouvellement à distance.

### cinq-ans

**Retenue.** Cinq ans pour les certificats clients, dix ans pour l'autorité, pour qu'un certificat renouvelé ne survive jamais à l'autorité qui l'a signé.

**Pour** — une remise rare, compatible avec un renouvellement fait à la main d'ici le cadrage qui l'automatisera.
**Contre** — une clé volée vaut plus longtemps ; ce que compense le mot de passe, toujours exigé.

## Décision

`cinq-ans`. Ce qui a tranché : sans renouvellement à distance, l'expiration est le risque le plus probable de couper la supervision, et le mot de passe gardé rend une clé volée inutile à elle seule. `appliquer.sh` signale une expiration à 90 jours.
