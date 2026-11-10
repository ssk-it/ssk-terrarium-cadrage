---
id: RG-chauffe-continue-bornee
fonctionnalites: [protections, chauffage]
statut: actif
cree_par: 2026-001
modifie_par: [2026-005]
---

Le chauffage ne reste pas allumé plus de 2 heures d'affilée : au-delà, il est coupé pendant 15 minutes, et le dépassement est signalé par la LED d'état et sur la liaison série ; l'alerte sur téléphone s'y ajoutera avec sa phase. Passé ces 15 minutes, le chauffage reprend sur la consigne du mode, sans intervention, sauf si la coupure par le substrat tient encore (RG-coupure-par-le-substrat) : un verrou posé la nuit laisserait le bac refroidir jusqu'au matin, hors-gel compris. La règle borne une durée, non une température : la coupure par le substrat borne la température du substrat, mais rien de matériel ne couvre une surchauffe en phase 1 (décision `06-protection-contre-la-surchauffe`). Des coupures qui se répètent signalent une chauffe sous-dimensionnée ou un relais collé. Ce que la règle protège : une sonde décrochée ou un câble défaillant ne fait pas chauffer sans fin.
