---
id: RG-chauffage-par-plages
fonctionnalites: [modes, chauffage, reglages]
statut: actif
cree_par: 2026-003
modifie_par: []
---

En mode `PLAGES`, le chauffage suit jusqu'à 4 plages horaires quotidiennes. Une plage s'écrit `HH:MM-HH:MM`, à la minute, dans le fuseau réglé (ADR-heure-par-ntp) ; son début est inclus, sa fin exclue ; elle peut passer minuit (`22:00-02:00`) ; son début ne peut pas égaler sa fin. Les plages peuvent se recouvrir : on est en plage dès qu'on est dans l'une d'elles. Sans aucune plage, on n'est jamais en plage. Le firmware fournit deux plages par défaut : `01:35-06:30` et `14:05-17:05`.

- **En plage**, le chauffage suit RG-chauffage-par-hysteresis, avec la consigne et l'hystérésis réglées.
- **Hors plage**, le chauffage s'allume quand l'air descend sous 12 °C et s'éteint quand il atteint 14 °C ; entre les deux, il garde son état. Ces seuils sont fixés à la compilation.
- **Tant que l'heure n'est pas connue** depuis le démarrage (ADR-heure-par-ntp), le mode se comporte comme en plage.

RG-capteur-en-defaut et RG-chauffe-continue-bornee s'appliquent en plage comme hors plage ; après la coupure de 15 minutes, le chauffage reprend sur la cible du moment, plage ou plancher. Chaque entrée et chaque sortie de plage est annoncée sur la liaison série. Ce que la règle protège : l'élevage est chauffé aux heures choisies sans que l'air passe sous 12 °C le reste du temps, et une heure inconnue ne le fait jamais descendre au plancher.
