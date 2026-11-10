---
id: 05-ou-vit-le-reglage
titre: Où vit le réglage des alertes que sterrarium modifie ?
statut: retenue
option_retenue: dans-le-regulateur
---

## Description

Le propriétaire veut régler depuis sterrarium, sur le bureau comme sur le téléphone, les alertes qui lui sont envoyées. vmalert lit ses règles dans le dépôt ssk-it-infra, où l'application n'écrit pas : il les lira donc filtrées par un réglage historisé, comme le reste de l'état. Ce réglage doit vivre quelque part où les deux applications le lisent et l'écrivent, et d'où Telegraf le reçoit.

## Options

### dans-le-regulateur

**Retenue.** `cmd/config` porte un objet `alertes`. Le régulateur le valide, l'enregistre en mémoire non volatile et le republie dans `state` toutes les 30 s, comme ses autres réglages.

**Pour** — une seule vérité, lue par tous les appareils ; le chemin des réglages existe déjà, avec ses bornes publiées et sa réponse sur `event` ; il revient de lui-même après un redémarrage du courtier, qui est sans persistance.
**Contre** — une évolution du firmware et un flash, tant que la mise à jour à distance n'est pas là. Le régulateur porte un réglage dont il ne se sert pas. Un régulateur hors ligne ne peut pas être réglé, mais ses alertes gardent le dernier réglage reçu.

### message-retenu-du-courtier

L'application publie le réglage sur un sujet retenu `ssk-terrarium/<id>/alertes`, que Telegraf historise.

**Pour** — aucun changement du firmware.
**Contre** — Mosquitto est sans persistance : au redémarrage du pod, le réglage retenu se perd, et l'application ne le relit plus, sauf à ajouter un volume au courtier. Il faut aussi un sujet et un droit de plus.

### abonnements-ntfy

Un sujet ntfy par alerte, choisi dans l'application ntfy elle-même.

**Pour** — rien à développer.
**Contre** — sterrarium ne règle rien, et les seuils restent figés.

## Décision

`dans-le-regulateur`, choisi par le propriétaire le 11 novembre 2026. Ce qui a tranché : c'est le seul endroit déjà persistant, déjà relu par les deux applications, et republié sans que personne ait à y penser.
