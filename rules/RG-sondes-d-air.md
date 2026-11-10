---
id: RG-sondes-d-air
fonctionnalites: [mesures, reglages]
statut: actif
cree_par: 2026-007
modifie_par: []
---

Le régulateur a deux sondes d'air, nommées par leur composant : `sht45`, sur le bus I²C, et `dht11`, sur sa propre broche (RG-brochage). Le DHT11 est facultatif : son absence se traite comme une sonde muette.

Chaque sonde a un rôle : `interieure`, quand elle mesure l'air du bac et sert à la régulation, ou `exterieure`, quand elle mesure l'air du garage et que sa mesure est seulement publiée. Au moins une sonde est intérieure. Par défaut, `sht45` est intérieure et `dht11` extérieure.

La **mesure de l'air** que les autres règles emploient est une seule mesure, température et humidité, calculée à chaque relevé à partir des seules sondes intérieures dont la mesure est acceptée (RG-capteur-en-defaut), selon la combinaison réglée :

| Combinaison | Mesure de l'air |
| --- | --- |
| `priorite-sht45` (par défaut) | celle de `sht45` si elle est acceptée, sinon celle de `dht11` |
| `priorite-dht11` | celle de `dht11` si elle est acceptée, sinon celle de `sht45` |
| `moyenne` | la moyenne des températures et la moyenne des humidités des sondes acceptées |
| `plus-froide` | celle de la sonde acceptée la plus froide, température et humidité ensemble |

Une combinaison ne joue qu'entre sondes intérieures : une sonde extérieure n'entre dans aucune. Quand une seule sonde intérieure est acceptée, la mesure de l'air est la sienne, quelle que soit la combinaison. Quand aucune ne l'est, il n'y a pas de mesure de l'air, et RG-capteur-en-defaut s'applique. Le passage d'une sonde à l'autre se fait à la mesure qui le provoque. Il ne remet pas à zéro l'état de l'hystérésis, ni le compte de la chauffe continue.

Le rôle de chaque sonde et la combinaison se règlent par `cmd/config` (RG-topics-mqtt) et par la liaison série, dans les bornes de RG-reglages-bornes. Ils s'enregistrent en mémoire non volatile (RG-mode-au-demarrage).

Ce que la règle protège : la panne d'une sonde ne coupe plus le chauffage quand une autre peut prendre le relais, et la régulation porte toujours sur une seule mesure, publiée, qui dit à elle seule ce que fait le chauffage (2026-005, décision `01-combinaison-air-substrat`). Déclarer le DHT11 intérieur, ou le retenir en priorité, fait réguler sur une sonde moins précise que la SHT45 : c'est un choix du propriétaire, fait en connaissance de cause (ADR-capteur-air-sht45).
