---
id: RG-mesures-periodiques
fonctionnalites: [mesures]
statut: actif
cree_par: 2026-001
modifie_par: [2026-005, 2026-007]
---

Le régulateur relève chaque sonde d'air (RG-sondes-d-air), température et humidité, toutes les 30 secondes, et en déduit la mesure de l'air qui sert à la régulation. Une sonde extérieure est relevée et publiée de la même façon, mais n'entre pas dans la mesure de l'air. Le DHT11 est facultatif : son absence n'empêche pas la régulation, tant qu'une sonde intérieure est acceptée. Le régulateur mesure aussi la température du substrat côté chaud quand la sonde est présente ; son absence n'empêche pas la régulation de l'air. Quand elle est présente, la mesure du substrat peut couper le chauffage (RG-coupure-par-le-substrat).
