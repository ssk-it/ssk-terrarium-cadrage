---
id: 04-periodes-et-pas
titre: Quelles périodes résumer, à quel pas, et avec quoi dans chaque fenêtre ?
statut: retenue
option_retenue: quatre-periodes-moyenne-et-extremes
---

## Description

Les résumés ne se demandent pas : ils se publient (décision `02-lecture-hors-du-cluster`). Il faut donc choisir d'avance quelles périodes l'application pourra montrer, et ce que chaque point en garde.

Le choix des périodes est celui de la vue (sterrarium-cadrage 2026-007). Le pas et le contenu d'une fenêtre relèvent du contrat. Une courbe lisible sur un écran de téléphone tient en 300 points environ, et le résumé d'une année doit rester petit pour un message MQTT retenu.

## Options

### une-seule-periode

Les 24 dernières heures, à 5 minutes.

**Pour** — le plus petit des contrats.
**Contre** — ni la semaine, ni l'hiver : l'objectif H1 n'est pas atteint dans l'application.

### quatre-periodes-moyenne-seule

24 heures, 7 jours, 30 jours et un an, avec la seule moyenne de chaque fenêtre.

**Pour** — un résumé deux à trois fois plus petit.
**Contre** — une nuit à 9 °C disparaît dans la moyenne d'une fenêtre de deux heures, et d'autant plus dans celle d'un jour. C'est précisément ce qu'on cherche dans un historique de terrarium.

### quatre-periodes-moyenne-et-extremes

**Retenue.** 24 heures à 5 minutes, 7 jours à 30 minutes, 30 jours à 2 heures, un an à un jour : 288 à 365 fenêtres chacune. Chaque fenêtre garde la moyenne, le minimum, le maximum et le nombre de mesures acceptées. Le résumé compte aussi les états reçus, et la part du temps où chaque sortie était allumée.

**Pour** — environ 300 points par courbe, à toutes les échelles. Les extrêmes survivent au pas. Le compte des mesures dit si une fenêtre est entière, partielle ou vide, et celui des états distingue un silence d'un rejet. De l'ordre de 100 Ko pour l'année.
**Contre** — quatre résumés à republier toutes les 5 minutes, dont trois changent bien plus lentement. Une fenêtre d'un jour va de minuit à minuit UTC, une heure plus tôt que minuit à Paris en hiver.

## Décision

`quatre-periodes-moyenne-et-extremes`. Ce qui a tranché : le minimum et le maximum de chaque fenêtre. Ce sont eux qui disent si l'élevage a eu froid, et la moyenne seule les efface.
