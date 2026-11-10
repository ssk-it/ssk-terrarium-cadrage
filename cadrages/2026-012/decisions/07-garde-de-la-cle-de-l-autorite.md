---
id: 07-garde-de-la-cle-de-l-autorite
titre: Où garder la clé de l'autorité, pour qu'elle survive à la perte d'un Mac ?
statut: retenue
option_retenue: trousseau-icloud
---

## Description

`appliquer.sh` signe chaque renouvellement avec la clé de l'autorité (décision `03-declenchement`). Cette clé ne doit pas être en clair sur le cluster, ce qu'a écarté `02-autorite-de-certification` de 2026-011, ni dans un dépôt. Si elle n'existe que sur un Mac et que ce Mac est perdu, volé ou réinstallé, plus rien ne signe. Il faut alors une nouvelle autorité, et la remise de chaque certificat par le portail, au garage. C'est la coupure que ce cadrage veut éviter.

## Options

### trousseau-de-session-seul

La clé dans le trousseau de session du Mac, où `sceller-secrets.sh` range déjà les mots de passe, sans autre copie.

**Pour** — c'est le geste déjà écrit, avec `security`, et la clé reste sur une seule machine.
**Contre** — la perte du Mac coûte une nouvelle autorité et un passage au garage par client.

### scellee-dans-ssk-it-infra

La clé scellée dans `ssk-it-infra`, comme les mots de passe.

**Contre** — un secret scellé ne se descelle que sur le cluster, où il serait en clair dans un Secret. C'est `autorite-dans-cert-manager`, écartée par 2026-011.

### copie-chiffree-hors-ligne

`sceller-secrets.sh` exporte en plus la clé, chiffrée par une phrase de passe, sur un support hors ligne.

**Pour** — la copie ne dépend d'aucun service, et n'existe que là où on l'a posée.
**Contre** — un support à garder, et une phrase de passe à ne pas perdre. Une copie qu'on ne relit jamais, on ne sait pas si elle se relit encore.

### trousseau-icloud

**Retenue.** La clé est rangée dans le trousseau iCloud du propriétaire, chiffré de bout en bout par Apple. Elle s'y synchronise d'un Mac à l'autre. `appliquer.sh` l'y lit, après déverrouillage.

**Pour** — la clé survit à la perte d'un Mac sans support à garder. Elle n'est jamais en clair hors des appareils du propriétaire, ni sur le cluster, ni dans un dépôt, ni chez Apple.
**Contre** — la clé quitte une machine unique : quiconque tient le compte Apple et le code d'un appareil peut la lire. Le mot de passe exigé par Mosquitto rend un certificat forgé inutile à lui seul. Il faut aussi vérifier qu'un script peut y écrire. `security` n'écrit que dans le trousseau de session, qui ne se synchronise pas. Un élément synchronisé passe par le trousseau de protection des données, qu'un outil sans droit de trousseau (`keychain-access-groups`) ne peut pas atteindre. Si le chantier ne trouve pas de voie scriptable, il revient à cette décision au lieu de faire copier la clé à la main.

## Décision

`trousseau-icloud`. Ce qui a tranché : la clé doit survivre à la perte d'un Mac sans support supplémentaire à tenir, et le trousseau iCloud, chiffré de bout en bout, la garde hors du cluster et des dépôts.
