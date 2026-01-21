# Étape 3 – Organisation de la maintenance  
**(C16 – Méthodologie d’exploitation)**

## 3.1 Modèle d’organisation de la maintenance (inspiré ITIL)

La maintenance de la plateforme **ShopNow Marketplace** s’appuie sur un modèle organisationnel inspiré des bonnes pratiques **ITIL (Information Technology Infrastructure Library)**, afin d’assurer la continuité de service, la traçabilité des actions et une amélioration continue.

Un **outil de ticketing** (ex. Jira, GLPI, Wrike) est utilisé pour centraliser l’ensemble des demandes et incidents. Chaque événement est formalisé sous forme de ticket, permettant un suivi structuré du cycle de vie.

### Typologie des tickets

Les tickets sont classifiés selon leur nature :

- **Incident** : interruption ou dysfonctionnement non prévu du service (ex. arrêt du job Stream Analytics, indisponibilité du DWH).
- **Problème** : analyse approfondie d’incidents récurrents afin d’en identifier la cause racine.
- **Demande de service** : action standard planifiée (ex. création d’un accès, restauration d’une sauvegarde).
- **Évolution** : amélioration ou adaptation fonctionnelle ou technique (ex. ajout d’une nouvelle dimension dans le DWH).

Cette classification permet d’adapter les processus de traitement, les délais et les responsabilités associées.

---

## 3.2 Priorisation des incidents et SLA

Les tickets sont priorisés en fonction de leur **impact métier** et de leur **urgence**, avec des **engagements de temps de résolution (SLA)** clairement définis.

| Priorité | Description | Exemple | SLA de résolution |
|--------|------------|---------|------------------|
| **P1 – Critique** | Rupture totale de service | DWH indisponible, flux Event Hub arrêté | < 4 heures |
| **P2 – Majeure** | Dégradation significative | Retard de traitement, erreurs ASA | < 24 heures |
| **P3 – Mineure** | Faible impact ou demande | Évolution, optimisation | < 72 heures |

Ce mécanisme garantit une allocation efficace des ressources et une réponse proportionnée à l’impact business.

---

## 3.3 Rôles et responsabilités

La maintenance repose sur une **répartition claire des rôles**, chacun disposant d’un périmètre de responsabilité défini.

### Rôles clés

**Data Engineer**
- Supervision des pipelines de données (Event Hubs, Stream Analytics).
- Correction des erreurs de transformation et de qualité des données.
- Implémentation des évolutions du modèle de données.

**Administrateur DWH**
- Gestion du serveur SQL et du Data Warehouse.
- Supervision des performances, sauvegardes et restaurations.
- Application des politiques de sécurité et de rétention.

**Exploitant / Support**
- Surveillance quotidienne via les dashboards et alertes.
- Qualification et routage des tickets.
- Communication avec les équipes métier en cas d’incident.

Chaque rôle intervient selon des procédures documentées, garantissant la **traçabilité**, la **réversibilité des actions** et la **continuité opérationnelle**.
