---
id: ADR-historique-victoriametrics
statut: actif
cree_par: 2026-014
modifie_par: []
---

L'historique tient dans l'espace de noms `historique` de ssk-it-01, déployé par ssk-it-infra (`historique/`). Il se compose de deux composants configurés, et d'aucun service écrit :

- **VictoriaMetrics**, en un seul nœud, sur un volume, qui garde cinq ans (`-retentionPeriod=5y`) et n'est joignable que par son Service dans le cluster ;
- **Telegraf**, sans état. Il s'abonne à `ssk-terrarium/+/state` sur l'écouteur interne du courtier, sans passer par Traefik, et en écrit les valeurs numériques dans VictoriaMetrics par le protocole InfluxDB. Toutes les 5 minutes, il interroge VictoriaMetrics sur `/api/v1/query_range`, dans le cluster, et publie les résumés de RG-resumes-de-l-historique.

Deux scripts Starlark de Telegraf mettent en forme l'état reçu et les résumés publiés : c'est le seul code de l'historique. Ni Grafana, ni InfluxDB, ni Ingress. vmui suffit à l'administrateur, par une redirection de port.

Ce qui a tranché :

- VictoriaMetrics est un seul binaire, interface comprise. Il tient en quelques dizaines de Mio de mémoire : 48 Mio demandés et 192 Mio au plus, et 32 et 128 Mio pour Telegraf. Sur le disque, il prend quelques dizaines de Mio par an pour une vingtaine de séries à un point toutes les 30 s. Le motif qui avait écarté un historique en 2026-002/03, « plusieurs centaines de mégaoctets sur un nœud de production partagé », ne tient pas à ces mesures — décision `01-regulariser-l-historique`.
- Hors du cluster, l'historique ne se lit que par ses résumés, publiés sur le courtier que tout client du terrarium joint déjà — décision `02-lecture-hors-du-cluster`.

Ce que l'architecture ne couvre pas :

- aucune sauvegarde du volume n'est décidée ici : perdre le volume perd l'historique, jamais la régulation ;
- l'application ne choisit ni sa période ni son pas : elle lit les quatre résumés publiés.
