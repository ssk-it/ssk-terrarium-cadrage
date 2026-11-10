---
id: 04-adoption
titre: Comment le régulateur adopte-t-il un certificat neuf sans perdre la supervision ?
statut: retenue
option_retenue: essai-puis-retour-arriere
---

## Description

Seul Traefik sait si un certificat est accepté, et il ne le dit qu'à la poignée de main. Un certificat neuf peut être refusé pour plusieurs raisons : signé par une autre autorité que celle admise, abîmé, ou forgé par quelqu'un qui aurait le compte `certificats`. Le régulateur ne peut présenter qu'un certificat par connexion. Par ailleurs, tout redémarrage coupe d'abord ses sorties (RG-sorties-coupees-au-demarrage), et RG-regulation-sans-reseau veut qu'aucune affaire de réseau ne touche à la régulation.

## Options

### remplacer-et-redemarrer

Enregistrer le certificat neuf à la place de l'ancien, puis redémarrer.

**Pour** — le plus simple à écrire.
**Contre** — le redémarrage coupe les sorties. Un certificat refusé laisse le régulateur sans certificat valide, donc au garage.

### remplacer-sans-redemarrer

Enregistrer le certificat neuf à la place de l'ancien, et se reconnecter.

**Pour** — pas de redémarrage.
**Contre** — un refus fait perdre la supervision jusqu'au passage au garage, alors que l'ancien certificat était encore bon.

### verifier-la-signature-sur-le-regulateur

Le régulateur garde le certificat public de l'autorité et vérifie la signature avant d'adopter.

**Pour** — un certificat forgé est écarté avant tout essai.
**Contre** — il faudrait remettre au régulateur, de façon sûre, le certificat de chaque nouvelle autorité, ce qui complique la relève (décision `06-releve-de-l-autorite`). Et cela ne dit pas si Traefik admet bien cette autorité : seul l'essai le dit.

### essai-puis-retour-arriere

**Retenue.** Le régulateur garde en mémoire non volatile le certificat en place et sa clé, et, à côté, un candidat et sa clé. Il vérifie seulement que le candidat porte sa clé en attente. Puis il ferme sa connexion et se reconnecte avec le candidat, sans redémarrer. Si Traefik l'admet et que Mosquitto accepte le compte, le candidat devient le certificat en place, l'ancien est effacé, et l'adoption se publie sur `event`. Sinon, il se reconnecte avec l'ancien, publie le refus et sa raison, et oublie le candidat. Un redémarrage pendant l'essai repart toujours du certificat en place.

**Pour** — la supervision ne manque que les quelques secondes d'une reconnexion, même quand le certificat est refusé. C'est Traefik qui juge, c'est-à-dire celui qui jugera de toute façon. Rien ne redémarre.
**Contre** — deux certificats et deux clés en mémoire non volatile pendant l'essai. Un certificat refusé coûte une reconnexion de plus. Une coupure du courtier au moment précis de l'essai se lit comme un refus : le régulateur refera une demande, sans rien perdre d'autre.

## Décision

`essai-puis-retour-arriere`. Ce qui a tranché : c'est la seule option où un certificat défectueux ne coûte rien de plus qu'une reconnexion, et où celui qui juge est le seul dont l'avis compte, Traefik.
