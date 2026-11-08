---
id: 03-hebergement-du-courtier
titre: Où héberger le courtier MQTT, et avec quoi d'autre ?
statut: retenue
option_retenue: mosquitto-seul-sur-ssk-it-01
---

## Description

La piste #12 laissait ouvert le choix entre une machine locale et une infrastructure existante. Le propriétaire dispose du cluster ssk-it-01 (OVH Managed Kubernetes, SBG5, un nœud de 4 vCPU et 8 Go), qui porte déjà Traefik derrière un Load Balancer public, cert-manager, Sealed Secrets, un PostgreSQL et un Prometheus sans volume. Ce nœud sert aussi la production de Skoppt : ce qu'on y ajoute doit être sobre en processeur et en mémoire.

## Options

### machine-au-domicile

Mosquitto sur une machine du réseau domestique.

**Pour** — pas de port ouvert sur Internet pour le régulateur.
**Contre** — une machine de plus, allumée en permanence, à tenir à jour ; lecture et commandes depuis l'extérieur demanderaient une ouverture de la box.

### mosquitto-et-historique

Mosquitto, plus une base de séries temporelles et un tableau de bord, dès maintenant.

**Pour** — des courbes tout de suite.
**Contre** — avance la phase 5 ; une base et un tableau de bord avec volume, plusieurs centaines de mégaoctets sur un nœud de production partagé.

### mosquitto-seul-sur-ssk-it-01

**Retenue.** Un Mosquitto seul, sans volume, derrière une entrée TCP `mqtts` du Traefik existant, avec un certificat cert-manager et des comptes scellés.

**Pour** — tout ce qu'il faut existe déjà sur le cluster ; quelques mégaoctets de mémoire ; joignable de partout.
**Contre** — un port public de plus sur le Load Balancer du cluster ; pas d'historique, et l'état retenu se perd au redémarrage du pod (republié dans les 30 s).

## Décision

Mosquitto seul sur ssk-it-01. Ce qui a tranché : réutiliser l'entrée, les certificats et les secrets du cluster existant, sans rien y ajouter que le courtier lui-même.
