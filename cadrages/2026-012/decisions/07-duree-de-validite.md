---
id: 07-duree-de-validite
titre: Combien de temps valent les certificats, maintenant qu'ils se renouvellent à distance ?
statut: retenue
option_retenue: un-an
---

## Description

2026-011 a retenu cinq ans pour les certificats et dix ans pour l'autorité (décision `04-duree-de-validite`). Le motif était la remise au garage : une durée longue la rendait rare, « d'ici le cadrage qui l'automatisera ». Ce cadrage est celui-là. Le motif tombe, et la question se repose autrement : le risque le plus probable n'est plus d'oublier d'aller au garage, mais qu'une voie de renouvellement qu'on n'emprunte jamais soit cassée le jour où l'on en a besoin. La signature reste manuelle, à chaque passage d'`appliquer.sh` (décision `03-declenchement`), et le renouvellement commence 90 jours avant l'échéance.

## Options

### cinq-ans

Garder la durée de 2026-011.

**Pour** — rien à changer, et le moins de passages possible.
**Contre** — la voie de renouvellement ne sert qu'une fois tous les cinq ans : un firmware qui l'a cassée entre-temps ne se révèle qu'à l'échéance. Une clé volée vaut cinq ans.

### quatre-vingt-dix-jours

La durée de Let's Encrypt.

**Pour** — une clé volée vaut peu, et la voie sert sans cesse.
**Contre** — avec un renouvellement qui commence à 90 jours de l'échéance, la demande serait permanente. Une signature manuelle, qui dépend du passage d'`appliquer.sh`, ne tient pas ce rythme sans tâche planifiée, ce qu'a écarté `03-declenchement`.

### un-an

**Retenue.** Un an pour les certificats clients, dix ans pour l'autorité, qu'aucun certificat ne dépasse. Les certificats de cinq ans remis par 2026-011 sont renouvelés dès la livraison de ce cadrage.

**Pour** — la voie de renouvellement sert chaque année, et un défaut se voit avec 90 jours de marge, avant de couper quoi que ce soit. Une clé volée vaut un an au plus. Un passage d'`appliquer.sh` par trimestre suffit.
**Contre** — une signature à confirmer par client et par an, soit trois. Un oubli de plus de 90 jours renvoie au garage (décision `05-portail-en-secours`).

## Décision

`un-an`. Ce qui a tranché : un chemin qu'on emprunte chaque année reste praticable, et c'est ce qui rend le renouvellement à distance digne de confiance. Le mot de passe, toujours exigé, reste la protection d'une clé volée. La durée ne l'est plus.
