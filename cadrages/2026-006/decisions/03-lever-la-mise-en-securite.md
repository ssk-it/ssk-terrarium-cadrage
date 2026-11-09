---
id: 03-lever-la-mise-en-securite
titre: Peut-on lever la mise en sécurité d'une sonde depuis l'application, et pour combien de temps ?
statut: retenue
option_retenue: interrupteur-permanent
---

## Description

Le 9 novembre 2026, une humidité impossible (102 %) a coupé le chauffage alors que la température mesurée restait plausible (15,2 °C, pour une consigne de 19 °C) : le terrarium a refroidi, et rien ne permettait de relancer le chauffage à distance. Le propriétaire veut pouvoir désactiver et réactiver depuis l'application la mise en sécurité d'une sonde.

La difficulté : la mise en sécurité est la seule protection contre une chauffe à l'aveugle. La décision `06-protection-contre-la-surchauffe` de 2026-001 n'a retenu aucune protection matérielle en phase 1, et RG-chauffe-continue-bornee borne une durée, non une température.

## Options

### rejet-par-grandeur

Une humidité impossible ne coupe plus le chauffage, qui ne dépend que de la température ; un capteur muet ou une température impossible mettent toujours en sécurité. Aucun interrupteur.

**Pour** — règle le cas du 9 novembre sans jamais laisser chauffer sans température plausible.
**Contre** — ne laisse au propriétaire aucun recours quand c'est la température qui est rejetée, ou quand il juge lui-même le défaut sans danger. Revient aussi sur l'énoncé « une mesure rejetée l'est entière », alors qu'un SHT45 trempé peut fausser les deux grandeurs.

### interrupteur-temporaire

Le propriétaire suspend la mise en sécurité d'une sonde ; elle se réarme d'elle-même après un délai (24 h par exemple), et la suspension est publiée dans l'état.

**Pour** — un oubli ne laisse pas l'installation sans protection pour toujours.
**Contre** — le réarmement automatique peut recouper le chauffage en pleine nuit, sur le même défaut, sans que personne ne soit là pour le relever.

### interrupteur-permanent

**Retenue.** Le propriétaire active ou désactive la mise en sécurité de chaque sonde depuis l'application ; le choix est conservé en mémoire non volatile, sans limite de durée, jusqu'à ce qu'il le change.

**Pour** — le propriétaire garde la main sur son installation, dans les deux sens, et le choix survit à une coupure de courant.
**Contre** — désactivée, une sonde muette laisse les sorties dans leur dernier état, et une mesure fausse peut faire chauffer sans fin, à la seule coupure de 15 minutes toutes les 2 heures près ; sans protection matérielle, c'est un risque de surchauffe pour les animaux et pour l'installation. Un oubli le prolonge indéfiniment.

## Décision

`interrupteur-permanent`, choisi par le propriétaire le 9 novembre 2026, en connaissance du risque de surchauffe qu'il emporte. Ce qui a tranché : c'est au propriétaire, non au firmware, de décider si un défaut de sonde justifie de laisser refroidir le terrarium.

Ce qui en limite le risque, sans le lever : la durée maximale de chauffe continue s'applique toujours ; le rejet reste signalé et publié ; la désactivation est publiée dans `state`, signalée au démarrage, et l'application la rappelle en permanence. Une protection matérielle contre la surchauffe (thermostat de sécurité en série sur le chauffage) rendrait ce choix bien moins coûteux : elle reste hors de ce cadrage.
