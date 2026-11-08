---
id: ADR-courtier-mosquitto-sur-ssk-it-01
statut: actif
cree_par: 2026-002
modifie_par: []
---

Le courtier est un Mosquitto seul, déployé sur le cluster ssk-it-01 par le dépôt `ssk-it/ssk-it-infra`, sans volume ni historique. Il est joint à `mq.ssk-it.fr`, sur le port 443 : un routeur TCP du Traefik existant prend sur l'entrée `websecure` les connexions qui demandent ce nom dans leur poignée de main (SNI), y termine le TLS avec un certificat cert-manager, et passe le flux à Mosquitto. Aucun port n'est ajouté au Load Balancer. Ce qui l'a décidé : le cluster existe déjà, avec son entrée publique, ses certificats et ses secrets scellés, et Mosquitto y tient dans quelques mégaoctets ; une machine au domicile aurait été une infrastructure de plus à tenir — décision `03-hebergement-du-courtier`.
