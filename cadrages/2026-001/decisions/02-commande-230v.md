---
id: 02-commande-230v
titre: Comment commander le chauffage, l'éclairage, la pompe et le ventilateur ?
statut: retenue
option_retenue: relais-electromecaniques-optocouples
---

## Description

Le câble chauffant est en 230 V, le ruban LED et la pompe en 12 V, le ventilateur en 5 V. Leur commande doit rester sûre électriquement, ne jamais s'enclencher sans ordre du firmware, et surtout ne pas faire dépendre la régulation du réseau.

## Options

### prises-shelly

Des prises connectées en Wi-Fi, commandées par l'ESP32 ou par un serveur.

**Pour** — aucun câblage 230 V à faire soi-même.
**Contre** — chaque commande passe par le Wi-Fi : une box en panne laisse le chauffage dans son dernier état, contraire à NF1.

### relais-ssr-et-mosfet

Un module de deux relais statiques Omron G3MB-202P pour le 230 V, un MOSFET logique pour la pompe 12 V.

**Pour** — silencieux, sans usure mécanique ; un MOSFET tenu par sa résistance de rappel reste coupé au boot sans autre précaution.
**Contre** — deux modules et des composants à assembler, plus chers ; un SSR peut rester collé, et il ne commute pas le continu du ruban LED ni du ventilateur.

### relais-electromecaniques-optocouples

**Retenue.** Un module de 4 relais 5 V optocouplés à cavalier JD-VCC séparable, câblé à l'ESP32 dans le boîtier IP65 fermé avec fusible : chauffage, LED, pompe, ventilateur. La pompe garde sa diode de roue libre. Le module 6 relais de Kubii, d'abord retenu, est écarté : en rupture, et sa fiche ne dit ni son niveau de déclenchement ni s'il a un cavalier JD-VCC.

**Pour** — un seul module, bon marché (≈ 8-12 €), pour toutes les sorties, continu comme alternatif.
**Contre** — une bobine 5 V pilotée par une logique 3,3 V, un niveau de déclenchement à vérifier, une broche flottante qui peut enclencher un relais : d'où les garde-fous de RG-relais-coupes-sans-commande. Un contact peut coller, d'où le limiteur matériel en série (RG-limiteur-materiel).

## Décision

Relais électromécaniques optocouplés, filaires, dans un boîtier fermé. Ce qui a tranché : les prises connectées rendent la régulation dépendante du Wi-Fi, ce que NF1 interdit ; entre les deux options filaires, l'utilisateur a choisi le module de relais pour son prix et la simplicité d'un seul module, à condition que RG-relais-coupes-sans-commande soit tenue et vérifiée au multimètre avant tout raccordement du 230 V.
