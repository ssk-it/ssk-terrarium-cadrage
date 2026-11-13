---
id: 05-signature-et-publication
titre: Qui signe l'image et la publie dans Skaron ?
statut: retenue
option_retenue: poste-du-proprietaire
---

## Description

La CI compile déjà le firmware et publie la release sur un runner de GitHub, puisque le dépôt est public. Skaron veut que ses artefacts et ses manifestes ne s'écrivent que par son CLI, depuis le poste de l'administrateur (RG-seul-le-cli-ecrit-licences-et-artefacts). La clé de signature est ce qui protège le bac (décision `03-authenticite-de-l-image`).

## Options

### ci-github

Le workflow de publication signe et publie dans Skaron, avec la clé minisign et une clé d'écriture S3 en secrets du dépôt.

**Pour** — aucun geste après le tag.
**Contre** — la clé qui protège le bac vivrait dans les secrets d'un dépôt public, lue par des actions tierces, sur un runner que l'on ne tient pas. La règle de Skaron serait à faire évoluer par un cadrage du référentiel de Skaron.

### poste-du-proprietaire

**Retenue.** La CI attache à la release `firmware.bin` et son empreinte SHA-256, en plus de l'image fusionnée. Le propriétaire lance ensuite sur son poste un script versionné, `outils/publier-mise-a-jour.sh <tag>`. Ce script télécharge l'image, en vérifie l'empreinte, la signe avec la clé minisign tenue dans le trousseau du système, puis la publie par `skaron release publish`.

**Pour** — la clé ne quitte jamais le poste, et la règle de Skaron est respectée telle quelle. Le geste de publier une mise à jour et celui de l'installer restent tous deux ceux du propriétaire.
**Contre** — un geste de plus après le tag, et la publication dépend d'un poste.

## Décision

`poste-du-proprietaire`. Le critère qui a tranché : une image installable doit exiger la clé du propriétaire, et cette clé ne doit vivre ni dans la CI ni dans Skaron.
