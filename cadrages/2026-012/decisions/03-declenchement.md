---
id: 03-declenchement
titre: Qui déclenche le renouvellement, et quand ?
statut: retenue
option_retenue: regulateur-demande-appliquer-signe
---

## Description

Deux gestes sont à déclencher. Le régulateur doit tirer une clé et publier une demande. Quelqu'un doit ensuite la signer avec la clé de l'autorité. Cette clé ne doit pas être en clair sur le cluster, ce qu'a écarté `02-autorite-de-certification` de 2026-011. Elle vit donc dans le trousseau du Mac, qui n'est pas toujours allumé, et elle ne se déverrouille qu'à la main. Le régulateur n'a d'heure que par NTP (ADR-heure-par-ntp). `appliquer.sh` signale déjà les certificats qui expirent dans moins de 90 jours.

## Options

### service-du-cluster

Un service du cluster écoute les demandes et les signe aussitôt.

**Pour** — entièrement automatique.
**Contre** — la clé de l'autorité vivrait en clair sur le cluster : c'est `autorite-dans-cert-manager`, écartée par 2026-011.

### tache-planifiee-sur-le-mac

Un agent `launchd` signe les demandes, sans personne derrière le Mac.

**Pour** — rien à lancer à la main.
**Contre** — la clé de l'autorité devrait se déverrouiller sans personne, donc rester ouverte à tout ce qui tourne sur le Mac. Et une signature passerait sans que personne ne l'ait vue.

### appliquer-seul

`appliquer.sh` voit l'échéance et publie une demande sur `certificat/demander`. Le régulateur répond par une demande de signature, et `appliquer.sh` la signe dans la foulée.

**Pour** — le régulateur n'a pas à juger la date.
**Contre** — le régulateur doit être connecté au moment même où le script tourne. Une demande forcée suit les règles des commandes de RG-topics-mqtt : elle n'est jamais retenue, et elle est ignorée dans les 3 secondes qui suivent l'abonnement.

### regulateur-seul

Le régulateur publie de lui-même sa demande, à 90 jours de l'échéance.

**Pour** — la demande attend, retenue, que quelqu'un la signe.
**Contre** — rien ne le force à renouveler hors échéance, ni pour relever l'autorité ni après une compromission. Sans heure connue, il ne demande jamais rien.

### regulateur-demande-appliquer-signe

**Retenue.** Le régulateur publie de lui-même sa demande, retenue, dès que son certificat expire dans moins de 90 jours selon l'heure NTP. À chaque passage, `appliquer.sh` lit l'échéance que publie le régulateur sur `certificat`. Il signe une demande en attente après confirmation, la clé de l'autorité déverrouillée dans le trousseau. Il demande un certificat sur `certificat/demander` quand l'échéance approche sans demande, quand le régulateur ne connaît pas l'heure, ou quand on relève l'autorité.

**Pour** — la demande attend, retenue, et le certificat signé attend aussi : le Mac et le régulateur n'ont pas à être en ligne au même moment. Le renouvellement forcé reste possible. Aucune clé ne se déverrouille sans personne, et `appliquer.sh` est déjà le passage où l'on regarde les échéances.
**Contre** — rien ne signe si `appliquer.sh` n'est pas lancé pendant 90 jours : le certificat expire, et c'est le portail qui prend le relais (décision `05-portail-en-secours`). Le firmware doit lire la date d'expiration de son certificat.

## Décision

`regulateur-demande-appliquer-signe`. Ce qui a tranché : la clé de l'autorité ne s'ouvre qu'avec quelqu'un derrière le Mac. Le geste attendu de cette personne doit donc être un passage qu'elle fait déjà. Les messages retenus, eux, dispensent le Mac et le régulateur d'être en ligne ensemble.
