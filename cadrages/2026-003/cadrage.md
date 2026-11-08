---
id: 2026-003
titre: 'Mode PLAGES : chauffer sur la consigne pendant des plages horaires, tenir 12 °C en dehors'
domaines: [regulation, securite, supervision]
liens:
  - { tag: pull_request, nom: 'ssk-terrarium-cadrage#22', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/pull/22' }
  - { tag: pull_request, nom: 'ssk-terrarium#13', url: 'https://github.com/sskorupski/ssk-terrarium/pull/13' }
  - { tag: issue_github, nom: 'ssk-terrarium#14', url: 'https://github.com/sskorupski/ssk-terrarium/issues/14' }
impacts:
  - { adr: ADR-heure-par-ntp, operation: cree }
  - { regle: RG-chauffage-par-plages, operation: cree }
  - { regle: RG-sorties-par-mode, operation: modifie }
  - { regle: RG-regulation-sans-reseau, operation: modifie }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { regle: RG-reglages-bornes, operation: modifie }
  - { regle: RG-mode-au-demarrage, operation: modifie }
  - { regle: RG-chauffage-par-hysteresis, operation: touche }
  - { regle: RG-changement-de-mode-manuel, operation: touche }
  - { regle: RG-chauffe-continue-bornee, operation: touche }
  - { regle: RG-capteur-en-defaut, operation: touche }
---

## Objectif

Aujourd'hui, le chauffage n'a que deux régimes pour l'hiver : `ACTIF` tient l'air à la consigne (19 °C par défaut) jour et nuit, `HIBERNATION` le laisse descendre jusqu'au hors-gel (4-6 °C). Le propriétaire veut un régime entre les deux : chauffer à la consigne pendant quelques plages de la journée, et laisser l'air redescendre en dehors, sans passer sous 12 °C.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| P1 | Chauffer à la consigne aux heures choisies | Pendant une plage, le chauffage suit la consigne comme en `ACTIF` |
| P2 | Ne chauffer en dehors que pour tenir 12 °C | Hors plage, le chauffage s'allume sous 12 °C et s'arrête à 14 °C |
| P3 | Régler les plages et le fuseau sans recompiler | Jusqu'à 4 plages et le fuseau horaire se règlent par la liaison série ou par MQTT, et survivent à une coupure ; le firmware part avec deux plages, 01:35-06:30 et 14:05-17:05, à l'heure de Paris |
| P4 | Ne rien céder sur la sécurité | Une plage mal formée est refusée ; sans heure connue, le chauffage ne descend jamais au plancher de 12 °C ; les protections s'appliquent en plage comme hors plage |

P4 prime sur les trois autres, comme O6 dans 2026-001 et W4 dans 2026-002.

### Arbitrage d'élevage

[ssk-terrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-001) décrit l'air du garage à 10-12 °C comme « une zone intermédiaire à éviter : il faut choisir entre une hibernation franche et une activité chauffée ». Hors plage, ce mode laisse l'air redescendre jusqu'à 12-14 °C, soit juste au-dessus de cette zone. C'est un choix du propriétaire, fait en connaissance de cause le 2026-11-08. Le mode ne remplace ni `ACTIF` ni `HIBERNATION`, qui restent les deux régimes francs.

### Ce que le référentiel disait déjà

- Ce cadrage s'empile sur [ssk-terrarium-cadrage#2026-002](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002), encore en cours sur sa branche, lui-même empilé sur 2026-001 et sa variante sans limiteur (ssk-terrarium-cadrage#21). Il se fusionne après eux.
- **NF1** (2026-001) dit que « le chauffage, le hors-gel et les protections n'ont pas besoin de l'heure », et **NF5** que « seuls l'éclairage et les cycles de ventilation dépendent de l'heure ». Ce cadrage fait dépendre de l'heure le chauffage du seul mode `PLAGES`. Le hors-gel d'`HIBERNATION` et les protections restent indépendants de l'heure, et `PLAGES` sans heure chauffe comme `ACTIF` (décision `01-sans-heure`) : l'autonomie que NF1 protège tient.
- **F6** et **RG-sorties-par-mode** fixent trois modes ; **RG-topics-mqtt** n'accepte que ces trois valeurs sur `cmd/mode`. Ce cadrage ajoute un quatrième mode et modifie les deux règles.
- **RG-changement-de-mode-manuel** reste entière : `PLAGES` est un mode à part entière, choisi par commande. Le passage en plage et hors plage fait partie de son comportement, et ne change jamais le mode (décision `03-mode-ou-programme`).
- **RG-chauffage-par-hysteresis** décrit déjà le comportement en plage ; elle n'est pas modifiée.
- **RG-reglages-bornes** et la décision `04-reglages-a-distance` de 2026-002 veulent que tout réglage à distance soit borné à la compilation : le plancher de 12-14 °C n'est pas un réglage (décision `02-plancher-hors-plage`), et les plages sont validées en entier.
- Le NTP est renvoyé par 2026-002 à la piste #8 (éclairage à l'heure NTP), qui proposait `ADR-heure-par-ntp`. Ce cadrage crée cet ADR pour le seul besoin des plages. L'heure estimée après un démarrage sans réseau (`RG-heure-ntp` de la piste) reste à la piste #8, et n'entre pas dans le chauffage.
- Incohérence relevée, non tranchée ici : 2026-002 cite la décision `06-protection-contre-la-surchauffe` de 2026-001, qui n'existe que sur la branche de ssk-terrarium-cadrage#21.

## Parcours utilisateur

1. Au premier démarrage, le mode a deux plages, 01:35-06:30 et 14:05-17:05, à l'heure de Paris. Je peux les changer, par exemple `08:00-10:00 18:00-22:00`, par la liaison série (`PLAGES 08:00-10:00 18:00-22:00`) ou par MQTT (`{"plages": ["08:00-10:00", "18:00-22:00"]}` sur `cmd/config`). Le régulateur les valide, les enregistre et confirme.
2. Je choisis le mode `PLAGES`, par la liaison série ou sur `cmd/mode`.
3. À 8 h 00, heure de Paris, le chauffage chauffe vers la consigne ; à 10 h 00, il n'est plus en plage : il s'éteint et ne se rallume que si l'air passe sous 12 °C.
4. L'état publié sur `state` dit le mode, les plages, si l'heure est connue et si l'on est en plage. La liaison série annonce chaque entrée et chaque sortie de plage.
5. Quand ça se passe mal :
   - Coupure de courant pendant la nuit, box éteinte au redémarrage : le régulateur repart en `PLAGES` sans heure ; il chauffe vers la consigne comme en `ACTIF` jusqu'à ce que le NTP réponde, puis suit les plages.
   - Le Wi-Fi tombe après la synchronisation : l'horloge interne continue, les plages aussi ; la synchronisation quotidienne reprend au retour du réseau.
   - Je change de fuseau par `FUSEAU <chaîne POSIX>` ou `{"fuseau": "…"}` : une chaîne mal formée est refusée, et le fuseau en place ne change pas.
   - Je saisis `25:00-26:00`, une plage dont le début égale la fin, ou cinq plages : la commande est refusée en entier, et les plages en place ne changent pas.
   - Le capteur d'air se tait, ou le chauffage tourne 2 h d'affilée : les protections coupent le chauffage, en plage comme hors plage.

## Exigences

- **F6** Proposer quatre modes : `ACTIF`, `HIBERNATION`, `MAINTENANCE` et `PLAGES`. *(ce cadrage modifie F6)*
- **F12** Chauffer à la consigne pendant jusqu'à 4 plages horaires quotidiennes, réglables par la liaison série et par MQTT, et tenir 12-14 °C en dehors. *(ce cadrage)*
- **NF5** L'heure vient du NTP, synchronisée au démarrage puis une fois par jour, dans un fuseau réglable, Europe/Paris par défaut. *(avancée pour le seul mode `PLAGES` ; l'heure estimée reste à la piste #8)*

## Hors périmètre

- L'éclairage et la ventilation à l'heure (piste #8) : en `PLAGES`, ils se comportent comme en `ACTIF`.
- Des plages différentes selon le jour de la semaine, ou des consignes différentes selon la plage.
- Un module d'horloge RTC, écarté par 2026-001.

## Énoncés

### ADR-heure-par-ntp

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Il se synchronise dès que le Wi-Fi est joint après un démarrage, puis une fois par jour. L'heure est tenue pour connue dès la première synchronisation depuis le démarrage, puis avance sur l'horloge interne de l'ESP32 même si le réseau tombe ; elle se perd à chaque redémarrage. Elle est lue dans un fuseau horaire réglable, écrit comme une chaîne POSIX TZ ; par défaut celui de Paris, heure d'été comprise (`CET-1CEST,M3.5.0,M10.5.0/3`) — décision `05-fuseau`. Seul le chauffage du mode `PLAGES` en dépend aujourd'hui, et il ne descend jamais au plancher hors plage sur une heure inconnue (RG-chauffage-par-plages). Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC (2026-001), et le Wi-Fi est déjà là pour la supervision (2026-002).

### RG-chauffage-par-plages

En mode `PLAGES`, le chauffage suit jusqu'à 4 plages horaires quotidiennes. Une plage s'écrit `HH:MM-HH:MM`, à la minute, dans le fuseau réglé (ADR-heure-par-ntp) ; son début est inclus, sa fin exclue ; elle peut passer minuit (`22:00-02:00`) ; son début ne peut pas égaler sa fin. Les plages peuvent se recouvrir : on est en plage dès qu'on est dans l'une d'elles. Sans aucune plage, on n'est jamais en plage. Le firmware fournit deux plages par défaut : `01:35-06:30` et `14:05-17:05`.

- **En plage**, le chauffage suit RG-chauffage-par-hysteresis, avec la consigne et l'hystérésis réglées.
- **Hors plage**, le chauffage s'allume quand l'air descend sous 12 °C et s'éteint quand il atteint 14 °C ; entre les deux, il garde son état. Ces seuils sont fixés à la compilation.
- **Tant que l'heure n'est pas connue** depuis le démarrage (ADR-heure-par-ntp), le mode se comporte comme en plage.

RG-capteur-en-defaut et RG-chauffe-continue-bornee s'appliquent en plage comme hors plage ; après la coupure de 15 minutes, le chauffage reprend sur la cible du moment, plage ou plancher. Chaque entrée et chaque sortie de plage est annoncée sur la liaison série. Ce que la règle protège : l'élevage est chauffé aux heures choisies sans que l'air passe sous 12 °C le reste du temps, et une heure inconnue ne le fait jamais descendre au plancher.

### RG-sorties-par-mode

Le régulateur a quatre modes, et chacun dit ce que le chauffage peut faire :

| Mode | Chauffage | Usage |
| --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Printemps-été, ou hiver chauffé |
| `PLAGES` | Consigne pendant les plages horaires, marche sous 12 °C et arrêt à 14 °C en dehors (RG-chauffage-par-plages) | Hiver chauffé aux heures choisies |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Novembre à février |
| `MAINTENANCE` | Coupé | Nettoyage, changement de substrat |

La brumisation, l'éclairage et la ventilation suivent en `PLAGES` ce qu'ils font en `ACTIF` ; ils restent coupés dans tous les modes jusqu'à ce que les cadrages des phases 2 et 4 leur donnent leur comportement, en modifiant cette règle. Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler ; en maintenance, rien ne s'allume pendant qu'on a les mains dans le bac.

### RG-regulation-sans-reseau

La régulation tourne entièrement sur le régulateur. L'absence du Wi-Fi, du broker ou de tout serveur n'a aucun effet sur la brumisation, l'éclairage ni le chauffage, à une exception : en mode `PLAGES`, sans heure connue depuis le démarrage, le chauffage suit la consigne comme en plage, au lieu de suivre les plages. L'absence de réseau ne peut donc jamais abaisser le chauffage au plancher de 12 °C, ni l'éteindre. Le réseau ne sert qu'à superviser, et à donner l'heure. Ce que la règle protège : une panne de box ou de serveur ne met pas l'élevage en danger.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : mesures de l'air et du substrat (`null` si invalides), état de chaque sortie, mode, consigne, hystérésis, plages, fuseau, heure connue ou non, en plage ou non, défaut capteur, temps depuis le démarrage, version du firmware |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel : `consigne`, `hysteresis` (°C), `plages` (liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place), `fuseau` (chaîne POSIX TZ) |

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est : toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Ce que la règle protège : on lit l'état sans attendre la mesure suivante, et une commande ancienne, oubliée sur le courtier, ne change pas le mode à la reconnexion suivante.

### RG-reglages-bornes

La consigne et l'hystérésis du chauffage, utilisées en mode `ACTIF` et pendant les plages du mode `PLAGES`, les plages horaires du mode `PLAGES` et le fuseau horaire sont réglables à distance et par la liaison série, dans des bornes fixées à la compilation, qu'aucune commande ni aucun réglage enregistré ne peut changer : consigne de 15 à 22 °C, hystérésis de 0,2 à 2 °C, et consigne plus hystérésis strictement sous 24 °C, le seuil d'alerte haute ; de 0 à 4 plages, chacune conforme à RG-chauffage-par-plages ; un fuseau en chaîne POSIX TZ d'au plus 47 caractères, aux décalages compris entre −24 et +24 heures, avec ou sans heure d'été réglée par des dates `Mm.s.j`. Une commande dont une valeur sort de ces bornes, ou qui est mal formée, est refusée en entier, et rien n'en est appliqué. Un réglage accepté s'applique à la mesure suivante et s'enregistre en mémoire non volatile. Le hors-gel de `HIBERNATION` (4-6 °C), le plancher hors plage de `PLAGES` (12-14 °C), la durée maximale de chauffe continue, la coupure sur capteur en défaut et le chien de garde ne sont pas des réglages : aucune commande ne les modifie. Ce que la règle protège : sans limiteur matériel en phase 1, une erreur de saisie ou un compte compromis ne peut pas porter l'air du bac au-delà de 24 °C par la consigne.

### RG-mode-au-demarrage

Le mode en cours, la consigne, l'hystérésis, les plages horaires et le fuseau sont enregistrés en mémoire non volatile à chaque changement. Au démarrage, le régulateur reprend le mode enregistré ; s'il n'en trouve aucun de valide — premier démarrage, mémoire effacée ou corrompue —, il démarre en `MAINTENANCE`, tout coupé, jusqu'à ce qu'on choisisse un mode. Il reprend chacun des réglages enregistrés — consigne et hystérésis ensemble, plages, fuseau — s'il respecte RG-reglages-bornes ; sinon, celui du firmware : 19 °C ± 0,5, les plages `01:35-06:30` et `14:05-17:05`, le fuseau de Paris. Les autres seuils restent ceux du firmware jusqu'à ce qu'ils deviennent réglables. Ce que la règle protège : une coupure de courant en plein hiver ne fait pas sortir l'élevage de son hors-gel, un régulateur qui ne sait pas où il en est ne chauffe pas au hasard, et un réglage enregistré par un firmware plus ancien, aux bornes plus larges, n'échappe pas aux bornes du firmware courant.
