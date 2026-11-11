---
id: 04-option-saturation
titre: Que fait le ventilateur quand l'air du bac reste saturé ?
statut: retenue
option_retenue: option-a-deux-comportements
---

## Description

Le propriétaire veut pouvoir faire tourner le ventilateur quand l'humidité reste au-dessus d'un seuil, au-delà du rythme de jour et de nuit. Mais le bac vit près de la saturation : un déclenchement mal borné ferait tourner le ventilateur sans fin, et dessécherait le bac. Et c'est la première fois que la ventilation dépendrait d'une mesure.

## Options

### aeration-puis-pause

Humidité au-dessus du seuil pendant une attente : une aération de durée réglée, puis une pause avant le déclenchement suivant.

**Pour** — toujours borné : une aération, puis une pause.
**Contre** — l'aération tourne sa durée même si l'air redescend tout de suite.

### tant-que-c-est-sature

Le ventilateur tourne tant que l'humidité reste au-dessus du seuil, au plus une durée maximale, puis une pause.

**Pour** — il s'arrête dès que l'air redescend.
**Contre** — un seuil bas le fait tourner à chaque fois sa durée maximale.

### option-a-deux-comportements

**Retenue.** Une option inactive par défaut, dont le propriétaire choisit le comportement, `aeration` ou `continu`, l'humidité, l'attente, la durée et la pause, dans des bornes. Elle se tait quand la mesure de l'air manque, et l'emporte sur le rythme de jour, de nuit ou d'hibernation pendant qu'elle tourne.

**Pour** — les deux comportements, au choix, toujours bornés ; rien ne change sans l'activer.
**Contre** — six réglages de plus.

## Décision

`option-a-deux-comportements`, au choix du propriétaire. Ce qui a tranché : quel que soit le comportement, la durée et la pause bornent ce que l'option peut faire, et une sonde muette ne la déclenche jamais.
