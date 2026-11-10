---
id: 2026-011
titre: Un certificat client exigé sur mq.ssk-it.fr, pour que seuls les clients connus atteignent le courtier
domaines: [supervision]
liens:
  - { tag: pull_request, nom: 'ssk-it-infra#44', url: 'https://github.com/ssk-it/ssk-it-infra/pull/44' }
  - { tag: pull_request, nom: 'ssk-terrarium-cadrage#37', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/pull/37' }
  - { tag: pull_request, nom: 'ssk-it-infra#47', url: 'https://github.com/ssk-it/ssk-it-infra/pull/47' }
  - { tag: issue_github, nom: 'ssk-terrarium#26', url: 'https://github.com/sskorupski/ssk-terrarium/issues/26' }
  - { tag: issue_github, nom: 'ssk-it-infra#48', url: 'https://github.com/ssk-it/ssk-it-infra/issues/48' }
impacts:
  - { adr: ADR-certificats-clients-par-autorite-propre, operation: cree }
  - { adr: ADR-supervision-par-mqtt-tls, operation: modifie }
  - { adr: ADR-courtier-mosquitto-sur-ssk-it-01, operation: modifie }
  - { regle: RG-courtier-authentifie, operation: modifie }
  - { regle: RG-configuration-wifi-sur-place, operation: modifie }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { adr: ADR-portail-wifi-maison, operation: touche }
---

## Objectif

Le courtier de la supervision est joignable de tout Internet à `mq.ssk-it.fr:443`, et n'importe qui peut y ouvrir une connexion TLS : seul le compte et son mot de passe l'arrêtent ensuite, chez Mosquitto. Depuis que Traefik transmet à Mosquitto l'adresse des clients (ssk-it/ssk-it-infra#44, 9 novembre 2026), le journal du courtier montre qui le remplit : des machines EC2 d'Amazon, dans la région us-east-1 (`3.81.124.19`, `32.197.119.162`, `32.200.179.158`), qui ouvrent six connexions en une à deux secondes, terminent la poignée de main TLS chez Traefik, puis ferment sans envoyer de `CONNECT`. Ce sont des scanners, que le nom `mq.ssk-it.fr` a sans doute attirés depuis les journaux de transparence des certificats.

Ils ne menacent pas les comptes : leurs mots de passe sont longs et tirés au hasard. Mais rien ne les empêche d'atteindre Mosquitto, qui ne sait freiner ni les échecs d'authentification ni une rafale de connexions ; et Traefik ne sait pas, en TCP, limiter un débit dans le temps. ssk-it/ssk-it-infra#47 plafonne à 8 les connexions simultanées par adresse, ce qui borne une rafale sans la refuser.

Ce qu'on cherche à obtenir, avec son critère de réussite :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| C1 | Qu'un client inconnu n'atteigne plus le courtier | Une connexion à `mq.ssk-it.fr:443` sans certificat signé par l'autorité du courtier échoue dès la poignée de main TLS, chez Traefik, et ne laisse aucune ligne au journal de Mosquitto |
| C2 | Ne rien mettre de secret dans le dépôt ni dans l'image du firmware | La clé du régulateur n'existe que scellée dans `ssk-it-infra` et enregistrée dans sa mémoire non volatile |
| C3 | Ne pas rouvrir le boîtier | Le certificat du régulateur s'installe par son portail de configuration, sans USB ni recompilation |
| C4 | Ne rien changer à la régulation | Un certificat absent, refusé ou expiré coupe la supervision, jamais le chauffage, la brumisation ni l'éclairage |

C4 prime sur les trois autres, comme W4 dans [ssk-terrarium-cadrage#2026-002](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002).

### Ce que le référentiel disait déjà

Consulté le 10 novembre 2026 sur `origin/main` (8c2a222) et les branches de cadrage en cours.

- **RG-courtier-authentifie** n'exige qu'un compte et un mot de passe, et ne vérifie que le certificat du serveur : ce cadrage la modifie pour exiger aussi un certificat client. Le compte reste exigé.
- **RG-configuration-wifi-sur-place** dit qu'aucun identifiant ne figure dans le dépôt ni dans l'image du firmware : un certificat compilé dans le firmware la contredirait. Ce cadrage la modifie pour que le portail reçoive aussi le certificat et sa clé.
- La décision `01-portail-de-configuration` de 2026-002 a écarté `identifiants-compiles`, parce que chaque changement demandait l'USB et que « l'image porte les secrets ». Ce cadrage s'y conforme : **ADR-portail-wifi-maison** est touchée, pas rouverte.
- **ADR-supervision-par-mqtt-tls** (décision `02-protocole-de-publication`) relevait déjà le coût de la poignée de main TLS sur l'ESP32 ; le TLS mutuel l'alourdit, et l'ADR est modifiée pour dire que le régulateur présente un certificat.
- **ADR-courtier-mosquitto-sur-ssk-it-01** (décision `03-hebergement-du-courtier`) : le TLS reste terminé chez Traefik, sur la route TCP de `mq.ssk-it.fr`, sans port ni Load Balancer ajouté. Traefik y vérifie désormais aussi le client ; l'ADR est modifiée.
- **RG-regulation-sans-reseau** reste entière (C4).
- L'application sterrarium ([sterrarium-cadrage#2026-001](https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-001), décision `02-transport-mqtt`) passe par `wss://mq-ws.ssk-it.fr/mqtt`, un autre nom, servi par un Ingress : elle n'est pas touchée.
- Aucun cadrage en cours ne recouvre celui-ci : 2026-006, 2026-007 et 2026-008 portent sur les mesures.

## Parcours utilisateur

1. Depuis le Mac, `clusters/ssk-it-01/sceller-secrets.sh mosquitto-certificats` (dans `ssk-it-infra`) crée l'autorité du courtier, puis un certificat par client, `terrarium` et `proprietaire`. Il scelle le tout, range dans le trousseau du Mac ce qui sert sur le Mac, et ne montre aucune clé.
2. `appliquer.sh` installe sur le cluster le certificat public de l'autorité, que Traefik exige désormais sur `mq.ssk-it.fr`.
3. Au garage, j'ouvre le portail du régulateur (`WIFI CONFIGURER` sur la liaison série, ou un Wi-Fi resté injoignable), et je connecte le Mac à son réseau `ssk-terrarium-XXXX`.
4. Je lance le script de remise de `ssk-it-infra`. Il lit le certificat et la clé du régulateur scellés sur le cluster, les envoie au portail, et me dit ce que le portail a répondu. Je n'ai rien copié ni collé, et les autres réglages du régulateur restent tels quels.
5. Le régulateur rejoint le Wi-Fi du domicile, présente son certificat à Traefik, puis son compte à Mosquitto, et publie comme avant.
6. MQTT Explorer et `mosquitto_sub`, sous le compte `proprietaire`, présentent le certificat de ce compte, que le Mac tient du trousseau.
7. Quand ça se passe mal :
   - Le régulateur n'a pas encore de certificat, ou le sien est refusé : Traefik ferme la connexion, la supervision s'arrête, la régulation continue. Le régulateur retente comme pour toute panne du courtier, et l'échec se lit sur sa liaison série.
   - Le certificat approche de son expiration : `appliquer.sh` le signale, 90 jours avant, à chaque passage.
   - Un certificat est volé : il ne suffit pas, le compte et son mot de passe restant exigés par Mosquitto. On change le mot de passe du compte, puis on refait l'autorité et ses certificats.
   - Un scanner ouvre une connexion : la poignée de main échoue chez Traefik, et le journal de Mosquitto n'en voit rien.

## Hors périmètre

- **Le renouvellement des certificats** — par MQTT, sur un sujet réservé à un compte dédié, ou autrement. Il fera l'objet d'un cadrage à part. D'ici là, un certificat se renouvelle comme il s'installe (étapes 3 et 4), et sa durée de validité (décision `04-duree-de-validite`) est choisie pour que ce soit rare.
- **`mq-ws.ssk-it.fr`**, par lequel sterrarium joint le courtier en WebSocket : il reste ouvert aux scanners. Un navigateur gère mal un certificat client, et cette entrée sert l'application web. Un adaptateur MQTT natif de sterrarium, s'il voit le jour, passerait par `mq.ssk-it.fr` et devrait présenter un certificat.
- **L'historique** (Telegraf) se connecte au courtier dans le cluster, sur l'écouteur 1883, sans passer par Traefik : il n'est pas touché.

## Chantier

- **sskorupski/ssk-terrarium** — le portail reçoit un certificat client et sa clé, seuls ou avec les autres réglages, et les enregistre en mémoire non volatile ; `WiFiClientSecure` les présente au courtier ; un refus se lit sur la liaison série.
- **ssk-it/ssk-it-infra** — l'autorité et les certificats, fabriqués et scellés par `sceller-secrets.sh` ; la `TLSOption mqtt` exige un certificat signé par l'autorité ; le script de remise au portail ; le contrôle d'`appliquer.sh` présente un certificat et signale une expiration proche ; le README.

Ordre : ssk-it-infra d'abord fabrique l'autorité et les certificats, sans encore les exiger ; le firmware sait les recevoir et les présenter ; le certificat est remis au régulateur ; alors seulement, Traefik les exige. Exiger avant d'avoir remis couperait la supervision.

## Énoncés

### ADR-certificats-clients-par-autorite-propre

Les clients de `mq.ssk-it.fr` présentent un certificat signé par une autorité propre au courtier, et non par une autorité publique. L'autorité et chaque certificat, un par compte (`terrarium`, `proprietaire`), sont fabriqués par `clusters/ssk-it-01/sceller-secrets.sh` dans `ssk-it/ssk-it-infra`, en ECDSA P-256, et n'existent que scellés dans ce dépôt, sur le cluster, dans le trousseau du Mac pour ce qui sert sur le Mac, et dans la mémoire non volatile du régulateur pour ce qui est à lui. Traefik ne reçoit que le certificat public de l'autorité. Ce qui l'a décidé : une autorité publique ne garantit pas de signer un certificat client, et ne sait pas qui doit joindre ce courtier ; une autorité propre n'admet que les clients qu'on lui a fait signer, avec la durée qu'on choisit — décision `02-autorite-de-certification`.

### ADR-supervision-par-mqtt-tls

Le régulateur publie son état et reçoit ses commandes en MQTT, chiffré par TLS, avec PubSubClient et le `WiFiClientSecure` du cœur Arduino ; il vérifie le certificat du courtier, et son nom, contre les racines ISRG Root X1 et ISRG Root YR de Let's Encrypt, embarquées dans le firmware, et présente son propre certificat client, reçu par le portail et enregistré en mémoire non volatile (ADR-certificats-clients-par-autorite-propre). Ce qui l'a décidé : MQTT porte à la fois la publication et les commandes sur une connexion que le régulateur ouvre lui-même, sans service à écrire côté serveur, et le chiffrement est indispensable dès lors que le courtier est joint par Internet — décision `02-protocole-de-publication` de 2026-002 ; le certificat client, pour que seuls les clients connus atteignent le courtier — décision `01-filtrer-avant-le-courtier` de 2026-011.

### ADR-courtier-mosquitto-sur-ssk-it-01

Le courtier est un Mosquitto seul, déployé sur le cluster ssk-it-01 par le dépôt `ssk-it/ssk-it-infra`, sans volume ni historique. Il est joint à `mq.ssk-it.fr`, sur le port 443 : un routeur TCP du Traefik existant prend sur l'entrée `websecure` les connexions qui demandent ce nom dans leur poignée de main (SNI), y termine le TLS avec un certificat cert-manager, n'y admet qu'un client présentant un certificat signé par l'autorité du courtier (ADR-certificats-clients-par-autorite-propre), et passe le flux à Mosquitto. Cette exigence ne vaut que pour `mq.ssk-it.fr`, et pour aucun autre nom de l'entrée `websecure`. Aucun port n'est ajouté au Load Balancer. Ce qui l'a décidé : le cluster existe déjà, avec son entrée publique, ses certificats et ses secrets scellés, et Mosquitto y tient dans quelques mégaoctets ; une machine au domicile aurait été une infrastructure de plus à tenir — décision `03-hebergement-du-courtier` de 2026-002 ; vérifier le client chez Traefik, parce qu'il y termine déjà le TLS — décision `01-filtrer-avant-le-courtier` de 2026-011.

### RG-courtier-authentifie

Le courtier n'accepte que des connexions chiffrées par TLS, d'un client présentant un certificat signé par l'autorité propre au courtier, puis authentifiées par un compte. Un client sans ce certificat est refusé dès la poignée de main, avant d'atteindre le courtier. Le compte du régulateur ne peut publier que sur `state`, `event` et `status` de son préfixe, et ne lire que ses `cmd/#`. Le compte du propriétaire peut lire tout `ssk-terrarium/#` et publier sur les `cmd/#`. Aucun compte anonyme. Les mots de passe, les certificats et leurs clés n'existent que scellés dans `ssk-it-infra`, enregistrés dans le régulateur, et, pour le compte du propriétaire, dans le trousseau de son Mac. Ce que la règle protège : le courtier est joignable depuis Internet ; sans certificat, une connexion n'atteint même pas le courtier ; sans compte, personne ne lit ni ne commande le régulateur, et un certificat volé n'y suffit pas ; le régulateur lui-même ne peut pas se donner d'ordre.

### RG-configuration-wifi-sur-place

Le régulateur ouvre son propre réseau Wi-Fi, `ssk-terrarium-` suivi des quatre derniers chiffres hexadécimaux de son adresse MAC, quand il n'a aucun Wi-Fi enregistré, ou quand le Wi-Fi enregistré reste injoignable 5 minutes ; il continue alors d'essayer ce dernier. Ce réseau est protégé en WPA2 par un mot de passe tiré au hasard au premier démarrage, enregistré en mémoire non volatile, et affiché sur la liaison série à chaque démarrage. Sa page de configuration demande le Wi-Fi du domicile, son mot de passe, l'adresse et le port du courtier, l'identifiant et le mot de passe MQTT du régulateur, son certificat client et sa clé, et les enregistre en mémoire non volatile. Le certificat et sa clé s'y envoient aussi seuls, sans toucher aux autres réglages, ce que fait le script de remise de `ssk-it-infra` ; la page ne les réaffiche jamais. Le réseau se ferme dès que le régulateur a rejoint le Wi-Fi du domicile. La commande série `WIFI CONFIGURER` le rouvre à la demande. La page ne commande aucune sortie et ne change ni le mode ni les réglages ; ni elle ni la connexion n'interrompent la régulation, qui n'attend jamais le réseau. Aucun identifiant ne figure dans le dépôt ni dans l'image du firmware. Ce que la règle protège : on configure le réseau sans outil ni recompilation, sans qu'un voisin puisse le faire, et sans que cette configuration puisse rien allumer.
