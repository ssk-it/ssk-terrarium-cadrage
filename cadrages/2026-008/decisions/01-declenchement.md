---
id: 01-declenchement
titre: Quand la SHT45 doit-elle se chauffer ?
statut: retenue
option_retenue: seuil-95-au-plus-toutes-les-5-minutes
---

## Description

La chauffe sert à évaporer l'eau déposée sur la puce. Elle a un coût : tant que la puce n'a pas refroidi, sa mesure est faussée (température trop haute, humidité trop basse), et Sensirion limite son chauffage à 10 % du temps. Il faut chauffer assez tôt pour que la sonde ne reste pas trempée, sans chauffer en continu un bac qui serait réellement saturé, puisque la chauffe n'y changerait rien.

95 % HR est le seuil d'alerte haute prévu par la fonction F9 de 2026-001, au-dessus de la plage du bac (75 à 90 % HR, objectif O2).

## Options

### seuil-95-au-plus-toutes-les-5-minutes

**Retenue.** Chauffer après un relevé à 95 % HR ou plus, ou rejeté pour `humidite-hors-plage`, au plus une fois toutes les 5 minutes.

**Pour** — la sonde se chauffe avant d'être trempée au point de rendre plus de 100 %. La chauffe n'occupe la sonde qu'une seconde toutes les 5 minutes au plus, soit 0,3 % du temps. Un bac saturé ne fait pas chauffer la puce à chaque relevé.
**Contre** — une sonde trempée attend jusqu'à 5 minutes avant sa chauffe suivante.

### seuil-95-a-chaque-releve

Même seuil, sans intervalle minimal : une chauffe après chaque relevé concerné, jusqu'à une toutes les 30 secondes.

**Pour** — la sonde est chauffée aussi souvent qu'elle peut l'être, et sort plus vite de la condensation.
**Contre** — 3,3 % du temps de chauffe dans un bac saturé, pour aucun effet, et une puce qui ne refroidit jamais tout à fait entre deux relevés.

### sur-rejet-seulement

Chauffer seulement quand le relevé est rejeté pour `humidite-hors-plage`.

**Pour** — la chauffe est rare, et ne vise que le cas observé le 9 novembre.
**Contre** — elle attend que la sonde soit trempée et sa mesure perdue. La dérive de la sonde entre 95 et 100 % HR n'est jamais corrigée.

### periodique

Chauffer à intervalle fixe, par exemple toutes les heures, quelle que soit l'humidité.

**Pour** — rien à seuiller : la sonde est entretenue même quand elle n'en a pas besoin.
**Contre** — la chauffe ne suit pas la condensation : une sonde trempée peut attendre une heure, et une sonde sèche se chauffe pour rien.

## Décision

`seuil-95-au-plus-toutes-les-5-minutes`, choisie par le propriétaire le 2026-11-10. Ce qui a tranché : chauffer dès que l'humidité approche de la saturation, mais pas sans fin, parce que la chauffe ne fait rien contre un air réellement saturé.
