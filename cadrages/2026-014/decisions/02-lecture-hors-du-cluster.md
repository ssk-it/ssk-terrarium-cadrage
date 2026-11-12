---
id: 02-lecture-hors-du-cluster
titre: Comment un client hors du cluster lit-il l'historique ?
statut: retenue
option_retenue: resumes-sur-le-courtier
---

## Description

VictoriaMetrics n'est joignable que dans le cluster. Pour que l'application sterrarium montre des courbes, sur le bureau, sur Android et dans le navigateur, l'historique doit sortir du cluster d'une façon ou d'une autre.

Ce qui rendait la question difficile : la voie la plus directe, une lecture HTTP de l'API de VictoriaMetrics, se heurte à plusieurs décisions déjà prises. Chacune a son motif :

1. **Un second adaptateur.** ADR-mqtt-sur-websocket de sterrarium-cadrage fait passer l'application par un seul adaptateur, en TypeScript, derrière un port « courtier ». Le motif est d'éviter « un second adaptateur, et un second jeu de tests, pour le même contrat ». Une lecture HTTP ne sert pas le même contrat, mais elle ajoute bien un adaptateur, ses doublures, ses erreurs, et une seconde façon d'être hors ligne.
2. **Un service à déployer et sécuriser.** L'option `passerelle-http` de sterrarium-cadrage 2026-001/02 a été écartée comme « un service à écrire, déployer et sécuriser », et l'option `http-maison` de 2026-002/02 comme « un format maison que rien d'autre ne lit ». Un vmauth n'est pas écrit, mais il reste à déployer et à sécuriser, sur une entrée publique que 2026-011 sait exposée aux scanners.
3. **Un secret de plus.** sterrarium-cadrage 2026-001/05 écarte le secret compilé dans l'application, qui « se lit dans le binaire et dans le site statique », et le secret gardé par le navigateur, « lisible par tout script de la page ». La version web n'a donc que la mémoire, redemandée à chaque ouverture.
4. **Un client HTTP de plus, et le CORS.** sterrarium-cadrage 2026-005/03, en cours, écarte `skaron-par-l-application` pour ces trois raisons ensemble : « un secret de plus sur chaque appareil, dont la version web ne sait pas garder », « un client HTTP de plus », et « ouvrir le CORS ».

Le courtier, lui, n'a pas de mémoire au-delà des messages retenus : aucune voie par MQTT seul ne donne d'historique sans qu'un composant l'y publie.

## Options

### aucune-lecture-hors-du-cluster

Garder vmui par redirection de port, et ne rien montrer dans l'application.

**Pour** — rien à ouvrir ni à écrire.
**Contre** — l'objectif H2 n'est pas atteint : il faut `kubectl` et l'accès au cluster pour voir une courbe, et rien n'est lisible depuis le téléphone.

### vmui-expose

Exposer vmui sur un nom à lui, sous l'entrée HTTPS existante, derrière une authentification. Le propriétaire le lit dans un navigateur, hors de l'application.

**Pour** — aucun code dans l'application ; toute période, tout pas, toute requête.
**Contre** — une entrée publique de plus, qui donne à qui la franchit le langage de requête entier, en lecture comme en coût. vmui n'est pas conçu pour WCAG 2.2 AA, que l'application s'impose (RG-interface-accessible). On s'y connecte à part, avec un secret de plus, et l'historique ne se lit pas à côté de l'état qu'il prolonge.

### vmauth-en-lecture-seule

Un vmauth, configuré et non écrit, sur un nom à lui sous l'entrée HTTPS existante, devant VictoriaMetrics. Il ne laisse passer que `/api/v1/query_range`, pour un compte authentifié. L'application l'interroge en `fetch`, derrière un port « historique », et calcule elle-même ses fenêtres.

Pour le secret, trois variantes :

- **le mot de passe du compte `sterrarium`**, déclaré aussi dans vmauth. L'application l'a déjà, dans son coffre ou en mémoire : rien de plus à saisir ni à garder. En revanche, un mot de passe fuité ouvre les deux portes, il se scelle deux fois dans ssk-it-infra, et il change aux deux endroits ensemble ;
- **un compte de lecture dédié**, selon l'esprit de RG-compte-dedie. Il se révoque seul, mais c'est un second secret dans le coffre, et une seconde saisie à chaque ouverture de la version web ;
- **un jeton compilé dans le site statique**, écarté d'emblée par sterrarium-cadrage 2026-001/05.

Ce que chaque motif de la description en dit :

