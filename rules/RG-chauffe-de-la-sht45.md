---
id: RG-chauffe-de-la-sht45
fonctionnalites: [mesures]
statut: actif
cree_par: 2026-008
modifie_par: []
---

Juste après un relevé de la SHT45 (RG-mesures-periodiques), le régulateur chauffe la sonde quand ce relevé rend une humidité de 95 % HR ou plus, ou qu'il est rejeté pour `humidite-hors-plage` (RG-capteur-en-defaut), et qu'aucune chauffe n'a commencé depuis 5 minutes. La chauffe dure 1 seconde, à la plus haute puissance du chauffage intégré (200 mW). Elle s'applique quel que soit le rôle de la SHT45 (RG-sondes-d-air) et quel que soit le mode. Une sonde muette ne se chauffe pas.

La mesure que la sonde rend à la fin de la chauffe est jetée : elle n'entre ni dans la mesure de l'air, ni dans `state`, ni dans le décompte des rejets. Aucun relevé n'est pris pendant la chauffe : le relevé suivant tombe à l'heure habituelle, 30 secondes après celui qui l'a déclenchée, une fois la puce refroidie. Entre les deux, rien ne change de ce que la régulation a décidé : les sorties gardent l'état décidé sur le relevé précédent, aucune sonde ne prend le relais d'une autre, et le délai de 2 minutes de RG-capteur-en-defaut ne court pas plus vite.

Chaque chauffe s'écrit sur la liaison série, avec l'humidité du relevé qui l'a déclenchée, et se publie sur `event` avec son motif, `humidite-haute` (95 % HR ou plus) ou `humidite-hors-plage` (RG-topics-mqtt). Une chauffe que la sonde refuse s'écrit sur la liaison série, ne se publie pas, et compte pour l'intervalle de 5 minutes.

Le seuil de 95 % HR, la durée et la puissance de la chauffe, et l'intervalle de 5 minutes sont des constantes du firmware : aucune commande ne les règle (RG-reglages-bornes).

Ce que la règle protège : la SHT45 se débarrasse d'elle-même de la condensation qui la fait mesurer l'eau plutôt que l'air, sans que personne ait à venir la sécher. Aucune mesure faussée par la chaleur de la puce n'est lue comme une mesure de l'air. La chauffe n'occupe la sonde que 1 seconde toutes les 5 minutes au plus, bien sous les 10 % du temps que Sensirion fixe à son chauffage, et un bac réellement saturé ne la fait pas chauffer en continu. Les chauffes répétées se lisent sur `event` : le propriétaire sait quand la chauffe ne suffit plus et qu'il faut déplacer ou sécher la sonde.
