---
id: 01-role-des-sondes
titre: Quelles sondes ont un rôle réglable ?
statut: retenue
option_retenue: deux-roles-reglables
---

## Description

Le propriétaire veut choisir depuis l'application si une sonde sert à la régulation (intérieure) ou n'est que publiée (extérieure). La question : ce choix porte-t-il sur le seul DHT11, ou sur les deux sondes ?

Elle est difficile parce que ADR-capteur-air-sht45 a écarté le DHT22 pour l'air du bac : il dérive au-dessus de 80 % HR, là où vit le bac, et son protocole est peu fiable sur un câble long. Le DHT11 a le même protocole et une précision moindre : humidité garantie de 20 à 90 % HR à ±5 %, température de 0 à 50 °C à ±2 °C, par pas de 1 °C.

## Options

### sht45-fixe-dht11-reglable

La SHT45 est toujours intérieure. Seul le DHT11 se règle, `exterieure` ou `interieure`.

**Pour** — il reste toujours une sonde intérieure, sans qu'aucun garde-fou ait à le vérifier. La SHT45, la sonde fiable, n'est jamais écartée de la régulation par un réglage, et l'ADR n'est modifiée qu'à la marge.
**Contre** — le DHT11 ne peut jamais réguler seul. Une SHT45 qu'on sait défaillante, mais qui rend des mesures plausibles, ne peut pas être écartée sans recâbler.

### deux-roles-reglables

**Retenue.** Chaque sonde a son rôle, réglable. Une commande qui ne laisserait aucune sonde intérieure est refusée en entier.

**Pour** — le propriétaire peut écarter une sonde qu'il sait fausse, quelle qu'elle soit, sans toucher au câblage. Les deux sondes se traitent de la même façon.
**Contre** — un réglage peut faire réguler le bac sur le seul DHT11, la SHT45 étant en état de marche. La garantie « au moins une sonde intérieure » repose sur un contrôle du firmware, et non plus sur la structure.

## Décision

`deux-roles-reglables`, choisi par le propriétaire le 2026-11-10, contre la recommandation `sht45-fixe-dht11-reglable` qui lui avait été présentée. Ce qui a tranché : pouvoir écarter n'importe quelle sonde depuis l'application. Le risque d'une régulation sur le seul DHT11 est accepté, et borné par le refus de toute configuration sans sonde intérieure (RG-reglages-bornes). Par défaut, la SHT45 reste seule intérieure (RG-mode-au-demarrage).
