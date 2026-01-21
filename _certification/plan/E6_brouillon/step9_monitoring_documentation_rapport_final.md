# Étape 9 – Monitoring, documentation et rapport final  
**(C16 / C17 – Exploitation, supervision et valorisation du projet)**

---

## 9.1 Indicateurs de monitoring

La supervision du Data Warehouse Marketplace repose sur un ensemble d’indicateurs permettant de garantir la **fiabilité**, la **performance** et la **qualité des données**.

### Indicateurs techniques (ETL & flux)

- **Succès / échec des traitements ETL**
  - Surveillance des erreurs Stream Analytics.
  - Détection des interruptions de flux Event Hubs.
- **Temps d’exécution et latence**
  - Délai entre la réception d’un événement et son intégration dans le DWH.
- **Volumétrie**
  - Nombre de messages entrants par Event Hub.
  - Évolution de l’activité Marketplace.

### Indicateurs qualité & Marketplace

- **Taux d’erreurs par vendeur**
  - Données rejetées pour non-conformité.
  - Erreurs de format ou de schéma.
- **Charges par vendeur**
  - Volume de commandes.
  - Activité clickstream par vendeur.

### Indicateurs sécurité & fiabilité

- **État des sauvegardes**
  - Sauvegardes automatiques (PITR).
  - Sauvegardes long terme (LTR).
- **Alertes critiques**
  - CPU SQL élevé.
  - Absence de messages entrants.
  - Erreurs Stream Analytics.

Ces indicateurs sont centralisés dans **Azure Monitor / Log Analytics** et visualisés via des **Workbooks**, avec déclenchement d’alertes automatiques.

---

## 9.2 Documentation d’exploitation

Une documentation d’exploitation est mise en place afin de garantir la **maintenabilité** et la **reproductibilité** du système.

### Procédures principales

#### Ajouter un vendeur
1. Créer l’entrée vendeur dans la dimension `dim_seller`.
2. Associer un `seller_id` unique.
3. Mettre à jour le mapping de sécurité (RLS).
4. Vérifier l’accès et les données visibles.

#### Ajouter un accès utilisateur
- Attribution du rôle approprié (`seller_role`, `internal_analyst`, `dwh_admin`).
- Vérification des permissions.
- Test du cloisonnement via RLS.

#### Restaurer une sauvegarde
- Choix du type de restauration (PITR ou LTR).
- Restauration dans une base temporaire.
- Validation de l’intégrité.
- Remplacement de la base si nécessaire.

#### Ajouter un datamart
- Identification du besoin métier.
- Création de vues ou tables agrégées.
- Sécurisation par rôles et RLS.
- Ajout au monitoring et aux dashboards.

#### Vérifier les logs et alertes
- Consultation du Log Analytics Workspace.
- Analyse de l’historique des alertes.
- Vérification des diagnostics et métriques.

---

## 9.3 Rapport professionnel

Le rapport final vise à présenter le projet de manière claire, structurée et professionnelle.

### Plan recommandé

1. Contexte et objectifs  
2. Problématique de la transformation Marketplace  
3. Analyse de l’existant  
4. Organisation de la maintenance  
5. Journalisation, monitoring et alertes  
6. Sauvegardes et restauration  
7. Intégration des vendeurs Marketplace  
8. Sécurité, RGPD et gestion des accès  
9. Gestion des évolutions (SCD & ETL)  
10. Conclusion et perspectives

Chaque section présente :
- le problème identifié,
- la solution mise en œuvre,
- la justification des choix techniques.

---

## 9.4 Préparation orale

### Pitch (5–7 minutes)

- **Introduction** : contexte ShopNow et évolution vers une Marketplace.
- **Problématique** : multi-vendeurs, sécurité, scalabilité, gouvernance.
- **Architecture cible** : Event Hubs → Stream Analytics → DWH.
- **Points forts techniques** :
  - Cloisonnement multi-vendeurs (RLS).
  - Gestion des évolutions (SCD2).
  - Sauvegardes et restauration.
  - Monitoring et alertes.
- **Gouvernance & conformité** :
  - RGPD.
  - Droit à l’oubli.
  - Gestion des accès.
- **Conclusion** : solution robuste, évolutive et conforme.

### Questions types à anticiper

- Pourquoi privilégier l’anonymisation plutôt que la suppression des faits ?  
- Pourquoi utiliser des SCD de type 2 ?  
- Comment garantir qu’un vendeur n’accède qu’à ses données ?  
- Que se passe-t-il en cas de panne ou d’erreur critique ?  

---

## Conclusion – Étape 9

Cette étape permet de valoriser l’ensemble du projet en démontrant :
- une vision **exploitation et long terme**,
- une **maîtrise du monitoring et de la supervision**,
- une capacité à documenter et transmettre,
- une préparation solide à l’oral.

Elle confirme que la solution mise en place est **opérationnelle, maintenable et conforme**, répondant pleinement aux exigences des compétences **C16 et C17**.
