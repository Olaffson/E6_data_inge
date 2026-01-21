# Étape 2 – Analyse de l’existant  
**(C16 – Analyse et compréhension de l’architecture)**

## 2.1 Architecture DWH actuelle

L’architecture actuelle du Data Warehouse (DWH) de la plateforme **ShopNow** repose sur un modèle décisionnel classique en **étoile**, adapté à l’analyse des ventes et des comportements utilisateurs.

### Modèle de données

Le schéma est composé des tables suivantes :

- **dim_customer** : informations clients (identité, localisation).
- **dim_product** : catalogue produits.
- **fact_order** : faits de vente (commandes, quantités, montants).
- **fact_clickstream** : événements de navigation utilisateurs.

Ce modèle permet des analyses orientées **clients, produits et ventes**, mais reste limité à un contexte mono-vendeur.

### Ingestion et traitement des données

- **Ingestion en temps réel** via **Azure Event Hubs**, alimentés par des producteurs d’événements.
- **Traitement streaming** assuré par **Azure Stream Analytics**, transformant les événements entrants et alimentant le DWH.
- **Processus ETL planifiés** (quotidiens) pour les traitements complémentaires et consolidations.

Cette architecture garantit une faible latence entre la génération des événements et leur disponibilité analytique.

---

## 2.2 Limites actuelles identifiées

L’analyse de l’existant met en évidence plusieurs limites face aux nouveaux besoins de type **Marketplace**.

### Limites fonctionnelles

- **Absence de la dimension vendeur** :
  - Impossible d’analyser les ventes par vendeur.
  - Pas de différenciation entre produits internes et vendeurs tiers.
- **Pas de cloisonnement multi-tenant** :
  - Les données de tous les vendeurs sont agrégées sans séparation logique.
  - Risque de non-conformité en cas d’accès différencié.

### Limites techniques

- **Peu de mécanismes de qualité des données** pour les sources externes :
  - Données incomplètes ou incohérentes possibles.
  - Absence de contrôles automatiques à l’ingestion.
- **Processus ETL peu adaptés à des flux hétérogènes** :
  - Difficulté à intégrer des formats ou fréquences variables.
  - Faible scalabilité face à l’augmentation du nombre de vendeurs.

Ces limites justifient une évolution de l’architecture et du modèle de données.

---

## 2.3 Analyse de l’infrastructure existante

L’infrastructure actuelle a été analysée à partir de la configuration **Terraform** existante.

### Ressources déjà en place

- **Azure Event Hubs** pour l’ingestion des flux temps réel.
- **Azure Stream Analytics** pour les traitements streaming.
- **Azure SQL Database** hébergeant le DWH.
- **Azure Log Analytics Workspace** pour la centralisation des logs et métriques.
- **Sauvegardes automatiques** (PITR et LTR) configurées sur la base SQL.

### État des mécanismes transverses

- **Logs** :
  - Disponibles pour Event Hubs, Stream Analytics et SQL.
  - Centralisés dans Log Analytics.
- **Sauvegardes** :
  - Sauvegardes automatiques actives.
  - Rétention conforme aux besoins définis.
- **Sécurité et accès** :
  - Accès administrateur SQL existant.
  - Séparation des rôles encore limitée (amélioration possible).

Cette analyse confirme que l’infrastructure fournit une base solide, mais nécessite des adaptations pour répondre aux exigences d’une plateforme Marketplace multi-vendeurs.

---
