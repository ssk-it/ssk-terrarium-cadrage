---
id: 06-licence-du-regulateur
titre: Comment le régulateur reçoit-il sa licence Skaron ?
statut: retenue
option_retenue: commande-mqtt
---

## Description

Skaron refuse toute demande sans jeton de licence valide. Le jeton est propre à chaque régulateur, pour que le quota et la trace `seen/` le soient aussi. Le dépôt et l'image sont publics, et ne portent aucun identifiant (RG-configuration-wifi-sur-place). La licence n'autorise qu'à télécharger une image signée, donc publique : sa fuite permet de consommer le quota, pas d'installer quoi que ce soit.

## Options

### compilee

Le jeton dans le firmware, à la compilation.

**Pour** — rien à transmettre.
**Contre** — l'image est publique, et une image ne sert qu'un régulateur. Écartée pour la même raison que les identifiants Wi-Fi compilés (2026-002, décision 01).

### portail-sur-place

Un champ de plus sur la page de configuration du Wi-Fi.

**Pour** — même chemin que les autres identifiants.
**Contre** — il faut aller au garage, avec le portail ouvert, pour un régulateur déjà en service : c'est le passage que la mise à jour à distance existe pour éviter.

### commande-mqtt

**Retenue.** `{"licence":"<jeton>"}` sur `cmd/mise-a-jour`, enregistrée en mémoire non volatile, jamais publiée ni journalisée. La liaison série l'accepte aussi. Le script `outils/licence-mise-a-jour.sh` l'émet par le CLI de Skaron et la publie lui-même, sans l'afficher.

**Pour** — se fait à distance, une fois par régulateur. Le jeton transite par le courtier sur TLS, entre des comptes qui sont tous ceux du propriétaire.
**Contre** — le jeton passe par le courtier, ce qui est acceptable au vu de ce qu'il protège. Un compte qui commande peut remplacer la licence, et donc empêcher la mise à jour, sans pouvoir rien installer.

## Décision

`commande-mqtt`. Le critère qui a tranché : la licence ne protège pas l'image, c'est la signature qui la protège. Elle peut donc suivre le chemin des commandes, qui est le seul chemin à distance.
