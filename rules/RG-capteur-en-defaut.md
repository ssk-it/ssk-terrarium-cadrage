---
id: RG-capteur-en-defaut
fonctionnalites: [protections, mesures]
statut: actif
cree_par: 2026-001
modifie_par: []
---

Un capteur d'air muet ou qui rend une valeur aberrante pendant plus de 2 minutes est en défaut : chauffage et pompe sont coupés, et le défaut est signalé par la LED d'état et sur la liaison série ; l'alerte sur téléphone s'y ajoutera avec sa phase. Pendant ces 2 minutes, aucune décision nouvelle n'est prise sur une mesure invalide : les sorties gardent l'état décidé sur la dernière mesure valide, et la durée maximale de chauffe continue s'applique toujours. Une erreur passagère ne coupe donc rien. Ils ne reprennent que lorsque le capteur rend de nouveau des mesures valides. Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle.
