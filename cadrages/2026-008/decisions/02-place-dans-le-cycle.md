---
id: 02-place-dans-le-cycle
titre: Où placer la chauffe par rapport aux relevés, et que fait la régulation pendant ce temps ?
statut: retenue
option_retenue: apres-le-releve
---

## Description

Après la chauffe, la puce met quelques secondes à refroidir. Une mesure prise pendant ce temps est fausse mais plausible : RG-capteur-en-defaut ne la rejette pas. Il faut donc qu'aucune mesure de ce moment n'entre dans la régulation. Avec 2026-007, une mesure de la SHT45 écartée fait aussi passer la régulation sur le DHT11, dès cette mesure, puis la ramène sur la SHT45 au relevé suivant : chaque chauffe ferait basculer la régulation deux fois.

Le propriétaire veut que la régulation garde, pendant la chauffe, ce qu'elle a décidé sur la dernière mesure : pas de bascule vers le DHT11, et pas de décompte sur les 2 minutes de tolérance.

## Options

### apres-le-releve

**Retenue.** La chauffe suit immédiatement le relevé qui la déclenche. La mesure rendue à la fin de la chauffe est jetée, et le relevé suivant tombe à l'heure habituelle, 30 secondes après.

**Pour** — aucun relevé ne tombe pendant le cycle : rien n'est écarté, aucune sonde ne prend le relais, et la régulation garde sa décision sans qu'aucune règle ait à le prévoir. La période de 30 secondes ne change pas. La puce a 29 secondes pour refroidir, bien plus qu'il ne lui en faut.
**Contre** — la mesure qui dit si la chauffe a suffi arrive 30 secondes après, pas plus tôt.

### remesure-anticipee

Une mesure de reprise, environ 10 secondes après la chauffe, hors de la période des 30 secondes.

**Pour** — on sait plus vite si la sonde est sèche.
**Contre** — un relevé de plus, hors période, qu'il faut loger dans RG-mesures-periodiques. Il est pris plus près de la chauffe, sur une puce plus chaude. Gagner 20 secondes ne change rien à un bac dont l'inertie se compte en heures.

### chauffer-avant-le-releve-et-l-ecarter

Chauffer juste avant un relevé, et écarter ce relevé comme une mesure rejetée.

**Pour** — la chauffe tombe toujours au même moment du cycle.
**Contre** — le relevé écarté fait basculer la régulation sur le DHT11 (RG-sondes-d-air), ou publie `air` à `null` sans DHT11, et compte dans les 2 minutes de tolérance. C'est exactement ce que le propriétaire ne veut pas.

## Décision

`apres-le-releve`, choisie par le propriétaire le 2026-11-10, avec la règle qu'il a posée d'abord : pendant la chauffe, la régulation garde la dernière mesure. Ce qui a tranché : placée entre deux relevés, la chauffe ne produit aucune mesure à écarter, et respecte cette règle sans en écrire une nouvelle.
