# ssk-terrarium — référentiel de cadrage

Le référentiel de **ssk-terrarium**, au format SSK Canon.

ssk-terrarium répond à une question : *comment tenir, sans y penser et sans jamais les mettre en danger, la température, l'humidité et la lumière du bac où vivent mes escargots ?* Ce dépôt en porte le *pourquoi* : ce que le régulateur doit faire, les décisions prises pour y arriver, et les options écartées. Il est réalisé par un dépôt :

- [`sskorupski/ssk-terrarium`](https://github.com/sskorupski/ssk-terrarium) — le firmware ESP32 : PlatformIO, framework Arduino, C++17.

L'élevage lui-même — l'espèce, l'installation, le journal — est décrit dans [`sskorupski/skarden`](https://github.com/sskorupski/skarden).

## Structure

| Dossier | Contenu |
|---|---|
| `domains/` | Les domaines fonctionnels |
| `features/` | Les fonctionnalités, rattachées à des domaines |
| `rules/` | Les règles de gestion — l'unité atomique du référentiel |
| `decisions/` | Les décisions d'architecture en vigueur — pourquoi le produit est construit ainsi |
| `cadrages/` | Les unités de changement, datées |

Le référentiel décrit l'état courant du produit ; les cadrages le transforment. Le référentiel est la projection des cadrages livrés.

## Le découpage

| Domaine | Fonctionnalités |
|---|---|
| Régulation | `mesures`, `chauffage`, `brumisation`, `eclairage`, `modes`, `reglages` |
| Sécurité | `protections`, `modes`, `boitier-de-commande` |
| Supervision | `page-web`, `mqtt`, `alertes`, `mise-a-jour`, `reglages` |
| Matériel | `boitier-de-commande` |

Les règles de gestion naissent des cadrages : leur texte n'est écrit dans `rules/` qu'à la livraison de l'un d'eux.

## Mise en place

Le dépôt se crée par [`outils/mise-en-place-github.sh`](outils/mise-en-place-github.sh), relançable.