1. le second adaptateur est entier : un port, un adaptateur `fetch`, des doublures, des tests, et une seconde façon d'être hors ligne et périmé ;
2. vmauth n'est pas écrit, mais une entrée publique s'ajoute, et elle donne le langage de requête de VictoriaMetrics à tout compte qui la franchit. Ce langage permet des requêtes coûteuses sur un nœud de production partagé ;
3. le mot de passe de `sterrarium` évite un secret de plus, au prix d'une seconde porte pour le même secret ;
4. le CORS est à ouvrir, aux origines des trois cibles, et la politique de sécurité du contenu de l'application à élargir.

**Pour** — toute période et tout pas, un zoom possible ; une API standard, que d'autres outils lisent ; des courbes qui ne retardent pas de la fenêtre en cours.
**Contre** — les quatre motifs de la description s'appliquent, au mieux atténués : aucun n'est levé. L'application doit en plus savoir combler une fenêtre vide comme un trou. Sans fenêtre explicite, en effet, la requête de VictoriaMetrics prolonge une série par-dessus un point manquant, et un rejet de quelques minutes y passe inaperçu à l'échelle d'une semaine.

### passerelle-maison

Un service écrit pour l'occasion, sur le cluster, qui lit VictoriaMetrics et sert à l'application un JSON taillé pour elle.

**Pour** — le format exact que la vue attend.
**Contre** — c'est la `passerelle-http` que sterrarium-cadrage 2026-001/02 a écartée : un service à écrire, construire, déployer et sécuriser. Les motifs 1, 3 et 4 s'y appliquent aussi.

### historique-tenu-par-l-application

L'application garde elle-même les états qu'elle reçoit, et en trace les courbes.

**Pour** — rien sur le cluster ; aucun secret.
**Contre** — l'historique n'existe que quand l'application est ouverte, sur un appareil à la fois. Il a donc des trous partout ailleurs, et chaque appareil en a un différent. Garder des mois de mesures dans le navigateur contredit la prudence de RG-mot-de-passe-jamais-en-clair sur le stockage du navigateur, sinon sa lettre.

### resumes-sur-le-courtier

**Retenue.** L'historique publie lui-même, toutes les 5 minutes, un résumé de chaque période sur le courtier, retenu, sur `ssk-terrarium/<id>/historique/<periode>`. C'est Telegraf qui s'en charge, déjà sur place, par une requête dans le cluster et un script Starlark (RG-resumes-de-l-historique). L'application s'y abonne quand la page Historique est ouverte, par son adaptateur MQTT et sous son compte `sterrarium`.

Ce que chaque motif de la description en dit :

1. aucun adaptateur de plus : un abonnement de plus sur le port « courtier » ;
2. aucune entrée publique de plus : VictoriaMetrics reste dans le cluster. Rien n'est écrit qu'un second script Starlark, à côté de `etat.star`, et le format est un contrat du référentiel, comme celui de `state` ;
3. aucun secret de plus : le compte `sterrarium` lit déjà `ssk-terrarium/#`. Le compte `historique` gagne un droit d'écriture, borné à `historique/#` ;
4. aucun client HTTP de plus, et aucun CORS.

**Pour** — tous les motifs de la description sont respectés. Le trou est décidé une fois, par la supervision, à chaque échelle : une fenêtre sans mesure vaut `null` dans le contrat, quel que soit le client. Le minimum et le maximum de chaque fenêtre gardent les nuits froides.
**Contre** — quatre périodes et quatre pas fixes : ni zoom, ni période libre dans l'application. La fenêtre en cours n'est pas résumée, et le résumé de l'année a un jour de retard. Le courtier, sans volume, perd les résumés à son redémarrage, pour 5 minutes au plus. Le compte `historique` passe de lecteur à éditeur. Un format est à tenir dans RG-resumes-de-l-historique. Enfin, la capacité de Telegraf à interroger puis republier en un seul message par période est à éprouver à la réalisation.

## Décision

`resumes-sur-le-courtier`. Ce qui a tranché : c'est la seule option qui ne rouvre aucun des motifs déjà consignés, ni le second adaptateur, ni l'entrée publique, ni le secret, ni le CORS. Ce qu'elle coûte, des périodes fixes, ne manque pas à la vue que cadre sterrarium-cadrage 2026-007.

`vmauth-en-lecture-seule`, avec le mot de passe du compte `sterrarium`, est l'option qui reprendrait si un besoin de zoom ou de période libre apparaissait. Ce besoin se cadrerait alors en levant explicitement les motifs 1, 2 et 4.

Si la réalisation montre que Telegraf ne sait pas publier un résumé en un seul message, la décision se révise sur la branche de ce cadrage, avant sa fusion, et non par un service écrit en douce.
