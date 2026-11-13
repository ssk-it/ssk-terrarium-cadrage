---
id: 01-emetteur-des-alertes
titre: Qui émet l'alerte sur téléphone ?
statut: retenue
option_retenue: supervision-sur-le-serveur
---

## Description

Trois acteurs voient l'état du terrarium : le régulateur, qui le produit ; le serveur, où le courtier et l'historique le reçoivent ; le téléphone, quand sterrarium y est ouvert. L'architecture cible de 2026-001 faisait partir l'alerte de l'ESP vers ntfy, et le firmware en garde des fonctions vides (`lib/alerts`).

Ce qui rendait la question difficile : un régulateur hors ligne ne peut pas signaler lui-même qu'il l'est, et c'est l'un des cas qu'on veut le plus connaître. Un téléphone en veille, lui, coupe ses connexions selon les règles d'Android.

## Options

### firmware-vers-ntfy

Le régulateur envoie lui-même l'alerte, en HTTPS, à ntfy, en dehors du chemin de la régulation.

**Pour** — c'est la voie de la feuille de route, sans aucun composant serveur de plus ; le régulateur connaît mieux que quiconque ses défauts, et la cause d'un redémarrage.
**Contre** — il ne peut pas annoncer son propre silence. Tant que la mise à jour à distance (piste #15) n'existe pas, chaque réglage d'une alerte demande de reflasher la carte par USB. Son envoi tient de la mémoire et du temps sur un microcontrôleur qui régule, sous RG-regulation-sans-reseau.

### service-android

sterrarium garde, sur Android, un service au premier plan abonné au courtier, et notifie lui-même.

**Pour** — aucun composant serveur ; l'application connaît déjà l'état et ses définitions de fraîcheur.
**Contre** — un plugin natif Kotlin à écrire derrière un port, un service au premier plan et sa notification permanente. La connexion WebSocket doit tenir sous le Doze avec un keepalive de 45 s au plus. Le bureau et le web n'alertent pas application fermée. C'est le plus de travail pour la fiabilité la plus faible.

### firmware-et-veilleur

Le firmware alerte de ce qu'il voit ; un veilleur, sur le serveur, n'alerte que du silence.

**Pour** — chaque alerte part de l'acteur qui la voit le mieux.
**Contre** — deux émetteurs, deux façons de régler, deux formes de message à tenir cohérents, et toujours le flash USB pour changer une alerte du firmware.

### supervision-sur-le-serveur

**Retenue.** vmalert évalue les alertes sur l'historique VictoriaMetrics déjà déployé, et Alertmanager les pousse vers ntfy.

**Pour** — couvre le silence ; toutes les alertes sont au même endroit ; une alerte se change sans toucher à la carte ; aucun compte MQTT de plus, puisque vmalert lit l'historique ; la régulation n'y est pour rien.
**Contre** — trois composants de plus sur ssk-it-01, contre le motif de 2026-002/03 ; ne voit que ce que le régulateur publie (pas la cause d'un redémarrage) ; une panne du cluster fait taire les alertes.

## Décision

`supervision-sur-le-serveur`, choisie par le propriétaire le 11 novembre 2026. Ce qui a tranché : c'est la seule option qui alerte d'un régulateur qui ne peut plus rien dire. L'historique, déjà sur le cluster, avait ouvert la porte qu'elle emprunte.
