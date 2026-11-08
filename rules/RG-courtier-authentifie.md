---
id: RG-courtier-authentifie
fonctionnalites: [mqtt]
statut: actif
cree_par: 2026-002
modifie_par: []
---

Le courtier n'accepte que des connexions chiffrées par TLS et authentifiées par un compte. Le compte du régulateur ne peut publier que sur `state`, `event` et `status` de son préfixe, et ne lire que ses `cmd/#`. Le compte du propriétaire peut lire tout `ssk-terrarium/#` et publier sur les `cmd/#`. Aucun compte anonyme. Les mots de passe n'existent que scellés dans `ssk-it-infra` et enregistrés dans le régulateur. Ce que la règle protège : le courtier est joignable depuis Internet ; sans compte, personne ne lit ni ne commande le régulateur, et le régulateur lui-même ne peut pas se donner d'ordre.
