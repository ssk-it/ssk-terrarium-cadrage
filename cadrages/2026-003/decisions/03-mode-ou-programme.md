---
id: 03-mode-ou-programme
titre: Les plages sont-elles un mode, ou un programme qui change de mode ?
statut: retenue
option_retenue: quatrieme-mode
---

## Description

Le comportement demandé alterne deux régimes de chauffe selon l'heure. On peut le porter par un mode à part, par un réglage d'`ACTIF`, ou par un programme qui bascule entre deux modes existants.

## Options

### quatrieme-mode

**Retenue.** Un mode `PLAGES`, choisi par commande ; le passage en plage et hors plage fait partie de son comportement.

**Pour** — RG-changement-de-mode-manuel reste entière ; `ACTIF` garde son sens ; le mode publié dit tout ce qu'il faut savoir.
**Contre** — F6, RG-sorties-par-mode et `cmd/mode` changent.

### plages-dans-actif

`ACTIF` gagne des plages ; sans plage, il chauffe à la consigne comme aujourd'hui.

**Pour** — aucun mode de plus.
**Contre** — `ACTIF` ne dit plus à lui seul ce que fait le chauffage ; une plage oubliée en mémoire change silencieusement le comportement d'un mode connu.

### bascule-automatique

Un programme fait passer le régulateur d'`ACTIF` à un mode plancher selon l'heure.

**Pour** — réutilise les modes.
**Contre** — contredit RG-changement-de-mode-manuel, écrite pour qu'aucun mode ne change sans commande.

## Décision

`quatrieme-mode`. Ce qui a tranché : RG-changement-de-mode-manuel, qu'aucune des autres options ne laisse intacte sans ambiguïté.
