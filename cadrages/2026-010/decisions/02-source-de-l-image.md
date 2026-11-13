---
id: 02-source-de-l-image
titre: Où le régulateur télécharge-t-il l'image ?
statut: retenue
option_retenue: skaron
---

## Description

Le firmware vérifie ses certificats contre ISRG Root X1 et ISRG Root YR seules (ADR-supervision-par-mqtt-tls). Une source servie sous une autre autorité demanderait d'embarquer d'autres racines, et de suivre leurs changements. Le dépôt du firmware est public, et l'image ne porte aucun secret. Le propriétaire veut savoir quel régulateur a téléchargé quoi, et pouvoir couper l'accès d'un appareil.

## Options

### skaron

**Retenue.** Skaron (`ssk-it/skaron`), le service de distribution de mises à jour de SSK IT, sous un produit `ssk-terrarium` et une cible `esp32-phase-<N>`.

**Pour** — tout existe :
- la licence par appareil, révocable ;
- le quota de dix URL par heure ;
- la trace `seen/` de la version annoncée ;
- les artefacts privés, livrés par URL présignée de quinze minutes ;
- un manifeste changé en dernier à la publication.

La route `/v1/{prd}/{target}/{arch}/{version}` accepte `esp32/phase-1` sans changer une ligne du service. `api.skaron.ssk-it.fr` et `s3.fr-par.scw.cloud` présentent des chaînes Let's Encrypt qui remontent à ISRG Root YR (mesuré le 11 novembre 2026).
**Contre** — une licence à émettre et à transmettre par régulateur. Le premier appel peut subir le démarrage à froid du conteneur. Le service ne garde qu'une version par canal, ce qui pèsera le jour d'une phase 2. Le firmware dépend d'un contrat de réponse pensé pour l'updater de Tauri.

### releases-github

`firmware.bin` attaché à la release du dépôt public, téléchargé par son URL.

**Pour** — rien à créer : la CI publie déjà les releases.
**Contre** — `github.com` présente une chaîne USERTrust : une racine de plus à embarquer, avant la redirection vers `release-assets.githubusercontent.com`, sur une chaîne que GitHub peut changer sans prévenir. Ni licence, ni trace, ni révocation.

### bucket-dedie

Un bucket Scaleway public, alimenté par la CI ou par un script.

**Pour** — chaîne ISRG, et rien entre le régulateur et l'image.
**Contre** — un bucket et une politique de plus à tenir, sans trace ni révocation : c'est refaire, moins bien, ce que Skaron fait déjà.

### cluster-ssk-it-01

Un petit serveur statique sur le cluster, à côté de Mosquitto.

**Pour** — même certificat Let's Encrypt que le courtier.
**Contre** — ADR-courtier-mosquitto-sur-ssk-it-01 veut un cluster qui ne porte que le courtier. Ce serait un service de plus à exposer et à mettre à jour, pour un téléchargement par mois.

## Décision

`skaron`, à la demande du propriétaire. Le critère qui a tranché : c'est la seule source qui donne une licence révocable et une trace par appareil sans rien écrire. Elle n'ajoute pas non plus de racine au firmware.
