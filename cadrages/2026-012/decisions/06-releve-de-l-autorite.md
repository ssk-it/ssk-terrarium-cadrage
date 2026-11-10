---
id: 06-releve-de-l-autorite
titre: Comment relever l'autorité, à son échéance ou après une compromission ?
statut: retenue
option_retenue: deux-autorites-le-temps-de-la-releve
---

## Description

L'autorité vaut dix ans. Elle doit aussi pouvoir être refaite à tout moment, si sa clé est perdue ou volée : Traefik ne lit pas de liste de révocation, et 2026-011 compte, pour retirer un certificat, sur le changement du mot de passe puis la réfection de l'autorité et des autres certificats. Tant que Traefik n'admet qu'une autorité, en changer refuse aussitôt tous les clients signés par l'ancienne. Le `clientAuth` d'une `TLSOption` de Traefik admet plusieurs certificats d'autorité.

## Options

### nouvelle-autorite-et-portail

On remplace l'autorité dans Traefik, et l'on remet chaque certificat par le portail.

**Pour** — rien à écrire de plus que 2026-011.
**Contre** — la supervision est coupée de l'instant du remplacement jusqu'au passage au garage, et c'est le geste rare qu'on aura oublié.

### autorite-intermediaire

Une racine de longue durée, gardée hors ligne, signe une autorité intermédiaire, qui signe les clients. Traefik n'admet que la racine.

**Pour** — relever l'intermédiaire ne change rien chez Traefik.
**Contre** — une clé de plus à garder, et une chaîne que le régulateur doit présenter en entier, ce qui alourdit sa poignée de main. Et la racine elle-même finira par expirer ou par fuir, ce qui ramène à la question de départ.

### deux-autorites-le-temps-de-la-releve

**Retenue.** `sceller-secrets.sh` fabrique la nouvelle autorité. `appliquer.sh` fait admettre par la `TLSOption mqtt` son certificat à côté de l'ancien, puis renouvelle chaque client : sur `certificat/demander` pour le régulateur, et dans le trousseau pour les comptes du Mac. Il retire l'ancienne autorité dès que chaque client a publié un certificat signé par la nouvelle. La relève commence au plus tard quand l'autorité n'a plus que la durée d'un certificat et 90 jours devant elle. Après une compromission, elle commence tout de suite, et s'accompagne du changement des mots de passe, comme le prévoit 2026-011.

**Pour** — aucun client ne perd la connexion. Le geste est le renouvellement ordinaire, éprouvé chaque année, et seule l'admission d'une seconde autorité s'y ajoute. Le régulateur n'a pas à connaître l'autorité (décision `04-adoption`).
**Contre** — pendant la relève, une autorité compromise reste admise jusqu'à ce que tous les clients aient adopté leur nouveau certificat. Le mot de passe exigé par Mosquitto rend un certificat forgé inutile à lui seul. Il faut un état de la relève, que `appliquer.sh` lit sur les `certificat` publiés.

## Décision

`deux-autorites-le-temps-de-la-releve`. Ce qui a tranché : la relève réemploie le renouvellement ordinaire, et le seul geste nouveau qu'elle demande, admettre une seconde autorité, se fait sur le cluster, depuis le Mac, sans toucher au régulateur.
