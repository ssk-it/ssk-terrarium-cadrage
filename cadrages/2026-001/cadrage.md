---
id: 2026-001
titre: Le régulateur autonome du terrarium — chauffage, éclairage, brumisation, ventilation et supervision
domaines: [regulation, securite, supervision, materiel]
liens: []
impacts:
  - { adr: ADR-microcontroleur-esp32, operation: cree }
  - { adr: ADR-commande-230v-par-relais-filaires, operation: cree }
  - { adr: ADR-capteur-air-sht45, operation: cree }
  - { adr: ADR-regulation-par-hysteresis, operation: cree }
  - { adr: ADR-firmware-platformio-arduino, operation: cree }
  - { adr: ADR-heure-par-ntp, operation: cree }
  - { regle: RG-mesures-periodiques, operation: cree }
  - { regle: RG-chauffage-par-hysteresis, operation: cree }
  - { regle: RG-brumisation-par-impulsions, operation: cree }
  - { regle: RG-photoperiode, operation: cree }
  - { regle: RG-heure-ntp, operation: cree }
  - { regle: RG-ventilation-periodique, operation: cree }
  - { regle: RG-sorties-par-mode, operation: cree }
  - { regle: RG-changement-de-mode-manuel, operation: cree }
  - { regle: RG-reglages-persistants, operation: cree }
  - { regle: RG-regulation-sans-reseau, operation: cree }
  - { regle: RG-sorties-coupees-au-demarrage, operation: cree }
  - { regle: RG-capteur-en-defaut, operation: cree }
  - { regle: RG-impulsion-de-brumisation-bornee, operation: cree }
  - { regle: RG-chauffe-continue-bornee, operation: cree }
  - { regle: RG-chien-de-garde, operation: cree }
  - { regle: RG-relais-coupes-sans-commande, operation: cree }
  - { regle: RG-limiteur-materiel, operation: cree }
  - { regle: RG-brochage, operation: cree }
  - { regle: RG-page-web-locale, operation: cree }
  - { regle: RG-topics-mqtt, operation: cree }
  - { regle: RG-alertes, operation: cree }
  - { regle: RG-mise-a-jour-protegee, operation: cree }
---

## Objectif

