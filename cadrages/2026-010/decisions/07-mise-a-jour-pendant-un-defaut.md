---
id: 07-mise-a-jour-pendant-un-defaut
titre: Un défaut en cours empêche-t-il une mise à jour ?
statut: retenue
option_retenue: avertir
---

## Description

Le cadrage refusait d'abord toute installation pendant un défaut : `defaut_capteur`, une sonde d'air en défaut, une mesure du substrat rejetée, une coupure par le substrat ou une pause de chauffe. La réalisation (ssk-terrarium#27) a montré ce que la règle attrape. La sonde du substrat et le DHT11 sont facultatifs, et une sonde absente se lit comme muette. Un régulateur qui n'en a pas refuse donc toute mise à jour à distance, sans qu'aucun défaut ne touche sa régulation. C'est le cas de la carte du bureau.

## Options

### refuser

Le régulateur refuse l'installation pendant tout défaut, et un défaut qui apparaît pendant le téléchargement l'interrompt.

**Pour** — le firmware en place, seul à connaître le défaut, le gère jusqu'au bout. Aucun redémarrage ne s'ajoute à une situation dégradée.
**Contre** — une sonde absente, ou une sonde extérieure en défaut, bloque à jamais la mise à jour d'un bac qui régule normalement. Un correctif qui règle justement un défaut ne peut pas s'installer à distance.

### refuser-ce-qui-pese-sur-le-chauffage

Seuls l'air intérieur en défaut, une sonde intérieure en défaut, la coupure par le substrat et la pause de chauffe bloquent. Une sonde extérieure en défaut, ou une sonde du substrat absente dès le démarrage, ne bloquent pas.

**Pour** — garde la protection là où le chauffage est en jeu.
**Contre** — distinguer une sonde absente d'une sonde qui lâche demande un état de plus, et un correctif pour un défaut de l'air intérieur ne s'installe toujours pas à distance.

### avertir

**Retenue.** Aucun défaut n'empêche ni n'interrompt l'installation. Chacun est nommé : `defauts` dans `acceptee`, et l'étape `avertissement` pour un défaut qui apparaît pendant le téléchargement.

**Pour** — le propriétaire décide en connaissance de cause, et l'application lui montre les défauts avant qu'il ne confirme. Un correctif s'installe même quand c'est lui qui règle le défaut.
**Contre** — le redémarrage, sorties coupées, s'ajoute à une situation dégradée, et les délais de détection repartent de zéro. Un nouveau firmware installé pendant un défaut de l'air intérieur risque de ne retenir aucune mesure en 5 minutes, et d'être défait par RG-retour-arriere-automatique.

## Décision

`avertir`, par le propriétaire, le 11 novembre 2026. Le critère qui a tranché : l'installation reste un geste du propriétaire, qui voit les défauts nommés. Un refus aurait bloqué des bacs qui régulent normalement.
