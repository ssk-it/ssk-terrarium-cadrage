---
id: 2026-012
titre: Renouveler à distance le certificat client du régulateur, sans que sa clé quitte l'ESP32
domaines: [supervision, securite]
liens:
  - { tag: pull_request, nom: 'ssk-terrarium-cadrage#37', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/pull/37' }
impacts:
  - { regle: RG-renouvellement-du-certificat, operation: cree }
  - { regle: RG-courtier-authentifie, operation: modifie }
  - { regle: RG-configuration-wifi-sur-place, operation: modifie }
  - { adr: ADR-certificats-clients-par-autorite-propre, operation: modifie }
  - { regle: RG-topics-mqtt, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { regle: RG-sorties-coupees-au-demarrage, operation: touche }
  - { adr: ADR-courtier-mosquitto-sur-ssk-it-01, operation: touche }
  - { adr: ADR-heure-par-ntp, operation: touche }
---

## Objectif

Depuis [ssk-terrarium-cadrage#2026-011](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-011), Traefik exige un certificat client sur `mq.ssk-it.fr`. Le régulateur reçoit le sien par son portail de configuration, au garage, le Mac connecté au réseau `ssk-terrarium-XXXX`. Rien d'autre ne le renouvelle. Quand ce certificat expire, la supervision s'arrête jusqu'au prochain passage au garage. 2026-011 l'a accepté pour un temps : il a renvoyé le renouvellement à un cadrage à part, et choisi cinq ans de validité pour que la remise soit rare (décision `04-duree-de-validite`). Ce cadrage est ce cadrage à part.

Le problème a trois faces :

- une remise qu'on fait tous les cinq ans ne s'éprouve jamais, et l'on aura oublié le geste quand l'expiration viendra ;
- le régulateur ne sait pas ouvrir son portail quand seul son certificat est en cause : 2026-011 compte sur `WIFI CONFIGURER`, donc sur l'USB, donc sur un boîtier rouvert ;
- l'autorité vaut dix ans, et rien ne dit comment la relever, ni comment la refaire si sa clé est perdue ou volée. Traefik ne lit pas de liste de révocation, et c'est 2026-011 qui le dit.

Ce qu'on cherche à obtenir, avec son critère de réussite :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| R1 | Que la supervision ne s'arrête pas pour un certificat expiré | Un certificat client est remplacé avant son expiration, sans aller au garage, tant que le régulateur joint le courtier |
| R2 | Ne faire transiter aucun secret | La clé d'un certificat renouvelé du régulateur n'existe que dans sa mémoire non volatile : ni dans le dépôt, ni dans l'image du firmware, ni dans un message MQTT, ni sur le Mac, ni sur le cluster |
| R3 | Ne jamais perdre la supervision à cause d'un renouvellement | Un certificat neuf refusé par Traefik laisse le régulateur sur l'ancien, encore valide |
| R4 | Relever l'autorité sans couper les clients | Une nouvelle autorité remplace l'ancienne sans qu'aucun client ne perde la connexion, et sans passage au garage |
| R5 | Garder un secours | Un régulateur sans certificat valide ouvre son portail de lui-même, et y reçoit un certificat comme le prévoit 2026-011 |
| R6 | Ne rien changer à la régulation | Un renouvellement réussi, refusé ou interrompu ne coupe ni le chauffage, ni la brumisation, ni l'éclairage, et ne redémarre pas le régulateur |

R6 prime sur tous les autres, comme C4 dans 2026-011 et W4 dans [ssk-terrarium-cadrage#2026-002](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-002).

### Ce que le référentiel disait déjà

Consulté le 11 novembre 2026, sur `origin/main` (3905479) et sur les branches de cadrage en cours. **Ce cadrage s'appuie sur 2026-011 tel qu'il est sur sa branche `cadrage-2026-011`** (ssk-it/ssk-terrarium-cadrage#37), qui n'est pas encore fusionné puisque son chantier n'est pas réalisé. Sa branche part de celle de 2026-011, et ses énoncés partent des textes que 2026-011 propose. Il ne se fusionne qu'après 2026-011.

- **2026-011 / `03-remise-au-regulateur`** a écarté `par-mqtt` pour la première remise seulement : un régulateur sans certificat ne joint pas le courtier. La décision la désignait comme la voie du renouvellement. Ce cadrage la reprend. La première remise reste `script-vers-le-portail`, et le portail reste le secours.
- **2026-011 / `02-autorite-de-certification`** a écarté `autorite-dans-cert-manager`, parce que la clé de l'autorité serait en clair dans un Secret du cluster. Aucun service du cluster ne signe donc de certificat, et ce cadrage ne remet pas ce point en cause. Le même motif écarte ici toute voie où une clé passerait par un tiers qui n'en a pas besoin, courtier compris.
- **2026-011 / `04-duree-de-validite`** a retenu cinq ans, « compatible avec un renouvellement fait à la main d'ici le cadrage qui l'automatisera ». Ce cadrage retire ce motif. Sa décision `07-duree-de-validite` choisit une nouvelle durée, qui s'applique dès sa livraison. 2026-011 n'est pas réécrit : il garde ce qui a été décidé pour la première remise.
- **RG-courtier-authentifie**, dans la version de 2026-011, met les clés des clients dans `ssk-it-infra`, dans le régulateur et dans le trousseau du Mac. Elle ne connaît que deux comptes sur `mq.ssk-it.fr`, `terrarium` et `proprietaire`. Ce cadrage la modifie : la clé du régulateur naît sur le régulateur, et un compte `certificats` s'ajoute.
- **RG-configuration-wifi-sur-place**, dans la version de 2026-011, n'ouvre le portail que sans Wi-Fi enregistré, sur un Wi-Fi injoignable, ou sur `WIFI CONFIGURER`. Ce cadrage la modifie pour qu'il s'ouvre aussi sans certificat valide (R5).
- **ADR-certificats-clients-par-autorite-propre**, que crée 2026-011, est modifiée : la clé du régulateur ne naît plus dans `ssk-it-infra`, la clé de l'autorité ne quitte pas le trousseau du Mac, et une relève à deux autorités est prévue.
- **RG-topics-mqtt** n'est que touchée. Les sujets du renouvellement vivent dans leur propre règle, RG-renouvellement-du-certificat, sous `certificat`, hors de `cmd/`. Ainsi, ce cadrage ne recouvre pas [ssk-terrarium-cadrage#2026-008](https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-008), qui modifie cette règle sur sa branche. Le motif de RG-topics-mqtt vaut ici aussi : une demande de renouvellement ancienne, restée sur le courtier, n'est pas appliquée.
- **RG-sorties-coupees-au-demarrage** et **RG-chien-de-garde** : tout redémarrage coupe d'abord les sorties. Le régulateur adopte donc un certificat neuf sans redémarrer.
- **ADR-heure-par-ntp** : le régulateur n'a d'heure que par NTP. Il ne juge une échéance que s'il connaît l'heure. Sans elle, c'est `ssk-it-infra` qui demande le renouvellement.
- **ADR-courtier-mosquitto-sur-ssk-it-01** reste entière : Traefik vérifie toujours le client, et rien ne s'ajoute sur le cluster pour signer.
- **La mise à jour du firmware à distance** (fonctionnalité `mise-a-jour`, besoin NF6 de 2026-001) n'a ni règle ni cadrage. Ce cadrage ne s'en sert pas. Il ne la prépare pas non plus.
- Le compte `sterrarium` (ssk-it/ssk-it-infra, `sceller-secrets.sh`) passe par `wss://mq-ws.ssk-it.fr/mqtt`, sans certificat client. Il n'est pas touché : il n'écrit que sous `cmd/`, et ne peut donc rien publier sous `certificat`.

## Parcours utilisateur

1. Le régulateur connaît l'heure et voit que son certificat expire dans moins de 90 jours. Il tire une nouvelle clé ECDSA P-256, l'enregistre en mémoire non volatile à côté de l'ancienne, et publie sa demande de signature sur `ssk-terrarium/<id>/certificat`, retenue. La clé ne sort pas de l'ESP32. La régulation ne s'interrompt pas.
2. Depuis le Mac, je lance `clusters/ssk-it-01/appliquer.sh` (dans `ssk-it-infra`), comme d'habitude. Il signale que le certificat du régulateur arrive à échéance, et qu'une demande de signature l'attend. Il me demande de la signer.
3. J'accepte. Le trousseau me demande de déverrouiller la clé de l'autorité. Le script vérifie que la demande vient du régulateur attendu, la signe, et publie le certificat signé sur `ssk-terrarium/<id>/certificat/signe`, retenu, sous le compte `certificats`. Rien de secret n'a circulé : la demande et le certificat ne contiennent que des clés publiques.
4. Le régulateur reçoit le certificat, tout de suite s'il est connecté, ou à sa prochaine connexion sinon. Il vérifie que le certificat porte bien sa nouvelle clé, ferme sa connexion, et se reconnecte en le présentant, sans redémarrer.
5. Traefik l'admet et Mosquitto accepte le compte. Le régulateur garde le certificat neuf, efface l'ancien et son ancienne clé, publie `certificat adopte` sur `event`, et republie l'état de son certificat, sans demande cette fois. Au passage suivant, `appliquer.sh` retire le certificat signé resté retenu sur le courtier, et range le nouveau certificat public parmi les secrets de `ssk-it-infra`.
6. Le certificat du compte `proprietaire` (MQTT Explorer) et celui du compte `certificats` se renouvellent sur le Mac, par le même `appliquer.sh` : une nouvelle clé dans le trousseau, signée par l'autorité, sans MQTT.
7. Un jour, l'autorité approche de son échéance, ou sa clé est compromise. `ssk-it-infra` en fabrique une nouvelle. `appliquer.sh` la fait admettre par Traefik à côté de l'ancienne. Il demande ensuite à chaque client un certificat signé par la nouvelle, comme aux étapes 1 à 5, sur `certificat/demander` pour le régulateur. Quand tous l'ont adopté, il retire l'ancienne autorité.
8. Quand ça se passe mal :
   - **Traefik refuse le certificat neuf** (mauvaise autorité, certificat abîmé) : le régulateur se reconnecte avec l'ancien, publie `certificat refuse` et sa raison sur `event`, oublie le candidat et sa clé. La supervision a manqué quelques secondes. `appliquer.sh` le dit au passage suivant, et le régulateur refera une demande.
   - **Le régulateur redémarre en plein renouvellement** : il repart sur l'ancien certificat, qu'il n'a pas effacé. Une demande en attente est republiée, avec la même clé.
   - **Le régulateur ne connaît pas l'heure** : il ne fait pas de demande de lui-même. `appliquer.sh` voit l'échéance, puisqu'il lit la date d'expiration que le régulateur publie, et la demande sur `certificat/demander`.
   - **`appliquer.sh` n'est pas lancé pendant 90 jours** : le certificat expire. Le régulateur, qui le voit à l'heure NTP, ou dont Traefik refuse le certificat expiré, ouvre son portail, et l'on fait la remise de 2026-011 au garage. La régulation, elle, n'a rien vu.
   - **Quelqu'un publie un faux certificat** sur `certificat/signe` : seul le compte `certificats` le peut. Un certificat qui ne porte pas la clé que le régulateur attend est ignoré. Un certificat qui la porte sans être signé par l'autorité est refusé par Traefik à l'essai, et le régulateur revient à l'ancien.
   - **La clé de l'autorité est volée** : on relève l'autorité (étape 7), et l'on change les mots de passe des comptes, comme le prévoit 2026-011. Le mot de passe, toujours exigé par Mosquitto, rend un certificat forgé inutile à lui seul.

## Hors périmètre

- **La mise à jour du firmware à distance**, qui aurait pu porter le renouvellement. Elle demande son propre cadrage (besoin NF6 de 2026-001).
- **Une signature sans personne derrière le Mac**, par une tâche planifiée ou un service : la clé de l'autorité ne se déverrouille qu'à la main (décision `03-declenchement`).
- **`mq-ws.ssk-it.fr`** et le compte `sterrarium` : sans certificat client depuis 2026-011, ils ne sont pas concernés.
- **La première remise**, qui reste celle de 2026-011, par le portail.

## Chantier

- **sskorupski/ssk-terrarium** :
  - tirer une clé P-256 et écrire une demande de signature avec le mbedTLS du cœur Arduino de l'ESP32, celui dont se sert déjà `WiFiClientSecure`. Le chantier vérifie que la configuration du cœur compile bien l'écriture de demandes (`MBEDTLS_X509_CSR_WRITE_C`) ;
  - tenir en mémoire non volatile un certificat en place et un candidat, chacun avec sa clé ;
  - publier `certificat`, lire `certificat/signe` et `certificat/demander` ;
  - essayer le candidat et revenir à l'ancien sans redémarrer ;
  - ouvrir le portail sans certificat valide.

  Le tampon MQTT du régulateur fait déjà 1 280 octets (`lib/mqtt/mqtt_link.cpp`). Une demande et un certificat P-256 en PEM y tiennent.
- **ssk-it/ssk-it-infra** :
  - le compte `certificats` et ses droits dans Mosquitto, avec son certificat, son mot de passe et son trousseau ;
  - la clé de l'autorité, gardée dans le trousseau du Mac et nulle part en clair ailleurs ;
  - dans `appliquer.sh`, l'échéance lue sur `certificat`, la signature d'une demande après confirmation, puis le retrait du certificat retenu ;
  - le renouvellement des certificats du Mac ;
  - la relève de l'autorité, avec deux autorités admises par la `TLSOption mqtt` le temps de la relève ;
  - la nouvelle durée de validité ;
  - le README.

Ordre :

1. Le chantier de 2026-011, d'abord, réalisé en entier.
2. Puis, dans `ssk-it-infra`, le compte `certificats` et ses droits, sans effet sur les autres.
3. Puis le firmware, qui sait demander, essayer et revenir.
4. Puis `appliquer.sh`, qui signe.

Le premier renouvellement éprouve tout le chantier : les certificats de cinq ans remis par 2026-011 sont renouvelés sur `certificat/demander` dès la livraison, à la durée de `07-duree-de-validite`. On éprouve aussi le retour arrière, une fois, avec un certificat signé par une autre autorité.

## Énoncés

### RG-renouvellement-du-certificat

Le régulateur renouvelle son certificat client par MQTT, sans que sa clé privée quitte l'ESP32.

**La demande.** Le régulateur en fait une quand il connaît l'heure et que son certificat expire dans moins de 90 jours. Il en fait une aussi quand il reçoit une demande sur `certificat/demander`. Il tire alors une clé ECDSA P-256, l'enregistre en mémoire non volatile à côté de la clé en place, et publie la demande de signature correspondante.

**L'état du certificat.** Le régulateur publie sur `ssk-terrarium/<id>/certificat`, retenu, à chaque connexion et à chaque changement : `{"numero":…,"expire":…,"demande":…}`.

- `numero` est le numéro de série du certificat en place ;
- `expire` est sa date d'expiration, en ISO 8601 ;
- `demande` est la demande de signature en PEM, ou `null` quand il n'en attend pas.

Une demande en attente survit à un redémarrage : elle se republie avec la même clé.

**Le certificat signé.** Le compte `certificats` publie le certificat signé, en PEM, sur `ssk-terrarium/<id>/certificat/signe`. Il le publie retenu, pour qu'un régulateur déconnecté le reçoive à sa prochaine connexion. Le régulateur ignore un certificat qui ne porte pas la clé de sa demande en attente. Il ne juge pas lui-même la signature : Traefik la juge à l'essai.

**L'essai.** Le régulateur essaie le candidat sans redémarrer : il ferme sa connexion et se reconnecte en le présentant.

- Si Traefik l'admet et que Mosquitto accepte le compte, le candidat remplace le certificat en place. L'ancien certificat et son ancienne clé sont effacés, et `certificat adopte` est publié sur `event`.
- Sinon, le régulateur se reconnecte avec le certificat en place, publie `certificat refuse` et sa raison sur `event`, et oublie le candidat et sa clé.

**La demande forcée.** Une demande sur `certificat/demander` suit les règles des commandes de RG-topics-mqtt. Elle n'est jamais retenue. Elle est ignorée dans les 3 secondes qui suivent l'abonnement. Elle reçoit sa réponse sur `event`.

**La signature.** Rien d'autre que `appliquer.sh` ne signe, depuis le Mac, après confirmation, la clé de l'autorité déverrouillée dans le trousseau. Il signale une échéance à 90 jours, signe une demande en attente, demande un certificat quand l'échéance approche sans demande, puis retire le certificat retenu une fois adopté.

Ni la demande, ni l'essai, ni un refus n'interrompent la régulation.

Ce que la règle protège :

- la supervision survit à l'expiration d'un certificat sans passage au garage ;
- aucune clé privée ne circule, pas même par le courtier ;
- un certificat neuf défectueux ne coupe pas la supervision ;
- une demande de renouvellement ancienne, restée sur le courtier, n'est pas appliquée ;
- un renouvellement ne redémarre jamais le régulateur, et donc ne coupe jamais ses sorties.

### RG-courtier-authentifie

Le courtier n'accepte que des connexions chiffrées par TLS, d'un client présentant un certificat signé par l'autorité propre au courtier, puis authentifiées par un compte. Un client sans ce certificat est refusé dès la poignée de main, avant d'atteindre le courtier.

Les droits des comptes :

- le compte du régulateur ne peut publier que sur `state`, `event`, `status` et `certificat` de son préfixe, et ne lire que ses `cmd/#`, son `certificat/signe` et son `certificat/demander` ;
- le compte du propriétaire peut lire tout `ssk-terrarium/#` et publier sur les `cmd/#` ;
- le compte `certificats` ne peut lire que les `certificat` et publier que sur les `certificat/signe` et `certificat/demander` des régulateurs ;
- aucun compte anonyme.

Les mots de passe n'existent que scellés dans `ssk-it-infra`, enregistrés dans le régulateur, et, pour les comptes du propriétaire et `certificats`, rangés dans le trousseau de son Mac. Il en va de même des certificats et de leurs clés, à une exception : une clé que le régulateur a tirée lui-même n'existe que dans sa mémoire non volatile.

Ce que la règle protège :

- le courtier est joignable depuis Internet : sans certificat, une connexion n'atteint même pas le courtier ;
- sans compte, personne ne lit ni ne commande le régulateur, et un certificat volé n'y suffit pas ;
- le régulateur lui-même ne peut pas se donner d'ordre ;
- le compte dont se sert MQTT Explorer au quotidien ne peut pas remettre de certificat ;
- le compte qui le peut ne peut rien commander.

### RG-configuration-wifi-sur-place

**Quand le portail s'ouvre.** Le régulateur ouvre son propre réseau Wi-Fi, `ssk-terrarium-` suivi des quatre derniers chiffres hexadécimaux de son adresse MAC, dans trois cas :

- il n'a aucun Wi-Fi enregistré ;
- le Wi-Fi enregistré reste injoignable 5 minutes ;
- il n'a pas de certificat client valide : il n'en a aucun, le sien a expiré d'après l'heure NTP, ou Traefik l'a refusé pendant 5 minutes.

Il continue alors d'essayer le Wi-Fi et le courtier.

**Le réseau.** Il est protégé en WPA2 par un mot de passe tiré au hasard au premier démarrage, enregistré en mémoire non volatile, et affiché sur la liaison série à chaque démarrage.

**La page de configuration.** Elle demande le Wi-Fi du domicile, son mot de passe, l'adresse et le port du courtier, l'identifiant et le mot de passe MQTT du régulateur, son certificat client et sa clé, et les enregistre en mémoire non volatile. Le certificat et sa clé s'y envoient aussi seuls, sans toucher aux autres réglages : c'est ce que fait le script de remise de `ssk-it-infra`. La page ne les réaffiche jamais.

**La fermeture.** Le réseau se ferme dès que le régulateur a rejoint le Wi-Fi du domicile et que le courtier a admis son certificat. La commande série `WIFI CONFIGURER` le rouvre à la demande.

**Ce que la page ne fait pas.** Elle ne commande aucune sortie, et ne change ni le mode ni les réglages. Ni elle ni la connexion n'interrompent la régulation, qui n'attend jamais le réseau. Aucun identifiant ne figure dans le dépôt ni dans l'image du firmware.

Ce que la règle protège :

- on configure le réseau sans outil ni recompilation ;
- aucun voisin ne peut le faire ;
- cette configuration ne peut rien allumer ;
- un certificat expiré se remplace sans rouvrir le boîtier.

### ADR-certificats-clients-par-autorite-propre

Les clients de `mq.ssk-it.fr` présentent un certificat signé par une autorité propre au courtier, et non par une autorité publique. Il y a un certificat par compte : `terrarium`, `proprietaire` et `certificats`. Tous sont en ECDSA P-256.

**L'autorité.** `clusters/ssk-it-01/sceller-secrets.sh`, dans `ssk-it/ssk-it-infra`, fabrique l'autorité. Sa clé n'existe que dans le trousseau du Mac. Elle n'est jamais en clair sur le cluster, et sert à `appliquer.sh` pour signer, après confirmation.

**Les certificats.** Ceux du Mac sont fabriqués et renouvelés dans le trousseau. Le premier certificat du régulateur est fabriqué et scellé par `sceller-secrets.sh`, puis remis par le portail. Ses certificats suivants naissent d'une clé qu'il tire lui-même et d'une demande de signature publiée par MQTT (RG-renouvellement-du-certificat) : cette clé ne quitte jamais l'ESP32.

**Les durées.** Les certificats valent un an et l'autorité dix ans. Aucun certificat n'est signé pour durer au-delà de l'autorité qui le signe.

**Ce que reçoit Traefik.** Il ne reçoit que le certificat public de l'autorité. Le temps d'une relève, il reçoit celui de l'ancienne et celui de la nouvelle. L'ancienne est retirée dès que chaque client a adopté un certificat signé par la nouvelle.

Ce qui l'a décidé :

- une autorité publique ne garantit pas de signer un certificat client, et ne sait pas qui doit joindre ce courtier ; une autorité propre n'admet que les clients qu'on lui a fait signer, avec la durée qu'on choisit (décision `02-autorite-de-certification` de 2026-011) ;
- une clé tirée sur le régulateur ne circule jamais, pas même par le courtier (décision `01-voie-du-certificat-neuf`) ;
- deux autorités admises ensemble relèvent l'autorité sans coupure (décision `06-releve-de-l-autorite`) ;
- un renouvellement éprouvé chaque année ne surprend pas à l'échéance (décision `07-duree-de-validite`).
