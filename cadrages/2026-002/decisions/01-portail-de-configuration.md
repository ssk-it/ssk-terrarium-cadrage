---
id: 01-portail-de-configuration
titre: Comment le régulateur obtient-il les identifiants du Wi-Fi ?
statut: retenue
option_retenue: portail-maison
---

## Description

Une fois installé, le régulateur ne se rebranche plus en USB sans rouvrir le boîtier. Il doit recevoir les identifiants du Wi-Fi du domicile et du courtier sans recompilation, depuis un téléphone, sans que cette configuration puisse rien commander, et sans qu'aucun secret n'entre dans le dépôt, qui est public.

## Options

### identifiants-compiles

Les identifiants dans un fichier ignoré par git, compilés dans l'image.

**Pour** — aucun code de configuration.
**Contre** — chaque changement de box demande une recompilation et un téléversement en USB, donc d'ouvrir le boîtier ; l'image porte les secrets.

### wifimanager

La bibliothèque WiFiManager (tzapu) : point d'accès et portail captif clés en main, avec des champs supplémentaires pour le courtier.

**Pour** — éprouvée, peu de code à écrire.
**Contre** — une bibliothèque de plus à épingler et suivre, et un second serveur web, synchrone, à côté d'ESPAsyncWebServer que la page web locale emploiera ; son portail bloquant se contourne par un mode non bloquant moins documenté.

### portail-maison

**Retenue.** Un point d'accès WPA2 et une page de configuration écrits dans le firmware, avec ESPAsyncWebServer, déjà épinglé, et le `DNSServer` du cœur Arduino.

**Pour** — aucune bibliothèque ajoutée ; un seul serveur web, asynchrone, qui ne retient jamais la boucle de régulation ; une page qui ne fait que ce qu'on a voulu.
**Contre** — le portail, la validation des champs et la bascule entre point d'accès et Wi-Fi du domicile sont à écrire et à tester.

## Décision

Le portail maison. Ce qui a tranché : ne pas ajouter de bibliothèque ni de second serveur web, alors que celui qu'il faut est déjà là.
