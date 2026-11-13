---
id: 01-sortie-du-cable-de-l-air
titre: Sur quelle sortie brancher le câble de l'air ?
statut: retenue
option_retenue: relais-de-l-eclairage
---

## Description

Le câble de 4,5 m / 25 W doit chauffer l'air pendant que le substrat est coupé. Le module de relais a quatre relais, tous attribués : chauffage, LED, pompe, ventilateur (RG-brochage). Il n'y a ni relais ni GPIO de sortie en réserve.

Le relais LED n'a pourtant jamais rien commandé : RG-sorties-par-mode tient l'éclairage coupé dans tous les modes, jusqu'au cadrage de la phase 4, qui n'existe pas. Le ruban LED de la nomenclature de 2026-001 n'est pas piloté par le régulateur.

## Options

### meme-relais

Brancher le câble de l'air sur la multiprise du relais de chauffage, à côté du câble du substrat : c'est le renfort que prévoyait la section « Puissance de chauffe » de 2026-001.

**Pour** — aucun matériel, aucune ligne de firmware.
**Contre** — la coupure par le substrat coupe les deux câbles ensemble. L'air chute donc toujours pendant une coupure, et c'est précisément le défaut à corriger.

### module-supplementaire

Ajouter un relais ou un second module sur une GPIO libre, et garder le relais LED pour l'éclairage.

**Pour** — l'éclairage garde sa sortie pour la phase 4.
**Contre** — du matériel en plus dans le boîtier, une alimentation des bobines à revoir, et les garde-fous de RG-relais-coupes-sans-commande à vérifier sur un second module. Le module 6 relais avait été écarté dans 2026-001 (en rupture, fiche incomplète).

### relais-de-l-eclairage

**Retenue.** Le relais LED (GPIO 27) devient le relais du câble de l'air. La lampe sort du régulateur : elle passe sur un programmateur horaire autonome, non connecté.

**Pour** — aucun matériel à ajouter, un relais déjà câblé et déjà vérifié ; un programmateur horaire allume une lampe aussi bien que le régulateur, sans réglage ni firmware.
**Contre** — le régulateur ne pilotera pas l'éclairage : la phase 4 devra trouver une autre sortie si elle revient un jour. Le contact du relais commute désormais du 230 V : son câblage se refait comme celui du relais de chauffage.

## Décision

Le relais LED, qui ne commandait rien, devient celui du câble de l'air, et la lampe passe sur un programmateur autonome : choix du propriétaire le 13 novembre 2026. Ce qui a tranché : la chauffe de l'air est un besoin présent et mesuré, alors que le pilotage de l'éclairage par le régulateur n'a jamais été fait. Un programmateur autonome, non connecté, ne contredit pas ADR-commande-230v-par-relais-filaires : celle-ci écartait une prise connectée pour ne pas faire dépendre la régulation du Wi-Fi, et l'éclairage n'est plus une sortie du régulateur.
