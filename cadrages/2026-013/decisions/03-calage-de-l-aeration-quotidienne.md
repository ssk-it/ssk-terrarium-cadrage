---
id: 03-calage-de-l-aeration-quotidienne
titre: Sur quoi se cale l'aération quotidienne d'hibernation, et le cycle d'activité ?
statut: retenue
option_retenue: heure-avec-repli
---

## Description

NF5 range les cycles de ventilation parmi ce qui dépend de l'heure. Or le régulateur n'a pas d'horloge (ADR-heure-par-ntp) : l'heure se perd à chaque redémarrage et ne revient qu'avec le NTP. La piste #8 propose une heure estimée après un démarrage sans réseau (RG-heure-ntp), mais elle n'est pas cadrée, et elle relève de l'éclairage. Il fallait dire sur quoi se calent l'aération quotidienne de `HIBERNATION` et le cycle de `ACTIF`, sans lier la ventilation à l'éclairage.

## Options

### ecoulement-seul

Tout se compte en durée écoulée depuis le démarrage ou le changement de mode : une période en `ACTIF`, 24 heures en `HIBERNATION`, chaque cycle commençant par une aération.

**Pour** — aucune dépendance au réseau ni à l'heure ; la ventilation marche dès le premier démarrage.
**Contre** — l'aération quotidienne tombe à une heure quelconque, celle où le régulateur a démarré, éventuellement en pleine nuit, quand l'air du garage est le plus froid.

### heure-fixe-seule

L'aération quotidienne commence à une heure réglée, dans le fuseau réglé.

**Pour** — le propriétaire choisit le moment de la journée.
**Contre** — tant que l'heure est inconnue, rien ne ventile. Pour ne pas sauter d'aération, il faudrait l'heure estimée de RG-heure-ntp, et lier ce chantier à celui de l'éclairage.

### heure-avec-repli

**Retenue.** Les deux, chacun là où il vaut. En `ACTIF` et en `PLAGES`, les périodes se comptent en durée écoulée : « 5 minutes par heure » n'a pas besoin de l'heure. En `HIBERNATION`, l'aération commence à l'heure réglée quand l'heure est connue ; tant qu'elle ne l'est pas, elle commence 24 heures après la précédente, ou après le démarrage ou l'entrée dans le mode. Deux aérations n'ont jamais lieu à moins de 12 heures d'intervalle, pour que le retour de l'heure n'en fasse pas tomber deux le même jour. Par défaut, l'heure est 13:00 : au plus chaud du garage, l'aération ne fait jamais entrer l'air le plus froid de la journée dans un bac en hors-gel.

**Pour** — l'aération tombe à l'heure choisie dès que l'heure est là, et n'est jamais sautée faute d'heure. Seule « l'heure connue » d'ADR-heure-par-ntp est employée, comme le fait déjà le mode `PLAGES` : la ventilation ne dépend pas de la piste #8.
**Contre** — sans heure, l'aération dérive à l'heure du démarrage, et son retour peut espacer deux aérations de 12 à 36 heures. Un réglage de plus, `heure`, à borner et à afficher.

## Décision

`heure-avec-repli`, au choix du propriétaire. Ce qui a tranché : garder le moment choisi quand on le connaît, sans jamais priver le bac de son aération quand on ne le connaît pas — et sans attendre le cadrage de l'éclairage pour livrer la ventilation.
