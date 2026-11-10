---
id: 01-methode
titre: Comment l'image d'un nouveau firmware parvient-elle au régulateur ?
statut: retenue
option_retenue: https-sur-commande-mqtt
---

## Description

Le régulateur est au garage, joint par MQTT sur TLS à travers Internet, et ne reçoit aucune connexion entrante. L'image fait environ 1 Mo, quand le tampon de PubSubClient est de 1 280 octets. Il faut amener cette image dans la partition inactive sans câble, sans aller sur place, et sans ajouter de service à tenir ni de serveur web au firmware.

## Options

### https-sur-commande-mqtt

**Retenue.** Une commande `cmd/mise-a-jour` ne porte qu'un numéro de version. Le régulateur télécharge lui-même l'image en HTTPS depuis un hôte fixé à la compilation, et la vérifie.

**Pour** — c'est la connexion sortante que le régulateur sait déjà ouvrir, et rien n'écoute sur le réseau du garage. Commande et suivi passent par les sujets et les droits existants. ESP-IDF fournit l'écriture par morceaux (`esp_ota_begin`, `esp_ota_write`), et une tâche à part laisse la boucle de régulation libre.
**Contre** — une seconde connexion TLS en mémoire vive, et un hôte de distribution à choisir (décision `02-source-de-l-image`).

### image-par-mqtt

L'image découpée en messages de moins d'un kilo-octet, publiés sur `cmd/…` et réassemblés par le firmware.

**Pour** — une seule connexion, déjà ouverte.
**Contre** — un millier de messages, un protocole de découpage, d'ordre et de reprise à écrire des deux côtés, et le courtier n'en garde rien (`persistence false`). Une coupure du Load Balancer à 50 s au milieu du transfert oblige à tout reprendre. L'émetteur doit rester connecté du début à la fin.

### reseau-local

ArduinoOTA (espota), ou un formulaire d'envoi sur la page web locale derrière un mot de passe, comme le proposait la piste #15.

**Pour** — rien à héberger, et c'est l'outillage le plus courant des ESP32.
**Contre** — il faut être sur le réseau du garage : ce n'est pas « à distance », et un correctif se fait encore depuis chez soi. ArduinoOTA ouvre un port en écoute, protégé par un hachage MD5 du mot de passe. La page d'envoi ajoute au serveur web une route qui écrit le firmware. ADR-portail-wifi-maison a écarté WiFiManager pour moins que ça.

### poussee-par-la-ci

La publication d'une release déclenche d'elle-même la mise à jour de chaque régulateur.

**Pour** — aucun geste du propriétaire.
**Contre** — une mise à jour sans personne pour la surveiller, à n'importe quelle heure de la nuit. Elle demanderait un compte MQTT pour la CI, ou un sondage périodique par le régulateur. Et une CI de dépôt public qui commande la régulation, c'est une surface de plus.

## Décision

`https-sur-commande-mqtt`. Le critère qui a tranché : c'est la seule option qui soit à la fois réellement à distance et qui ne demande ni service à écrire, ni port ouvert, ni droit de plus sur le courtier.
