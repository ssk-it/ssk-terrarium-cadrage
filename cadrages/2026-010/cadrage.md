---
id: 2026-010
titre: Mettre à jour le firmware à distance, sans jamais laisser le bac sans régulation
domaines: [supervision, securite, regulation]
liens:
  - { tag: piste, nom: '#15', url: 'https://github.com/ssk-it/ssk-terrarium-cadrage/issues/15' }
  - { tag: document, nom: 'ssk-terrarium-cadrage#2026-008', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/ssk-terrarium-cadrage/cadrages/2026-008' }
  - { tag: document, nom: 'skaron-cadrage#2026-002', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/ssk-it/skaron-cadrage/cadrages/2026-002' }
  - { tag: issue_github, nom: 'ssk-terrarium#27', url: 'https://github.com/sskorupski/ssk-terrarium/issues/27' }
  - { tag: issue_github, nom: 'sterrarium#17', url: 'https://github.com/sskorupski/sterrarium/issues/17' }
  - { tag: document, nom: 'sterrarium-cadrage#2026-005', url: 'https://ssk-canon.s3-website.fr-par.scw.cloud/sskorupski/sterrarium-cadrage/cadrages/2026-005' }
impacts:
  - { regle: RG-mise-a-jour-a-distance, operation: cree }
  - { regle: RG-mise-a-jour-refusee-pendant-un-defaut, operation: cree }
  - { regle: RG-image-signee, operation: cree }
  - { regle: RG-regulation-pendant-la-mise-a-jour, operation: cree }
  - { regle: RG-retour-arriere-automatique, operation: cree }
  - { regle: RG-topics-mqtt, operation: modifie }
  - { adr: ADR-mise-a-jour-distribuee-par-skaron, operation: cree }
  - { regle: RG-courtier-authentifie, operation: touche }
  - { regle: RG-sorties-coupees-au-demarrage, operation: touche }
  - { regle: RG-mode-au-demarrage, operation: touche }
  - { regle: RG-chien-de-garde, operation: touche }
  - { regle: RG-regulation-sans-reseau, operation: touche }
  - { regle: RG-configuration-wifi-sur-place, operation: touche }
  - { regle: RG-reglages-bornes, operation: touche }
  - { adr: ADR-firmware-platformio-arduino, operation: touche }
  - { adr: ADR-supervision-par-mqtt-tls, operation: touche }
---

## Objectif

Changer le firmware du régulateur demande aujourd'hui d'ouvrir le boîtier, de brancher un câble USB et de téléverser l'image fusionnée de la release. Ce téléversement efface la mémoire non volatile : le régulateur repart en `MAINTENANCE`, sans Wi-Fi, et il faut le reconfigurer sur place (2026-002). Chaque correctif coûte donc un passage au garage, et le bac se retrouve sans chauffage le temps de la reconfiguration. Les correctifs récents se sont pourtant enchaînés (2026-005 à 2026-008), et la plupart touchent la régulation.

Le propriétaire veut pouvoir installer une nouvelle version depuis chez lui. Mais le firmware est la seule protection du bac : il n'y a aucune protection matérielle en phase 1 (2026-001, décision `06-protection-contre-la-surchauffe`). Une mise à jour ratée, ou une image venue d'ailleurs, laisserait une centaine d'escargots sans régulation, ou sous un chauffage que rien ne borne.

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| U1 | Une nouvelle version s'installe sans toucher au régulateur | Une commande MQTT suffit : ni câble, ni présence sur place, ni reconfiguration |
| U2 | La mise à jour ne laisse jamais le bac sans régulation | La régulation continue pendant le téléchargement. La seule interruption est le redémarrage, sorties coupées |
| U3 | Un firmware qui ne marche pas se défait seul | Un nouveau firmware qui plante, ou qui ne régule pas ou ne rejoint pas le courtier dans les 5 minutes, laisse place à l'ancien sans intervention |
| U4 | Seul le propriétaire peut produire une image installable | Une image que la clé du propriétaire n'a pas signée est refusée, quel que soit le compte qui commande |
| U5 | On ne met pas à jour un bac qui va mal | La commande est refusée pendant un défaut, avec sa raison |
| U6 | Les réglages survivent | Mode, consigne, plages, fuseau, sondes, Wi-Fi et courtier sont conservés |
| U7 | On suit la mise à jour à distance | Chaque étape, la progression, l'échec et sa raison, et le retour arrière se lisent sur `event` |

### Ce que le référentiel disait déjà

- **La piste #15** proposait une règle de travail, « RG-mise-a-jour-protegee », pour une mise à jour depuis la page web locale, derrière un mot de passe. Ce cadrage ne la reprend pas : la page locale demande d'être sur le réseau du garage (décision `01-methode`).
- **2026-001, NF6** prévoyait l'OTA en phase 3. **2026-002** l'avait mise hors périmètre.
- **ADR-firmware-platformio-arduino** a écarté ESPHome, et son mécanisme d'OTA avec lui. Ce cadrage reste sur PlatformIO et Arduino, et emploie les API d'OTA d'ESP-IDF qu'Arduino expose.
- **ADR-supervision-par-mqtt-tls** et la décision `02-protocole-de-publication` de 2026-002 ont écarté un service HTTP maison. Ce cadrage n'en écrit pas : l'image est distribuée par Skaron, un service qui existe déjà (décision `02-source-de-l-image`). Le firmware embarque ISRG Root X1 et ISRG Root YR. `api.skaron.ssk-it.fr` et `s3.fr-par.scw.cloud`, qui sert les artefacts de Skaron, présentent tous deux une chaîne Let's Encrypt qui remonte à ISRG Root YR (mesuré le 11 novembre 2026). Aucune racine n'est à ajouter.
- **ADR-portail-wifi-maison** a écarté WiFiManager, en partie parce qu'il apportait un second serveur web. ArduinoOTA et la page d'envoi d'ESPAsyncWebServer tombent sous le même motif (décision `01-methode`).
- **RG-reglages-bornes** et l'objectif W4 de 2026-002 veulent qu'aucun compte, même compromis, ne puisse lever une protection. Une mise à jour permet de remplacer le firmware qui porte ces protections : sans signature, le compte qui publie sur `cmd/#` pourrait installer un firmware sans bornes. Ce cadrage lève la contradiction par RG-image-signee.
- **RG-courtier-authentifie** : le régulateur publie déjà sur `event` et lit ses `cmd/#`, et le propriétaire et l'application publient sur `cmd/#`. `cmd/mise-a-jour` et ses réponses entrent dans ces droits : **l'ACL de `ssk-it/ssk-it-infra` ne change pas**.
- **RG-configuration-wifi-sur-place** : le dépôt est public, et ni le dépôt ni l'image ne portent d'identifiant. La licence Skaron du régulateur suit le même principe (décision `06-licence-du-regulateur`).
- **RG-mode-au-demarrage**, **RG-sorties-coupees-au-demarrage**, **RG-chien-de-garde**, **RG-regulation-sans-reseau** : ce cadrage les respecte sans les changer. L'OTA n'écrit que la partition inactive, et la mémoire non volatile n'est pas touchée. Au redémarrage, les sorties sont coupées, puis les réglages sont relus et revalidés contre les bornes du nouveau firmware. Le téléchargement tourne à part de la boucle surveillée.
- **RG-topics-mqtt** dit que `event` publie le « démarrage ». Le firmware `edceb22` ne le publie pas. Ce cadrage ne s'appuie pas sur cet événement : l'issue d'une mise à jour a son propre événement.
- **Cadrages en cours** :
  - 2026-007 a été livré pendant la rédaction. 2026-008 est sur sa branche, et réécrit RG-topics-mqtt sur l'énoncé de 2026-007. L'énoncé ci-dessous part de celui de 2026-008, et ce cadrage se livre après lui.
  - Un cadrage 2026-009 était en préparation au moment de la rédaction. S'il modifie lui aussi RG-topics-mqtt, le second livré reprend l'énoncé du premier.
  - 2026-011, sur sa branche, exige un certificat client sur `mq.ssk-it.fr`, enregistré en mémoire non volatile par le portail. Il ne touche pas aux sujets. L'OTA conserve ce certificat comme les autres réglages, et la connexion qu'il rend plus lourde pèse sur la question de la mémoire vive, plus bas.

### Ce que le firmware permet déjà (mesuré sur `edceb22`, 11 novembre 2026)

- **Table de partitions** : celle d'Arduino par défaut pour `esp32dev`, avec deux partitions d'application `ota_0` et `ota_1` de 1,25 Mo (0x140000) et une partition `otadata`. Aucun changement de table n'est nécessaire, et donc aucun téléversement USB préalable.
- **Taille** : `firmware.bin` fait 1 045 648 octets, soit 80 % d'une partition. La marge est de 260 Ko. Mesuré après réalisation : 1 139 953 octets avec la mise à jour à distance, soit 87 %, et une marge de 167 Ko. Le client HTTPS et la vérification minisign en prennent 93 Ko ; appeler `sodium_init()` en aurait ajouté 60, pour Argon2 et les tables de signature, dont la vérification n'a pas besoin.
- **Retour arrière** : le bootloader précompilé d'Arduino est construit avec `CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE=y`. Arduino valide cependant toute nouvelle image dès son démarrage, sauf si le firmware surcharge `verifyRollbackLater()`. Il faut donc la surcharger pour que RG-retour-arriere-automatique ait un effet.
- **Signature** : ni secure boot, ni `CONFIG_SECURE_SIGNED_APPS_NO_SECURE_BOOT`. La signature se vérifie donc dans le firmware. libsodium, présente dans le SDK d'Arduino, fournit BLAKE2b et Ed25519, les primitives de minisign.
- **Version** : `state` publie déjà `version`, tirée de `git describe` à la compilation (`phase-1`, `phase-1-3-g1a2b3c4`).
- **Publication** : le workflow `publication.yml` publie, sur un tag `phase-*`, l'image fusionnée à 0x0 et la notice. Cette image efface la mémoire non volatile et ne convient pas à l'OTA, qui n'écrit que l'application.

## Parcours utilisateur

1. Le propriétaire pousse le tag `phase-1.3`. La CI publie la release GitHub, avec l'image fusionnée pour l'USB, `firmware.bin` et son empreinte SHA-256.
2. Sur son poste, il lance `outils/publier-mise-a-jour.sh phase-1.3`. Le script :
   - télécharge `firmware.bin` et vérifie son empreinte ;
   - le signe avec sa clé minisign, dont il tape la phrase de passe ;
   - le publie dans Skaron sous la version `1.3.0`, cible `esp32-phase-1`, canal `stable`.
3. Une fois par régulateur, il émet sa licence Skaron et la lui transmet : `outils/licence-mise-a-jour.sh <id>` la publie sur `cmd/mise-a-jour` sans l'afficher. Le régulateur répond `{"evenement":"mise-a-jour","etape":"licence","resultat":"applique"}`.
4. Depuis l'application ou `mosquitto_pub`, il envoie `{"action":"verifier"}` sur `cmd/mise-a-jour`. Le régulateur interroge Skaron et répond `{"evenement":"mise-a-jour","etape":"disponible","version":"1.3.0"}`. S'il est déjà à jour, il répond `"etape":"a-jour"`.
5. Il envoie `{"action":"installer","version":"1.3.0"}`. Le régulateur vérifie qu'aucun défaut n'est en cours, et redemande l'URL à Skaron. Si Skaron propose toujours `1.3.0`, il répond `"etape":"acceptee"`, vérifie que la signature est celle du propriétaire et nomme bien cette version, puis télécharge l'image dans la partition inactive.
   - Pendant ce temps, il régule et publie `state` comme d'habitude.
   - Il publie `"etape":"telechargement","progression":10`, puis 20, et ainsi de suite.
6. Image complète et signature vérifiée : il publie `"etape":"redemarrage"` et redémarre. Les sorties sont coupées pendant quelques secondes.
7. Le nouveau firmware relit ses réglages et régule. Dès qu'il a retenu une mesure de l'air et rejoint le courtier, il se déclare valide et publie `"etape":"validee","version":"1.3.0"`. `state` publie la nouvelle version.

Quand ça se passe mal :

- **Un défaut est en cours** (sonde en défaut, coupure par le substrat, pause de chauffe) : `"etape":"refusee","raison":"defaut en cours"`. Rien ne se télécharge.
- **Le réseau tombe pendant le téléchargement**, ou un défaut apparaît : `"etape":"echec","raison":…`. La partition inactive est abandonnée et le firmware en place continue. Rien ne se relance tout seul.
- **La signature ne correspond pas** : `"etape":"echec","raison":"signature invalide"`. L'image n'est jamais rendue démarrable.
- **Le nouveau firmware plante au démarrage**, ou le chien de garde le redémarre avant qu'il se soit déclaré valide : le bootloader revient à l'ancien. L'ancien publie `"etape":"annulee","version":"1.3.0"` à sa connexion.
- **Le nouveau firmware démarre, mais ne régule pas ou ne rejoint pas le courtier en 5 minutes** : il redémarre de lui-même, et le bootloader revient à l'ancien, qui publie `annulee`.
- **La version demandée n'est pas celle que Skaron propose**, parce qu'une autre a été publiée entre-temps : `"etape":"refusee","raison":"version non proposee"`. Le propriétaire relance `verifier`.
- **Licence absente, refusée par Skaron, ou quota dépassé** : `"etape":"refusee"`, avec la raison `sans licence`, `licence refusee` ou `quota depasse`.
- **Le firmware en place n'a pas été compilé depuis un tag `phase-*`** : il ne connaît pas sa version, et répond `"etape":"refusee","raison":"version inconnue"`.

## Énoncés

### RG-mise-a-jour-a-distance

Le firmware se met à jour à distance, et seulement sur commande, par `ssk-terrarium/<id>/cmd/mise-a-jour`. Il n'y a ni mise à jour automatique, ni vérification périodique, ni relance d'une mise à jour qui a échoué. La commande est un objet JSON qui porte l'une de ces trois formes :

- `{"licence":"<jeton>"}` enregistre en mémoire non volatile la licence Skaron du régulateur. Le jeton n'est jamais publié ni écrit sur la liaison série. Il compte de 1 à 768 caractères, lettres, chiffres, `-`, `_` et `.`, ceux d'un JWT : rien qui puisse casser un en-tête HTTP ou une ligne.
- `{"action":"verifier"}` demande à Skaron la version proposée au régulateur. Un défaut en cours ne l'empêche pas : elle ne change rien.
- `{"action":"installer","version":"<x.y.z>"}` installe cette version, si Skaron la propose encore au moment de la commande. Le propriétaire installe donc exactement ce qu'il a vu. Tout autre champ fait refuser la commande.

La licence s'enregistre aussi par la liaison série (`licence <jeton>`).

Le régulateur interroge Skaron par `GET https://api.skaron.ssk-it.fr/v1/ssk-terrarium/esp32/phase-<N>/<version>`, avec sa licence en en-tête `Authorization: Bearer`.
- `<N>` est la phase du firmware en place, et `<version>` sa version au sens semver : `phase-N` donne `N.0.0`, `phase-N.M` donne `N.M.0`.
- Une compilation entre deux tags porte en métadonnées de build le nombre de commits et le hash (`1.2.0+3.g1a2b3c4`). Elle a la même précédence que son tag : la version du tag ne lui est donc jamais reproposée.
- Le nom de l'hôte est fixé à la compilation, et aucune commande ne le change.
- L'URL présignée de l'image se demande au moment de l'installation, jamais à l'avance : elle ne vaut que quinze minutes.

Chaque commande reçoit sa réponse sur `event`, sous la forme `{"evenement":"mise-a-jour","etape":…}`, et chaque étape d'une installation y est publiée. Les étapes sont décrites dans RG-topics-mqtt.

Ce que la règle protège :

- une seule action, celle du propriétaire, remplace le firmware : aucune publication ne s'installe d'elle-même sur un bac ;
- une commande ne peut ni désigner une autre source, ni faire installer une image arbitraire : elle ne porte qu'un numéro de version que Skaron doit proposer ;
- une mise à jour ratée ne se répète pas en boucle.

### RG-mise-a-jour-refusee-pendant-un-defaut

Le régulateur refuse une installation, avec sa raison sur `event`, dans ces cas :

- `defaut en cours` : un défaut est en cours, qu'il s'agisse de `defaut_capteur`, d'une sonde d'air en défaut, d'une mesure du substrat rejetée, d'une coupure par le substrat ou d'une pause de chauffe ;
- `mise a jour en cours` : une autre vérification ou installation est en cours, ou le firmware installé par la précédente ne s'est pas encore déclaré valide : la partition de l'ancien est son seul chemin de retour, et rien ne doit l'écraser avant ;
- `sans licence` : aucune licence n'est enregistrée ;
- `version non proposee` : la version demandée n'est pas celle que Skaron propose ;
- `licence refusee`, `quota depasse` ou `service injoignable`, selon la réponse de Skaron (401 ou 403, 429, autre). Une réponse 200 illisible, ou dont l'adresse de l'image n'est pas en `https://`, compte comme `service injoignable` ;
- `version inconnue` : le firmware en place n'a pas été compilé depuis un tag `phase-*`, et ne sait pas quelle version demander.

La règle d'ignorance des 3 secondes de RG-topics-mqtt s'applique aussi à cette commande.

Un défaut qui apparaît pendant le téléchargement interrompt l'installation, avec `"etape":"echec","raison":"defaut en cours"`.

Le mode `MAINTENANCE` n'empêche pas une installation : les sorties y sont déjà coupées, et c'est le moment le plus sûr pour remplacer le firmware.

Ce que la règle protège : le firmware en place est le seul à connaître le défaut en cours et à le gérer. Le remplacer à ce moment ajouterait un redémarrage, sorties coupées, à une situation déjà dégradée, et effacerait de la mémoire vive les délais de détection en cours (RG-capteur-en-defaut). Un défaut se règle d'abord, et la mise à jour vient ensuite.

### RG-image-signee

Le régulateur n'installe qu'une image signée par la clé minisign du propriétaire. La clé publique est compilée dans le firmware. L'image est vérifiée **pendant** son écriture dans la partition inactive : l'empreinte BLAKE2b-512 se calcule au fil du téléchargement, puis la signature Ed25519 se vérifie, avec son commentaire de confiance. La partition n'est déclarée démarrable qu'après cette vérification et celle du format d'image d'ESP-IDF. Seules les signatures « préhachées » de minisign (`ED`) sont acceptées, jamais l'ancien format qui signe l'image entière.

Le commentaire de confiance, signé avec l'image, vaut `ssk-terrarium esp32-phase-<N> <x.y.z>` : le produit, la cible et la version. Le régulateur le vérifie avant le premier octet téléchargé, et refuse l'image s'il nomme une autre phase (`phase differente`), une version qui n'est pas plus récente que la sienne (`version non plus recente`), ou une autre version que celle demandée (`signature invalide`). Skaron transporte la signature comme pour Tauri : le fichier `.minisig` encodé en base64, sur une ligne.

Le régulateur refuse aussi une image :
- dont la version n'est pas strictement plus récente que la sienne ;
- dont la phase diffère de la sienne : une phase change le câblage, et ne s'installe qu'en USB, notice à la main ;
- qui dépasse la partition d'application.

L'hôte de Skaron et l'hôte des artefacts sont joints en HTTPS, avec un certificat et un nom vérifiés contre les racines déjà embarquées (ADR-supervision-par-mqtt-tls). Aucune vérification TLS n'est désactivée.

La clé privée de signature ne quitte pas le poste du propriétaire : ni la CI ni Skaron ne la détiennent.

Ce que la règle protège : les protections du firmware (bornes, coupures, chien de garde) ne peuvent être retirées par aucun compte MQTT, aucune fuite de licence, aucune compromission de Skaron, du bucket ou de la CI. Seul le propriétaire peut le faire, en signant sur son poste. C'est ce qui garde RG-reglages-bornes vraie à l'heure de l'OTA.

### RG-regulation-pendant-la-mise-a-jour

Le téléchargement et l'écriture de l'image tournent dans une tâche séparée de la boucle de régulation. Pendant ce temps, la boucle continue de mesurer, de réguler, de publier `state` et de nourrir le chien de garde, comme si de rien n'était. Le délai de 10 s du chien de garde ne change pas.

Les sorties restent pilotées par la régulation jusqu'au redémarrage. Le régulateur ne redémarre qu'une fois l'image complète et sa signature vérifiée. Au redémarrage, RG-sorties-coupees-au-demarrage coupe les quatre sorties avant toute autre opération.

L'installation ne touche que la partition d'application inactive et `otadata`. La mémoire non volatile est conservée. Au démarrage du nouveau firmware, RG-mode-au-demarrage relit et revalide chaque réglage contre ses bornes.

Un téléchargement qui ne progresse plus pendant 60 s est abandonné, avec `"etape":"echec","raison":"telechargement interrompu"`. Le firmware en place continue.

Ce que la règle protège : la mise à jour ne coûte au bac qu'un redémarrage, sorties coupées, de l'ordre d'une dizaine de secondes. Elle ne coûte ni la régulation pendant les minutes du téléchargement, ni les réglages, ni la configuration du Wi-Fi.

### RG-retour-arriere-automatique

Un nouveau firmware démarre « à vérifier » : il ne se déclare valide qu'une fois qu'il a, dans les 5 minutes qui suivent son démarrage :

- fait tourner sa boucle de régulation et retenu au moins une mesure de l'air ;
- rejoint le courtier MQTT.

Alors seulement, il annule le retour arrière et publie `"etape":"validee"` avec sa version.

Faute de quoi, il redémarre de lui-même, et le bootloader revient à l'image précédente. Il en va de même s'il plante, ou si le chien de garde le redémarre, avant de s'être déclaré valide.

L'image précédente reconnaît qu'elle a été restaurée : la version tentée est notée en mémoire non volatile avant le redémarrage, et la partition est marquée invalide. À sa connexion au courtier, l'image restaurée publie `"etape":"annulee"` avec la version refusée, puis efface la note. Elle ne retente pas l'installation.

Ce que la règle protège : un firmware qui ne régule pas, ou qui ne peut plus être joint pour en installer un autre, ne reste pas en place. Exiger le courtier est délibéré. Un nouveau firmware injoignable ne pourrait plus être corrigé qu'au câble. Si c'est le Wi-Fi qui est en cause, revenir à l'ancien ne coûte qu'une mise à jour à refaire.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<id>/`, où `<id>` est l'adresse MAC du régulateur en hexadécimal, affichée sur la liaison série :

| Sujet | Sens | Contenu |
| --- | --- | --- |
| `state` | publié, retenu, toutes les 30 s | JSON : la mesure de l'air retenue pour réguler (`air`) et la sonde qui la donne (`sonde_retenue`), chaque sonde d'air (`sondes`), la mesure du substrat (`null` si invalides ou rejetées), la cause du rejet de la mesure de l'air (`cause_mesure_air`), la mise en sécurité (`mise_en_securite`), la combinaison des sondes (`combinaison`), l'état de chaque sortie, le mode, la consigne, l'hystérésis, les plages, le fuseau, l'heure connue ou non, en plage ou non, le défaut capteur, la coupure par le substrat ou non (`coupure_substrat`), le temps depuis le démarrage, la version du firmware, et les bornes des réglages (`bornes`) |
| `event` | publié | JSON : changement de mode, réglage accepté ou refusé avec sa raison, démarrage, chauffe de la SHT45, étapes d'une mise à jour |
| `status` | publié, retenu | `en-ligne` à la connexion, `hors-ligne` comme dernière volonté |
| `cmd/mode` | reçu | `ACTIF`, `PLAGES`, `HIBERNATION` ou `MAINTENANCE` |
| `cmd/config` | reçu | JSON partiel. `consigne`, `hysteresis` : en °C. `plages` : liste de 0 à 4 chaînes `HH:MM-HH:MM`, qui remplace la liste en place. `fuseau` : chaîne POSIX TZ. `mise_en_securite` : objet partiel `{"air":true\|false}`. `sondes` : objet partiel `{"sht45":"interieure"\|"exterieure","dht11":…}`. `combinaison` : `priorite-sht45`, `priorite-dht11`, `moyenne` ou `plus-froide` |
| `cmd/mise-a-jour` | reçu | JSON : `{"licence":"<jeton>"}`, `{"action":"verifier"}` ou `{"action":"installer","version":"<x.y.z>"}` (RG-mise-a-jour-a-distance) |

`air` publie la mesure de l'air de RG-sondes-d-air, `{"temperature":…,"humidite":…}`, à `null` quand aucune sonde intérieure n'est acceptée. `sonde_retenue` vaut alors `null`. Sinon, elle vaut `sht45` ou `dht11` pour la sonde dont la mesure est retenue, ou `moyenne` quand deux sondes sont moyennées.

`sondes` publie chaque sonde d'air sous son nom : `{"sht45":{"role":…,"temperature":…,"humidite":…,"cause":…,"defaut":…},"dht11":{…}}`. Une mesure rejetée publie sa température et son humidité à `null`, jamais la valeur refusée, que la mise en sécurité soit active ou non. `cause` vaut `null` pour une mesure acceptée, et sinon la cause de son rejet selon RG-capteur-en-defaut. `defaut` dit si la sonde est en défaut.

`cause_mesure_air` vaut `null` quand `air` a une valeur. Sinon, il vaut la cause du rejet de la sonde intérieure prioritaire (RG-capteur-en-defaut) : le champ garde son sens pour qui ne lit pas encore `sondes`. `defaut_capteur` reste le booléen qu'il était : il dit si chauffage et pompe sont coupés faute de sonde intérieure acceptée. Le défaut d'une seule sonde se lit dans `sondes`. `mise_en_securite` publie `{"air":true}` ou `{"air":false}`. Elle porte sur l'air intérieur, toutes sondes intérieures ensemble.

Les bornes publiées dans `state` sont celles de RG-reglages-bornes, lues des constantes de compilation du firmware : `"bornes":{"consigne":[min,max],"hysteresis":[min,max],"somme_max":…,"plages_max":…,"fuseau_max":…,"combinaisons":[…]}`. `consigne` et `hysteresis` sont les intervalles admis, bornes comprises, en °C à une décimale. Consigne plus hystérésis doit rester strictement sous `somme_max`. `plages_max` est le nombre maximal de plages, et `fuseau_max` la longueur maximale d'un fuseau POSIX TZ, en entiers. `combinaisons` est la liste des combinaisons admises. Aucune commande ne règle ces bornes.

Chaque chauffe de la SHT45 (RG-chauffe-de-la-sht45) publie sur `event` : `{"evenement":"chauffe-sonde","sonde":"sht45","motif":…}`, où `motif` vaut `humidite-haute` ou `humidite-hors-plage`. Le message ne porte pas l'humidité qui l'a déclenchée : une valeur rejetée ne se publie jamais, et la mesure acceptée se lit déjà dans `state`. Une chauffe ne change rien à `state` : `air` et `sondes` y publient la mesure du dernier relevé, jamais celle que la sonde rend à la fin de la chauffe.

Une mise à jour publie sur `event` : `{"evenement":"mise-a-jour","etape":…}`, avec les champs que chaque étape porte :

| `etape` | Quand | Champs |
| --- | --- | --- |
| `licence` | licence reçue | `resultat` : `applique`, `applique_non_enregistre` ou `refuse` (jeton vide, trop long, ou avec d'autres caractères que ceux d'un JWT) |
| `disponible` | réponse à `verifier` | `version` proposée par Skaron |
| `a-jour` | réponse à `verifier` | `version` en place |
| `refusee` | commande refusée (RG-mise-a-jour-refusee-pendant-un-defaut) | `raison` |
| `acceptee` | installation acceptée, Skaron propose la version demandée | `version` |
| `telechargement` | tous les 10 % | `version`, `progression` (entier, 0 à 100) |
| `echec` | installation abandonnée, firmware en place conservé | `version`, `raison` : `defaut en cours`, `telechargement interrompu` (60 s sans octet, connexion perdue, ou adresse de l'image refusée), `signature invalide`, `image invalide`, `image trop grande`, `version non plus recente` ou `phase differente` |
| `redemarrage` | image vérifiée, juste avant de redémarrer | `version` |
| `validee` | nouveau firmware déclaré valide (RG-retour-arriere-automatique) | `version` |
| `annulee` | ancien firmware restauré par le bootloader | `version` refusée |

`state` ne porte aucun champ de mise à jour : la version en place s'y lit déjà, et une installation se suit sur `event`.

Une commande `cmd/mise-a-jour` illisible reçoit la réponse commune aux commandes : `{"evenement":"commande","sujet":"cmd/mise-a-jour","resultat":"refusee","raison":…}`, où `raison` vaut `JSON invalide`, `champ inconnu`, `action inconnue (verifier, installer)` ou `version invalide (x.y.z)`. Une licence invalide, elle, reçoit l'étape `licence` avec `"resultat":"refuse"`.

Une commande retenue par le courtier n'est jamais appliquée : seule compte une commande publiée pendant que le régulateur est connecté. Le courtier remet les messages retenus juste après l'abonnement, et la bibliothèque PubSubClient ne dit pas si un message l'est. Toute commande reçue dans les 3 secondes qui suivent l'abonnement est donc ignorée, et l'ignorance signalée sur `event`. Toute commande reçoit sa réponse sur `event`. Une commande `sondes` refusée parce qu'elle ne laisserait aucune sonde intérieure l'est avec la raison `aucune sonde interieure`.

Ce que la règle protège :

- on lit l'état sans attendre la mesure suivante ;
- une commande ancienne, oubliée sur le courtier, ne change pas le mode, la mise en sécurité ni le rôle des sondes à la reconnexion suivante, et ne lance pas de mise à jour ;
- lues dans le même message que les valeurs en place, les bornes ne peuvent pas appartenir à un autre firmware que celui qui les applique ;
- une valeur rejetée, ou mesurée sur une sonde encore chaude, n'est jamais lue comme une mesure courante ;
- la sonde qui décide, la cause d'un rejet et la mise en sécurité se lisent dans le même message que la mesure et le défaut qu'elles expliquent ;
- les chauffes répétées de la SHT45 se lisent sans accès à la liaison série ;
- une mise à jour se suit, étape par étape, sans sujet ni droit de plus sur le courtier.

### ADR-mise-a-jour-distribuee-par-skaron

Le firmware se met à jour par OTA en HTTPS, sur commande MQTT. L'image est distribuée par Skaron (`ssk-it/skaron`) sous le produit `ssk-terrarium`, cible `esp32-phase-<N>`. Le régulateur s'y authentifie par une licence propre, et télécharge l'image par l'URL présignée de quinze minutes que Skaron délivre. L'image est signée par minisign sur le poste du propriétaire, et vérifiée par le firmware avant d'être rendue démarrable. Le retour arrière repose sur les deux partitions OTA de la table par défaut et sur le bootloader d'ESP-IDF, la validation étant différée par `verifyRollbackLater()`.

Ce qui l'a décidé :
- Skaron fait déjà ce qu'il faut : licence révocable, quota, trace par appareil, artefacts privés servis par URL présignée, publication qui change le manifeste en dernier. Sa route générique `/{target}/{arch}/{version}` accepte une cible `esp32` sans changer son code.
- Ses deux hôtes présentent des chaînes Let's Encrypt que le firmware sait déjà vérifier.
- La signature tenue hors de la CI et de Skaron est la seule garantie qu'aucun compte compromis ne puisse retirer les protections du firmware (décisions `01-methode` à `06-licence-du-regulateur`).

## Questions ouvertes, à trancher en réalisant

- **Mémoire vive** : le régulateur ouvre déjà une connexion TLS vers le courtier. Le téléchargement en ouvre une seconde, d'abord vers Skaron, puis vers S3. Il faudra mesurer le tas libre sur la carte pendant un téléchargement. S'il ne suffit pas, couper MQTT le temps du téléchargement fait perdre les étapes `telechargement` : il faudra revenir à ce cadrage avant de le livrer.
- **Durée** : le temps de téléchargement d'1 Mo depuis le garage n'est pas mesuré. Le seuil de 60 s sans progrès est à confirmer.
- **Après une phase** : le manifeste de Skaron ne garde qu'une version par canal. La première publication d'une phase 2 retirera donc la cible `esp32-phase-1`, et les régulateurs de phase 1 ne se verront plus rien proposer. Cela se règlera le jour d'une phase 2, par un canal ou un produit par phase.
- **Écart constaté** : RG-topics-mqtt annonce un événement de démarrage que le firmware ne publie pas. Ce n'est pas l'objet de ce cadrage, et la session des alertes, qui en a besoin, l'a aussi relevé.