Une centaine de petits-gris vivent dans un aquarium de 96 × 56 × 40 cm, installé dans un garage où il fait 10-12 °C l'hiver — une zone intermédiaire à éviter : il faut choisir entre une hibernation franche et une activité chauffée. Aujourd'hui rien ne tient la température, l'humidité ni la lumière du bac, et rien ne prévient quand elles dérivent. L'élevage est décrit côté données dans [`sskorupski/skarden`](https://github.com/sskorupski/skarden) : [l'installation](https://github.com/sskorupski/skarden/blob/main/installations/aquarium-garage.md) et [l'espèce](https://github.com/sskorupski/skarden/blob/main/animaux/petit-gris.md).

Ce qu'on cherche à obtenir, avec son critère de réussite :

| # | Objectif | Critère de réussite |
| --- | --- | --- |
| O1 | Maintenir la température de l'air | 18-20 °C en mode actif, ±0,5 °C autour de la consigne |
| O2 | Maintenir l'hygrométrie | 75-90 % HR en mode actif |
| O3 | Gérer la photopériode | Plage d'éclairage configurable (12 à 16 h) |
| O4 | Gérer l'hibernation | Mode dédié : hors-gel uniquement (5-8 °C), pas de brumisation, pas de lumière |
| O5 | Superviser à distance | Mesures consultables, historique, alertes sur téléphone |
| O6 | Ne jamais mettre l'élevage en danger | Aucune panne logicielle ou réseau ne peut provoquer une surchauffe |

O6 prime sur tous les autres : un régulateur qui chauffe trop tue l'élevage plus sûrement qu'un régulateur qui ne fait rien.

Ce cadrage est le premier du référentiel : aucune règle, aucune décision, aucun cadrage ne le précédait — le référentiel a été consulté vide. Il transcrit le document de cadrage v0.1 du 28/10/2026, révisé le même jour sur le matériel : un module de relais électromécaniques remplace les relais statiques et le MOSFET, un ventilateur s'ajoute, l'horloge RTC disparaît au profit de l'heure NTP seule, et l'éclairage devient un ruban LED 12 V. Sa réalisation suit la feuille de route ci-dessous, phase par phase ; il ne se livre qu'une fois le régulateur réalisé.

## Parcours utilisateur

1. En automne, je règle le régulateur en mode `ACTIF` : il tient l'air autour de 19 °C, brumise quand l'humidité passe sous 75 %, aère le bac quelques minutes par heure, et allume le ruban LED de 8 h à 21 h.
2. Je consulte les mesures et l'état des sorties depuis la page web locale ou depuis mon téléphone, et je change une consigne ou un horaire sans toucher au boîtier.
3. En novembre, je passe le régulateur en `HIBERNATION` : la lumière, la brumisation et la ventilation s'arrêtent, le chauffage ne protège plus que du gel.
4. Pour nettoyer le bac ou changer le substrat, je passe en `MAINTENANCE` : tout est coupé, les mesures continuent.
5. Une coupure de courant survient : au retour, le régulateur repart sorties coupées, retrouve ses réglages et reprend la régulation du chauffage — avec ou sans Wi-Fi. L'éclairage attend que l'heure soit revenue par le réseau.
6. Quand ça se passe mal — un capteur se tait, le Wi-Fi tombe, le firmware se bloque, le relais de chauffage reste collé —, chauffage et pompe se coupent ou le limiteur matériel coupe à leur place, et mon téléphone reçoit une alerte dès que le réseau le permet.

## Exigences

### Fonctionnelles

- **F1** Mesurer température et humidité de l'air toutes les 30 s.
- **F2** Mesurer la température du substrat côté chaud (sonde optionnelle).
- **F3** Réguler le chauffage par hystérésis autour d'une consigne (défaut : 19 °C, hystérésis ±0,5 °C).
- **F4** Déclencher la brumisation par impulsions (défaut : 8 s) sous un seuil d'humidité (défaut : 75 %), avec un délai minimal entre deux impulsions (défaut : 10 min).
- **F5** Allumer et éteindre l'éclairage selon un horaire (défaut : 8 h – 21 h).
- **F6** Proposer trois modes : `ACTIF`, `HIBERNATION`, `MAINTENANCE` (tout coupé, mesures seules).
- **F7** Exposer une page web locale : mesures, état des sorties, mode, réglages.
- **F8** Publier l'état en MQTT et accepter des commandes (consignes, mode, forçage manuel temporaire).
- **F9** Envoyer des alertes : température hors 15-24 °C, humidité hors 60-95 %, capteur muet, redémarrage inattendu.
- **F10** Aérer le bac par un ventilateur, par cycles horaires en mode `ACTIF` (par exemple 5 min par heure, valeurs à valider).

### Non fonctionnelles

- **NF1 Autonomie** : la régulation tourne entièrement sur l'ESP32. Wi-Fi, broker ou serveur absents n'ont aucun effet sur elle. Le chauffage, le hors-gel et les protections n'ont pas besoin de l'heure : l'abandon de l'horloge RTC laisse NF1 intacte.
- **NF2 Sécurité intrinsèque** : un limiteur matériel coupe le chauffage au-delà de 24 °C, indépendamment du firmware.
- **NF3 Fail-safe logiciel** : capteur en défaut → chauffage et brumisation coupés, alerte émise.
- **NF4 Persistance** : réglages stockés en mémoire non volatile (NVS), conservés après coupure.
- **NF5 Heure** : l'heure vient du NTP, par le Wi-Fi de l'ESP32, sans module d'horloge. Sans heure valide, l'éclairage reste coupé (à valider) ; seuls l'éclairage et les cycles de ventilation dépendent de l'heure.
- **NF6 Maintenance** : mises à jour du firmware en OTA, watchdog matériel actif.

## Architecture cible

```mermaid
flowchart LR
    subgraph Bac["Aquarium"]
        SHT["SHT45<br/>T° + HR air"]
        DS["DS18B20<br/>T° substrat"]
        CAB["Câble chauffant 50 W<br/>(extérieur, paroi arrière)"]
        LED["Ruban LED 12 V<br/>(sous la vitre du couvercle)"]
        BUSE["Buse de brumisation"]
        VENT["Ventilateur 80 mm 5 V"]
    end

    subgraph Boitier["Boîtier de commande"]
        ESP["ESP32<br/>firmware ssk-terrarium"]
        REL["Module 6 relais 5 V optocouplé<br/>chauffage · LED · pompe · ventilateur"]
        BUCK["Abaisseur LM2596<br/>12 V → 5 V"]
    end

    ALIM["Bloc Mean Well 12 V 3 A"]

    LIM["Thermostat Exo Terra<br/>limiteur 24 °C"]
    POMPE["Pompe 12 V<br/>+ réservoir"]

    SHT -- I²C --> ESP
    DS -- 1-Wire --> ESP
    ALIM --> BUCK --> ESP
    ESP --> REL
    REL -- 230 V --> LIM --> CAB
    REL -- 12 V --> LED
    REL -- 12 V --> POMPE --> BUSE
    REL -- 5 V --> VENT

    ESP -. Wi-Fi / MQTT .-> MQTT["Broker Mosquitto"]
    ESP -. NTP .-> NTP["Serveur de temps"]
    MQTT -.-> TSDB["InfluxDB + Grafana<br/>(phase 5)"]
    ESP -. HTTPS .-> NTFY["ntfy<br/>alertes téléphone"]
    USER["Navigateur"] -. HTTP local .-> ESP
```

Tout ce qui est en trait plein fonctionne sans réseau. Les traits pointillés sont de la supervision et l'heure, jamais nécessaires à la régulation du chauffage ni aux protections.

## Nomenclature

| # | Composant | Référence indicative | Fournisseur | Qté | Prix indicatif |
| --- | --- | --- | --- | --- | --- |
| 1 | Microcontrôleur | Carte ESP32-WROOM-32 Keyestudio | Kubii | 1 | 14,40 € |
| 2 | Capteur T° / HR air | Adafruit Sensirion SHT45 avec filtre PTFE, STEMMA QT, n° 6174 ([fiche](https://www.adafruit.com/product/6174)), I²C 0x44, 3,3 / 5 V | Adafruit | 1 | ≈ 15 € (13,50 $ US) |
| 3 | Sonde T° substrat | DS18B20 étanche DFRobot | Kubii | 1 | 9,95 € |
| 4 | Commande des sorties | Module 6 relais 5 V optocouplé — voies : chauffage, LED, pompe, ventilateur ; 2 voies libres | Kubii | 1 | 8,70 € |
| 5 | Ventilation | Ventilateur 80 × 80 mm 5 V | Kubii | 1 | 7,96 € |
| 6 | Résistances | Pack de résistances (4,7 kΩ pour le 1-Wire, 10 kΩ) | Kubii | 1 | 9,95 € |
| 7 | Conversion 12 V → 5 V | Abaisseur LM2596 | Kubii | 1 | 2,95 € |
| 8 | Alimentation | Mean Well GST36E12-P1J, 12 V 3 A 36 W, jack 5,5 × 2,1 centre +, −30 … +70 °C — stock à vérifier (alimentatorishop, RS, TME, Farnell) | à choisir | 1 | 15-20 € HT |
| 9 | Raccord d'alimentation | Embase jack femelle 5,5 × 2,1 à bornier | à choisir | 1 | — |
| 10 | Éclairage | Ruban LED blanc 12 V, 4,8 W/m, IP54, sécable tous les 5 cm, 3000-4000 K, ≈ 90 cm, collé sous la vitre du couvercle, à l'extérieur si possible | lampe-eclairage-led.com | ≈ 1 m | ≈ 2,90 €/m |
| 11 | Brumisation | Pompe membrane 12 V, avec sa diode de roue libre, + 1 à 2 buses + tuyau 4 mm + réservoir 2-5 L | à choisir | 1 lot | 25-40 € |
| 12 | Boîtier | Boîtier électrique IP65, borniers, presse-étoupes, fusible 230 V | à choisir | 1 | 15-20 € |
| 13 | Chauffage | Câble chauffant terrarium 50 W (ou câble antigel existant, s'il n'a pas de thermostat intégré) | à choisir | 1 | 0-35 € |
| 14 | Limiteur de sécurité | Thermostat Exo Terra 300 W Dimming & Pulse, réglé à 24 °C — non négociable | à choisir | 1 | 65 € |
| 15 | Isolation | Polystyrène extrudé 2-3 cm | à choisir | 1 panneau | 10-20 € |

La commande Kubii (lignes 1 et 3 à 7) revient à environ 88 €. Les prix sont des ordres de grandeur, à vérifier à l'achat.

### Budget électrique sur le 12 V

| Consommateur | Courant |
| --- | --- |
| Ruban LED (≈ 90 cm à 4,8 W/m) | 0,4 A |
| ESP32, module de relais et ventilateur, par l'abaisseur LM2596 | ≈ 0,4 A |
| Pompe de brumisation | 0,5-1 A, à vérifier |
| **Total** | **≈ 1,3-1,8 A** |

Le bloc de 3 A laisse une marge. Le chauffage, seul en 230 V, ne passe que par son relais et le limiteur.

## Feuille de route

| Phase | Contenu | Livrable |
| --- | --- | --- |
| 0 | Initialisation du dépôt, squelette PlatformIO, CI de compilation | Firmware qui compile |
| 1 | Capteurs, régulation chauffage, sécurité, mode `HIBERNATION` | Prototype utilisable cet hiver |
| 2 | Éclairage à l'heure NTP, ventilation, page web locale, persistance NVS | Régulateur complet en local |
| 3 | MQTT, alertes ntfy, OTA | Supervision à distance |
| 4 | Brumisation automatique | Gestion complète de l'humidité |
| 5 | Historique InfluxDB + Grafana | Courbes et analyse |

La phase 1 est prioritaire : avec un garage à 10-12 °C, le hors-gel et la régulation de température comptent avant tout le reste.

## Questions ouvertes

- Le câble antigel existant a-t-il un boîtier thermostat intégré ? S'il n'en a pas, il remplace l'achat d'un câble de terrarium.
- Où héberger le broker MQTT et l'historique : machine locale ou infrastructure existante ?
- Le Wi-Fi du domicile couvre-t-il correctement le garage ?
- Dépôt public ou privé, et quelle licence ?
- Quel est le niveau de déclenchement du module de relais (actif haut ou actif bas) ? Il se vérifie et se consigne avant tout raccordement, et décide du niveau des sorties au repos.
- La pompe consomme-t-elle 0,5 ou 1 A ?
- Quel cycle d'aération retenir en `ACTIF` — 5 min par heure est une proposition ?
- Le ventilateur reste-t-il coupé en `HIBERNATION` et en `MAINTENANCE`, comme proposé ?
- Sans heure valide, l'éclairage reste-t-il coupé, comme proposé ?

## Énoncés

### ADR-microcontroleur-esp32

Le régulateur tourne sur un ESP32 (ESP32-WROOM-32, carte DevKit V1). Ce qui l'a décidé : le Wi-Fi intégré pour la supervision, un redémarrage instantané après une coupure, et aucune carte SD à user — décision `01-microcontroleur`.

### ADR-commande-230v-par-relais-filaires

Les sorties — chauffage en 230 V, ruban LED et pompe en 12 V, ventilateur en 5 V — sont commandées par un module de relais électromécaniques optocouplés, câblé à l'ESP32 dans un boîtier fermé avec fusible ; la pompe garde sa diode de roue libre. Aucune sortie ne passe par une prise connectée. Ce qui l'a décidé : une prise connectée rendrait la régulation dépendante du Wi-Fi, contraire à RG-regulation-sans-reseau ; entre relais statiques et module électromécanique, l'utilisateur a choisi le module pour son prix et la simplicité d'un seul module pour toutes les sorties, sous les garde-fous de RG-relais-coupes-sans-commande — décision `02-commande-230v`.

### ADR-capteur-air-sht45

La température et l'humidité de l'air sont mesurées par un Sensirion SHT45 muni d'une membrane PTFE, sur le bus I²C. Ce qui l'a décidé : le bac vit entre 75 et 90 % HR, où le DHT22 dérive et où un BME280, sans membrane, sature — décision `03-capteur-air`.

### ADR-regulation-par-hysteresis

Chauffage et brumisation se régulent en tout-ou-rien, par hystérésis autour d'une consigne ou par seuil, et non par PID. Ce qui l'a décidé : l'inertie forte d'un bac de 215 L isolé, sur laquelle un PID n'apporte rien et ajoute des réglages à tenir — décision `04-regulation`.

### ADR-firmware-platformio-arduino

Le firmware s'écrit en C++ avec PlatformIO et le framework Arduino, dans le dépôt `sskorupski/ssk-terrarium`. Ce qui l'a décidé : un contrôle total de la logique de sécurité, et un régulateur autonome sans Home Assistant — décision `05-firmware`.

### ADR-heure-par-ntp

L'heure vient du NTP, par le Wi-Fi de l'ESP32 ; le régulateur n'a pas de module d'horloge. Ce qui l'a décidé : l'utilisateur a écarté l'horloge RTC, et seuls l'éclairage et la ventilation dépendent de l'heure — le chauffage, le hors-gel et les protections n'en ont pas besoin, si bien que RG-regulation-sans-reseau reste entière — décision `06-heure`.

### RG-mesures-periodiques

Le régulateur mesure la température et l'humidité de l'air toutes les 30 secondes. Il mesure aussi la température du substrat côté chaud quand la sonde est présente ; son absence n'empêche pas la régulation de l'air.

### RG-chauffage-par-hysteresis

En mode `ACTIF`, le chauffage s'allume quand la température de l'air descend sous la consigne moins l'hystérésis, et s'éteint quand elle dépasse la consigne plus l'hystérésis ; entre les deux, il garde son état. Par défaut, la consigne vaut 19 °C et l'hystérésis 0,5 °C. Ce que la règle protège : l'air reste dans 18-20 °C sans que le relais batte à chaque mesure.

### RG-brumisation-par-impulsions

En mode `ACTIF`, quand l'humidité de l'air passe sous le seuil, la pompe brumise une impulsion de durée fixe ; une nouvelle impulsion n'a lieu qu'après un délai minimal depuis la précédente. Par défaut, le seuil vaut 75 % HR, l'impulsion 8 secondes, le délai 10 minutes. Ce que la règle protège : l'humidité remonte par petites touches, le temps que l'air se mélange, sans détremper le substrat.

### RG-photoperiode

En mode `ACTIF`, l'éclairage est allumé pendant une plage horaire quotidienne et éteint en dehors. La plage se règle entre 12 et 16 heures d'éclairage ; par défaut, de 8 h à 21 h. L'éclairage est un ruban LED 12 V, alimenté par le bloc 12 V et commandé par une voie du module de relais.

### RG-heure-ntp

L'heure qui règle l'éclairage et les cycles de ventilation vient du NTP, par le Wi-Fi. Tant que le régulateur n'a pas d'heure valide — après un démarrage sans réseau —, l'éclairage reste coupé (à valider). Le chauffage, le hors-gel et les protections ne dépendent jamais de l'heure. Ce que la règle protège : une heure inconnue n'allume pas la lumière au milieu de la nuit, et ne prive pas le bac de chauffage.

### RG-ventilation-periodique

En mode `ACTIF`, le ventilateur aère le bac par cycles horaires : il tourne une durée fixe chaque heure — par exemple 5 minutes par heure, valeurs à valider. Il est commandé par une voie du module de relais. Ce que la règle protège : l'air confiné et saturé du bac se renouvelle, sans le dessécher.

### RG-sorties-par-mode

Le régulateur a trois modes, et chacun dit ce que chaque sortie peut faire :

| Mode | Chauffage | Brumisation | Éclairage | Ventilation | Usage |
| --- | --- | --- | --- | --- | --- |
| `ACTIF` | Consigne (défaut 19 °C) | Seuil (défaut 75 % HR) | Selon horaire | Cycles horaires | Printemps-été, ou hiver chauffé |
| `HIBERNATION` | Hors-gel : marche sous 4 °C, arrêt à 6 °C | Coupée | Coupé | Coupée (à valider) | Novembre à février |
| `MAINTENANCE` | Coupé | Coupée | Coupé | Coupée (à valider) | Nettoyage, changement de substrat |

Les mesures continuent dans tous les modes. Ce que la règle protège : en hibernation, les escargots restent au frais et au sec dans l'obscurité, sans geler ; en maintenance, rien ne s'allume pendant qu'on a les mains dans le bac.

### RG-changement-de-mode-manuel

On passe d'un mode à l'autre seulement par une commande explicite — page web locale ou MQTT. Le régulateur ne change jamais de mode de lui-même, ni selon la date, ni selon une mesure. Ce que la règle protège : aucun réveil intempestif d'un élevage en hibernation.

### RG-reglages-persistants

Le mode, les consignes, les seuils et les horaires sont stockés en mémoire non volatile et retrouvés après une coupure de courant.

### RG-regulation-sans-reseau

La régulation tourne entièrement sur le régulateur. L'absence du Wi-Fi, du broker ou de tout serveur n'a aucun effet sur le chauffage, la brumisation ni l'éclairage : le réseau ne sert qu'à superviser. Ce que la règle protège : une panne de box ou de serveur ne met pas l'élevage en danger.

### RG-sorties-coupees-au-demarrage

À chaque démarrage, chauffage, éclairage, pompe et ventilateur sont mis à l'état coupé avant toute autre opération ; avant même que le firmware ne s'exécute, RG-relais-coupes-sans-commande les tient coupés. Ce que la règle protège : un redémarrage — coupure, chien de garde, mise à jour — n'allume jamais une sortie au hasard.

### RG-capteur-en-defaut

Un capteur d'air muet ou qui rend une valeur aberrante pendant plus de 2 minutes est en défaut : chauffage et pompe sont coupés, et une alerte est émise. Ils ne reprennent que lorsque le capteur rend de nouveau des mesures valides. Ce que la règle protège : le régulateur ne chauffe ni ne brumise à l'aveugle.

### RG-impulsion-de-brumisation-bornee

Une impulsion de brumisation dure au plus 30 secondes, quels que soient les réglages, les commandes reçues ou un forçage manuel. Ce que la règle protège : un réglage faux ou un blocage ne noie pas le bac.

### RG-chauffe-continue-bornee

Le chauffage ne reste pas allumé plus de 2 heures d'affilée : au-delà, il est coupé et une alerte est émise. Ce que la règle protège : une sonde décrochée ou un câble défaillant ne fait pas chauffer sans fin.

### RG-chien-de-garde

Un chien de garde matériel redémarre le régulateur si sa boucle principale se bloque. Le redémarrage repasse par RG-sorties-coupees-au-demarrage.

### RG-relais-coupes-sans-commande

Une broche que l'ESP32 ne pilote pas — reset, boot, plantage — laisse chaque relais du module ouvert. Pour le garantir :

- le niveau de déclenchement du module (actif haut ou actif bas) est vérifié et consigné, et décide du niveau « coupé » des sorties et des résistances de rappel ;
- le cavalier JD-VCC est retiré : VCC, côté optocoupleurs, sur le 3,3 V de l'ESP32, et JD-VCC, côté bobines, sur le 5 V, pour que la logique 3,3 V commute franchement ;
- ce comportement est vérifié au multimètre, carte en reset, au boot et sans firmware, avant tout raccordement du 230 V.

Ce que la règle protège : un module électromécanique, contrairement à un MOSFET tenu par sa résistance de rappel, peut coller sur une broche flottante ou une logique trop faible ; rien ne chauffe ni ne brumise tant que le firmware n'a pas décidé.

### RG-limiteur-materiel

Un thermostat indépendant du firmware, réglé à 24 °C, est câblé en série entre le relais de chauffage et le câble chauffant. Il coupe le chauffage au-delà de 24 °C même si le firmware est bloqué relais fermé, et reste en place quelle que soit la version du firmware. Aucun élément électrique n'est à l'intérieur du bac : le câble chauffant est à l'extérieur, les capteurs seuls y entrent.

### RG-brochage

Le brochage de l'ESP32 est le suivant :

| Fonction | GPIO | Remarque |
| --- | --- | --- |
| I²C SDA (SHT45) | 21 | |
| I²C SCL | 22 | |
| 1-Wire DS18B20 | 4 | Pull-up 4,7 kΩ vers 3,3 V |
| Relais chauffage | 26 | Coupé au démarrage |
| Relais LED | 27 | Coupé au démarrage |
| Relais pompe | 25 | Coupé au démarrage |
| Relais ventilateur | 33 | Coupé au démarrage |
| LED d'état | 2 | LED intégrée de la carte |

Le niveau logique « coupé » des quatre sorties de relais dépend du niveau de déclenchement du module, à vérifier (RG-relais-coupes-sans-commande).

### RG-page-web-locale

Le régulateur sert une page web sur le réseau local : tableau de bord des mesures, des sorties et du mode, formulaire de réglages, journal des derniers événements.

### RG-topics-mqtt

Le régulateur publie et reçoit sous le préfixe `ssk-terrarium/<device-id>/` :

| Topic | Sens | Contenu |
| --- | --- | --- |
| `state` | Publié (retain), toutes les 30 s | JSON : mesures, sorties, mode, consignes, uptime |
| `event` | Publié | Alertes et changements de mode |
| `cmd/mode` | Reçu | `ACTIF`, `HIBERNATION`, `MAINTENANCE` |
| `cmd/config` | Reçu | JSON partiel : consigne, hystérésis, seuils, horaires |
| `cmd/override` | Reçu | Forçage temporaire d'une sortie, avec durée |

Un forçage est temporaire et reste soumis aux protections : il ne lève ni la durée maximale d'une impulsion, ni celle de la chauffe continue, ni la coupure sur capteur en défaut.

### RG-alertes

Le régulateur envoie une alerte sur le téléphone quand la température de l'air sort de 15-24 °C, quand l'humidité sort de 60-95 %, quand un capteur se tait, et après un redémarrage inattendu. Les alertes partent dès que le réseau le permet ; leur envoi ne retarde jamais la régulation.

### RG-mise-a-jour-protegee

Le firmware se met à jour à distance (OTA), depuis la page web locale, derrière un mot de passe.
