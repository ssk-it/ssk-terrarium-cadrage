---
id: 02-compte-et-sujets
titre: Sous quel compte, et sur quels sujets, le certificat signé est-il remis ?
statut: retenue
option_retenue: compte-certificats-hors-de-cmd
---

## Description

Quelqu'un doit publier le certificat signé et, au besoin, demander au régulateur un renouvellement. RG-courtier-authentifie, telle que la propose 2026-011, ne connaît que deux comptes sur `mq.ssk-it.fr`. `terrarium` publie l'état et ne lit que ses `cmd/#`. `proprietaire` lit tout `ssk-terrarium/#` et publie sur les `cmd/#`. Sur `mq-ws.ssk-it.fr`, `sterrarium` écrit lui aussi dans `cmd/#`. Le compte `proprietaire` est celui de tous les jours : MQTT Explorer, `mosquitto_sub`. RG-topics-mqtt n'applique jamais une commande retenue. Or un certificat doit pouvoir attendre un régulateur déconnecté.

## Options

### sous-cmd-par-proprietaire

`cmd/certificat`, publié par `proprietaire`.

**Pour** — aucun compte ni droit à ajouter.
**Contre** — tout compte qui écrit dans `cmd/#`, `sterrarium` compris, pourrait remettre un certificat. Le compte de tous les jours gagne un pouvoir qu'il n'exerce qu'une fois l'an. Un sujet `cmd/` suit en plus la règle des commandes, jamais retenues : un régulateur déconnecté à ce moment-là ne recevrait rien.

### proprietaire-hors-de-cmd

Un sujet hors de `cmd/`, que `proprietaire` est seul à pouvoir écrire, en plus de ses droits actuels.

**Pour** — pas de compte de plus.
**Contre** — le compte de tous les jours, et le Mac où il sert, peuvent alors remettre un certificat. Le moindre privilège voudrait l'inverse.

### compte-certificats-hors-de-cmd

**Retenue.** Un compte `certificats`, qui sert à `appliquer.sh` et à rien d'autre. Il lit `ssk-terrarium/+/certificat` et publie sur `ssk-terrarium/+/certificat/signe`, retenu, et sur `ssk-terrarium/+/certificat/demander`, jamais retenu. Il ne lit ni n'écrit rien d'autre. Le régulateur publie `certificat` et lit `certificat/signe` et `certificat/demander`. `proprietaire` garde ses droits : il lit `certificat`, qui ne contient rien de secret, et n'y écrit pas.

**Pour** — remettre un certificat et commander le régulateur sont deux pouvoirs séparés, tenus par deux comptes. `sterrarium`, qui n'écrit que dans `cmd/#`, ne peut rien remettre. Le certificat signé peut être retenu, puisque ce n'est pas une commande : un régulateur déconnecté le reçoit à sa reconnexion, et il ignore de toute façon un certificat qui ne porte pas sa clé en attente. La demande forcée, elle, garde les règles des commandes.
**Contre** — un compte de plus, avec son mot de passe et son certificat, qu'il faut aussi renouveler, sur le Mac. Et trois sujets à ajouter aux droits de Mosquitto.

## Décision

`compte-certificats-hors-de-cmd`. Ce qui a tranché : le compte qu'on emploie tous les jours, et ceux qui écrivent dans `cmd/#`, ne doivent pas pouvoir remettre de certificat. Le compte qui le peut ne doit rien pouvoir commander.
