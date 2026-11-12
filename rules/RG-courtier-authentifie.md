---
id: RG-courtier-authentifie
fonctionnalites: [mqtt]
statut: actif
cree_par: 2026-002
modifie_par: [2026-014]
---

Depuis Internet, le courtier n'accepte que des connexions chiffrées par TLS et authentifiées par un compte. Dans le cluster, l'historique le joint sur son écouteur interne, sans TLS, mais sous son compte. Aucun compte anonyme.

Les droits des comptes :

- le compte du régulateur ne peut publier que sur `state`, `event` et `status` de son préfixe, et ne lire que ses `cmd/#` ;
- le compte du propriétaire peut lire tout `ssk-terrarium/#` et publier sur les `cmd/#` ;
- le compte `sterrarium`, celui de l'application, a les mêmes droits que celui du propriétaire, sous son propre nom (RG-compte-dedie de sterrarium-cadrage) ;
- le compte `historique` ne peut lire que les `state`, et ne publier que sur les `historique/#` des régulateurs (RG-resumes-de-l-historique).

Les mots de passe n'existent que scellés dans `ssk-it-infra`, et chez le client qui s'en sert : le régulateur, le coffre de l'application, le Secret de Telegraf.

Ce que la règle protège :

- le courtier est joignable depuis Internet : sans compte, personne ne lit ni ne commande le régulateur ;
- le régulateur lui-même ne peut pas se donner d'ordre ;
- l'historique, qui publie ses résumés, ne peut ni commander le régulateur, ni contrefaire son état.
