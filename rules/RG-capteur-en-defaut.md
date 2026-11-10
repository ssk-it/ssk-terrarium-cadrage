---
id: RG-capteur-en-defaut
fonctionnalites: [protections, mesures]
statut: actif
cree_par: 2026-001
modifie_par: [2026-006]
---

Une mesure de l'air est rejetée quand le capteur ne répond pas (muet), ou quand elle est impossible dans le terrarium : température hors de −20 à 60 °C, ou humidité relative hors de 0 à 100 %, bornes comprises, une valeur non numérique comptant comme hors plage. Température et humidité venant du même composant (ADR-capteur-air-sht45), une mesure rejetée l'est entière. La cause d'un rejet se dit par l'une de ces valeurs, la première qui s'applique : `muet`, `temperature-hors-plage`, `humidite-hors-plage`.

La mise en sécurité de la sonde d'air est active par défaut. Active, un capteur d'air dont les mesures sont rejetées pendant plus de 2 minutes est en défaut : chauffage et pompe sont coupés, et le défaut est signalé par la LED d'état, sur la liaison série avec sa cause, et sur le courtier (RG-topics-mqtt) ; l'alerte sur téléphone s'y ajoutera avec sa phase. Pendant ces 2 minutes, aucune décision nouvelle n'est prise sur une mesure rejetée : les sorties gardent l'état décidé sur la dernière mesure acceptée. Une erreur passagère ne coupe donc rien. Les sorties ne reprennent que lorsque le capteur rend de nouveau des mesures acceptées.

La mise en sécurité se désactive et se réactive par commande (`cmd/config`, RG-topics-mqtt), sonde par sonde, et le choix est conservé en mémoire non volatile, au-delà d'une coupure de courant. Désactivée, aucun défaut n'est déclaré pour cette sonde : la régulation se poursuit sur la mesure rejetée quand le capteur en rend une, et quand il est muet les sorties gardent la dernière décision prise, sans limite. Le rejet reste signalé, LED d'état et liaison série comprises, et la désactivation est elle-même signalée sur la liaison série au démarrage et publiée dans `state`, pour qu'aucun lecteur ne la croie active. La durée maximale de chauffe continue (RG-chauffe-continue-bornee) s'applique dans tous les cas.

Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle sans que son propriétaire l'ait décidé, et celui qui le supervise sait, sans lire le code, s'il faut vérifier le câblage ou le capteur lui-même. Les plages sont larges à dessein : elles écartent ce qu'aucun terrarium ne peut connaître, non ce qui serait seulement inhabituel ; une mesure fausse mais plausible, d'un capteur décroché dans un coin froid, n'est pas détectée (2026-001, décision 06). Désactiver la mise en sécurité est un risque accepté par le propriétaire (décision `03-lever-la-mise-en-securite`) : sans protection matérielle, une mesure fausse peut alors faire chauffer sans fin, à la seule coupure de 15 minutes toutes les 2 heures près.
