---
id: 01-voie-du-certificat-neuf
titre: Par quelle voie un certificat neuf arrive-t-il au régulateur tant que l'ancien est valide ?
statut: retenue
option_retenue: demande-de-signature-par-mqtt
---

## Description

Tant que son certificat est valide, le régulateur joint le courtier : c'est la seule liaison qu'il ait avec l'extérieur sans qu'on se déplace. La question est de savoir ce qui passe par cette liaison. Le dépôt du firmware est public, et RG-configuration-wifi-sur-place interdit tout identifiant dans le dépôt comme dans l'image. 2026-011 a voulu qu'aucune clé ne passe par un tiers qui n'en a pas besoin : c'est le motif de `autorite-dans-cert-manager` et de `application-de-bureau`, toutes deux écartées. Enfin, le régulateur est un ESP32 qui n'a qu'un tampon MQTT de 1 280 octets et aucune bibliothèque cryptographique en plus du mbedTLS de son cœur.

## Options

### portail-sur-place

On garde la remise de 2026-011, au garage, par le portail, à chaque échéance.

**Pour** — rien à écrire de plus ; aucune clé sur le réseau.
**Contre** — il faut se déplacer, et un oubli coupe la supervision ; un geste fait tous les cinq ans ne s'éprouve pas. C'est précisément ce que 2026-011 renvoyait à ce cadrage.

### cle-transportee-par-mqtt

`ssk-it-infra` fabrique le certificat et sa clé, comme pour la première remise, et les publie sur un sujet réservé que seul le régulateur lit.

**Pour** — le firmware n'a rien à fabriquer : il reçoit ce que le portail reçoit déjà.
**Contre** — la clé privée traverse le courtier. Traefik ne protège que le trajet jusqu'à lui : entre Traefik et Mosquitto, dans le cluster, le flux passe en clair sur l'écouteur 1883. Un message retenu laisserait en plus la clé dans la mémoire de Mosquitto. Le courtier devient ainsi le tiers qui tient une clé dont il n'a pas besoin, ce que 2026-011 a écarté deux fois. La clé existe en outre sur le Mac et sur le cluster.

### demande-de-signature-par-mqtt

**Retenue.** Le régulateur tire lui-même une nouvelle clé P-256 et publie une demande de signature (CSR) sur `ssk-terrarium/<id>/certificat`. `ssk-it-infra` la signe et publie le certificat sur `certificat/signe`. Ni la demande ni le certificat ne contiennent de secret.

**Pour** — la clé ne quitte jamais l'ESP32, et n'existe nulle part ailleurs. Rien de secret ne passe par le courtier, le Mac ou le cluster. Le mbedTLS du cœur Arduino sait tirer une clé et écrire une demande, sans bibliothèque ajoutée. Une demande et un certificat P-256 tiennent dans le tampon MQTT actuel.
**Contre** — le firmware doit tirer une clé et écrire une demande. Le chantier doit vérifier que la configuration du cœur compile bien `MBEDTLS_X509_CSR_WRITE_C`. Le régulateur doit tenir deux clés le temps de l'essai.

### service-https-de-renouvellement

Le régulateur tire son certificat d'un service HTTPS du cluster, comme le ferait un client ACME.

**Pour** — le protocole est connu, et on pourrait le rendre automatique.
**Contre** — c'est un service à écrire, à déployer et à exposer, ce que ADR-supervision-par-mqtt-tls voulait éviter. Pour signer seul, il devrait tenir la clé de l'autorité sur le cluster, ce qu'a écarté `02-autorite-de-certification` de 2026-011.

### mise-a-jour-du-firmware

Le certificat voyage avec une image du firmware mise à jour à distance.

**Contre** — l'image porterait la clé, ce qu'a écarté `01-portail-de-configuration` de 2026-002. Et la mise à jour à distance n'existe pas encore.

## Décision

`demande-de-signature-par-mqtt`. Ce qui a tranché : c'est la seule voie où la clé ne circule pas du tout. Elle n'a plus besoin d'être protégée en chemin, ni de laisser de trace chez le courtier, sur le Mac ou sur le cluster, et un sujet MQTT ne porte plus que des données publiques.
