---
id: 07-fusible-du-chauffage
titre: Faut-il un fusible sur la phase du chauffage dès la phase 1 ?
statut: retenue
option_retenue: sans-fusible-en-phase-1
---

## Description

Les deux câbles chauffants tirent 0,33 A (75 W sous 230 V). Sans fusible propre, seul le disjoncteur du circuit du garage, de 16 ou 20 A, protège la chaîne : un court-circuit entre 10 et 16 A, dans le boîtier ou sur un câble abîmé, passe sous lui, fait chauffer le fil 1 mm² et les contacts du relais, donnés pour 10 A, et peut souder ce contact. Le cadrage prévoyait un porte-fusible 5 × 20 et un fusible 1 A temporisé entre le cordon secteur et le relais. Au montage, le 08/11/2026, le propriétaire n'avait pas la pièce.

## Options

### fusible-1a-temporise

Un porte-fusible 5 × 20 et un fusible 1 A temporisé, entre la phase du cordon secteur et la borne COM du relais de chauffage.

**Pour** — coupe un court-circuit bien en dessous des 10 A du relais ; tolère une pointe de courant à la mise sous tension.
**Contre** — une pièce à acheter.

### fusible-1a-rapide

Le même porte-fusible, avec un fusible 1 A rapide.

**Pour** — coupe un court-circuit plus vite ; les câbles chauffants, résistifs, n'ont pas de pointe de courant.
**Contre** — une pièce à acheter ; saute à chaque mise sous tension si un appareil de la chaîne fait une pointe.

### sans-fusible-en-phase-1

**Retenue.** La phase du cordon secteur va directement à la borne COM du relais de chauffage.

**Pour** — rien à acheter.
**Contre** — un court-circuit entre 10 et 16 A n'est coupé par rien, et peut souder le contact du relais.

## Décision

Pas de fusible en phase 1. Ce qui a tranché : le propriétaire n'a pas la pièce, et tient la protection pour préventive. Le fusible 1 A temporisé reste la cible, reprise par [sskorupski/ssk-terrarium#10](https://github.com/sskorupski/ssk-terrarium/issues/10).
