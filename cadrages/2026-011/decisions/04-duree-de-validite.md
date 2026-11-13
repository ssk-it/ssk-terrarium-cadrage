---
id: 04-duree-de-validite
titre: Combien de temps valent l'autorité et les certificats ?
statut: retenue
option_retenue: un-an
---

## Description

Une durée courte limite ce que vaut une clé volée. Une durée longue rend les renouvellements rares. Le renouvellement à distance est hors périmètre de ce cadrage, mais il est cadré à part, dans [ssk-terrarium-cadrage#2026-012](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-012). Celui-ci fait tirer sa clé au régulateur, qui publie une demande de signature par MQTT. `appliquer.sh` la signe 90 jours avant l'échéance. D'ici à sa livraison, un certificat qui expire coupe la supervision jusqu'à ce qu'on remette le suivant au garage. La question n'est donc plus de rendre la remise rare. Il s'agit de choisir la durée que le renouvellement à distance aura à tenir.

## Options

### cinq-ans

Cinq ans pour les certificats, dix ans pour l'autorité.

**Pour** — la remise au garage reste rare, même si le renouvellement à distance tarde.
**Contre** — la voie de renouvellement ne sert qu'une fois tous les cinq ans : un firmware qui l'aurait cassée entre-temps ne le révélerait qu'à l'échéance. Une clé volée vaudrait cinq ans. Le premier certificat devrait en outre être renouvelé dès la livraison de 2026-012, pour passer à la durée qu'il emploie.

### deux-ans

**Pour** — le compromis courant.
**Contre** — avec un renouvellement à distance, rien ne justifie de l'espacer davantage qu'un an. Sans lui, on irait quand même au garage.

### quatre-vingt-dix-jours

La durée de Let's Encrypt.

**Contre** — avec un renouvellement qui commence 90 jours avant l'échéance, la demande serait permanente. La signature est manuelle, à chaque passage d'`appliquer.sh` (décision `03-declenchement` de 2026-012), et elle ne tient pas ce rythme.

### un-an

**Retenue.** Un an pour les certificats clients, dix ans pour l'autorité. Aucun certificat n'est signé pour durer au-delà de l'autorité qui le signe.

**Pour** — le renouvellement à distance de 2026-012 sert chaque année, et un défaut se voit avec 90 jours de marge, avant de couper quoi que ce soit. Une clé volée vaut un an au plus. Le premier certificat a déjà la durée de tous les suivants.
**Contre** — si 2026-012 n'est pas livré dans l'année qui suit la première remise, il faut retourner au garage. Il y a une signature à confirmer par client et par an.

## Décision

`un-an`. Ce qui a tranché : un chemin qu'on emprunte chaque année reste praticable. Le mot de passe, toujours exigé, reste la protection d'une clé volée, et la durée n'a pas à l'être. `appliquer.sh` signale une expiration 90 jours avant.

Révisée le 11 novembre 2026, avant la fusion, quand 2026-012 a cadré le renouvellement : elle retenait d'abord `cinq-ans`, au motif qu'il n'existait pas encore de renouvellement à distance.
