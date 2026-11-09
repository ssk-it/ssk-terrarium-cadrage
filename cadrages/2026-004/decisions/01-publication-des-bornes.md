---
id: 01-publication-des-bornes
titre: Comment une application connaît-elle les bornes des réglages ?
statut: retenue
option_retenue: bornes-dans-l-etat
---

## Description

Les bornes des réglages — consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, leur somme sous 24 °C, au plus 4 plages, un fuseau POSIX TZ d'au plus 47 caractères — sont fixées à la compilation (RG-reglages-bornes) et peuvent changer d'une version du firmware à l'autre. L'application sterrarium doit les montrer et s'en servir pour aider la saisie, sans jamais en devenir la source. La question a été posée côté application, par la décision 03-publication-des-bornes du cadrage 2026-001 de sterrarium ; elle change le contrat du firmware, et se consigne donc aussi ici.

## Options

### recopiees-dans-l-application

L'application embarque les mêmes valeurs que `config.h`.

**Pour** — aucun changement du firmware.
**Contre** — deux copies d'un même fait, qui divergent au premier firmware qui les change ; l'application refuserait une valeur que le firmware accepte, ou l'inverse, sans que rien ne le signale.

### sujet-retenu-dedie

Le firmware publie ses bornes une fois par connexion, sur un sujet retenu `ssk-terrarium/<id>/bornes`.

**Pour** — l'état publié toutes les 30 s ne grossit pas.
**Contre** — un sujet de plus, et ses droits, sur le courtier ; l'état et les bornes peuvent arriver dans un ordre quelconque, et rien ne garantit qu'ils viennent du même firmware.

### bornes-dans-l-etat

**Retenue.** Le firmware ajoute un objet `bornes` à la fin de l'état retenu.

**Pour** — un seul message dit la valeur en place et ses bornes, lus ensemble ; rien à ajouter au courtier ni à ses droits.
**Contre** — l'état grossit d'environ 120 octets, à vérifier contre sa taille maximale : mesuré à 593 octets au pire, sous les 640 octets de l'état et les 768 du tampon MQTT.

## Décision

`bornes-dans-l-etat`, choisie par le propriétaire pour que les bornes viennent du firmware. Ce qui a tranché entre les deux publications : lues dans le même message que la valeur, les bornes ne peuvent pas appartenir à un autre firmware que celui qui l'applique.
