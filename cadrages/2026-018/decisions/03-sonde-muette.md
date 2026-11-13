---
id: 03-sonde-muette
titre: Le comportement sur sonde muette se règle-t-il, et jusqu'où ?
statut: retenue
option_retenue: reprise-air-ou-maintien-plancher
---

## Description

2026-005 (décision `03-sonde-muette`) a retenu que la coupure tient 2 minutes puis se lève, et écarté `reste-coupe`, parce qu'une sonde débranchée couperait le chauffage pour toujours, hors-gel compris : « l'élevage peut geler pour une sonde optionnelle ». Le propriétaire demande de choisir le comportement.

## Options

### delai-seul

Le comportement reste `reprise-air` ; seul le délai se règle.

**Pour** — l'option écartée en 2026-005 le reste.
**Contre** — on ne peut pas choisir de ne pas rechauffer un substrat qu'on a vu chaud, ce que la demande vise.

### reprise-air-ou-maintien

`reprise-air` avec son délai, ou `maintien` : la coupure tient jusqu'à une mesure valide sous la reprise.

**Pour** — le choix demandé.
**Contre** — `maintien` rouvre le risque de gel exactement comme 2026-005 l'avait décrit.

### reprise-air-ou-maintien-plancher

**Retenue.** `reprise-air` (par défaut, délai de 1 à 30 minutes, 2 par défaut) ou `maintien` ; en `maintien`, la coupure se lève quand même dès que l'air retenu descend sous 4 °C, le bas du hors-gel. Ce plancher n'est pas un réglage.

**Pour** — le choix demandé, sans le risque de gel : sous 4 °C, un substrat chaud n'est plus la menace.
**Contre** — une règle de plus à tenir, et un plancher qui dépend d'une mesure de l'air : sans aucune sonde d'air acceptée, le défaut capteur coupe déjà le chauffage (RG-capteur-en-defaut), et le plancher ne change rien.

## Décision

`reprise-air-ou-maintien-plancher`. Ce qui a tranché : le motif de 2026-005 — une sonde optionnelle ne doit pas pouvoir empêcher le hors-gel — tient toujours ; il est gardé par le plancher plutôt que par l'interdiction de `maintien`.
