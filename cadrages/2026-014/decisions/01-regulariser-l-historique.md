---
id: 01-regulariser-l-historique
titre: Que faire de l'historique déployé sans cadrage, contre ADR-courtier-mosquitto-sur-ssk-it-01 ?
statut: retenue
option_retenue: victoriametrics-tel-que-deploye
---

## Description

Le 9 novembre 2026, ssk-it-infra a déployé Telegraf et VictoriaMetrics sur ssk-it-01 (`f156d56`). L'ADR en vigueur dit pourtant le courtier « sans volume ni historique », et la décision `03-hebergement-du-courtier` de 2026-002 avait écarté `mosquitto-et-historique`. Depuis, les alertes de 2026-009 se sont posées sur cet historique, sans le cadrer.

Ce qui rendait la question difficile : le déploiement a précédé la décision. Le régulariser sans peser le motif d'origine aurait fait du référentiel le simple greffier de l'infrastructure. Le retirer aurait privé 2026-009 de ce sur quoi il repose.

Le motif de 2026-002/03 avait deux branches : « avance la phase 5 », et « plusieurs centaines de mégaoctets sur un nœud de production partagé ». La phase 5 est celle de la piste #18, que ce cadrage réalise. La seconde branche se mesure sur ce qui tourne.

## Options

### retirer-l-historique

Supprimer `historique/` de ssk-it-infra, et revenir à l'ADR tel qu'il est.

**Pour** — le référentiel dit vrai sans rien changer ; le nœud de Skoppt ne porte que le courtier.
**Contre** — 2026-009 perd la base où vmalert lit l'état, et avec elle la seule façon d'alerter d'un silence ; les courbes de la phase 5 restent à faire.

### influxdb-et-grafana

Remplacer l'historique déployé par ce qu'annonçaient la feuille de route de 2026-001 et la piste #18.

**Pour** — des outils très répandus, et des tableaux de bord riches.
**Contre** — deux serveurs au lieu d'un binaire, une mémoire et un disque qui donnaient raison au motif de 2026-002/03, une migration de ce qui est déjà gardé. Grafana n'apporte rien que vmui et l'application ne couvrent, et resterait à protéger derrière une entrée de plus.

### prometheus-du-cluster

Garder les séries dans le Prometheus que ssk-it-01 porte déjà, en lui donnant un volume.

**Pour** — rien de plus à déployer qu'un exportateur.
**Contre** — Prometheus collecte, il ne reçoit pas : il faudrait un pont de MQTT vers ses métriques. Cinq ans de conservation alourdiraient un Prometheus qui sert à la surveillance du cluster, et en mêleraient les données à celles du terrarium.

### victoriametrics-tel-que-deploye

**Retenue.** Régulariser l'historique déployé : un ADR à lui (ADR-historique-victoriametrics), et ADR-courtier-mosquitto-sur-ssk-it-01 amendé pour dire que le courtier reste sans volume, l'historique à côté de lui.

**Pour** — il tourne, il est mesuré, 2026-009 s'en sert. VictoriaMetrics est un seul binaire, interface comprise : 48 Mio de mémoire demandés et 192 Mio au plus, un volume de 1 Gio, et quelques dizaines de Mio par an sur le disque. Le courtier lui-même reste ce que 2026-002 a décidé.
**Contre** — deux composants de plus sur un nœud de production partagé, et un volume à tenir. Le référentiel valide après coup un déploiement qu'il aurait dû précéder.

## Décision

`victoriametrics-tel-que-deploye`. Ce qui a tranché : le motif de 2026-002/03 portait sur un coût de « plusieurs centaines de mégaoctets », et le déploiement mesure le dixième. Ce qui restait du motif, ne rien ajouter que le courtier, est levé en connaissance de cause, pour ce que la phase 5 et les alertes demandent.

Ce que la régularisation apprend : un composant d'infrastructure s'est posé avant son cadrage, et un cadrage voisin (2026-009) a dû le constater sans pouvoir le décider. Les composants que ce cadrage ajoute — les résumés, l'historisation de chaque sonde — attendent sa relecture pour se déployer.
