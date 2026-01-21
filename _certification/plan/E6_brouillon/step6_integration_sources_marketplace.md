# Étape 6 – Intégration des nouvelles sources Marketplace  
**(C16 / C17 – Intégration, qualité et évolutivité des données)**

## 6.1 Zone de staging / ingestion

Afin d’intégrer efficacement les nouvelles sources de données issues des vendeurs externes, une **zone de staging** est mise en place.  
Cette zone constitue un espace tampon entre les sources Marketplace et le Data Warehouse.

### Rôles de la zone de staging

- Centraliser les données brutes provenant :
  - de fichiers (CSV, JSON),
  - d’API exposées par les vendeurs,
  - de flux événementiels.
- Appliquer une **normalisation initiale** des formats (encodage, structure, typage).
- Isoler les données non conformes avant leur propagation dans le DWH.

### Contrôles automatiques à l’ingestion

- Vérification du **format des fichiers** (JSON valide, schéma attendu).
- Contrôle de la **structure des messages** (présence des champs obligatoires).
- Rejet immédiat des données illisibles ou corrompues.

---

## 6.2 Nouvelle dimension : `dim_seller`

Dans un contexte Marketplace, l’introduction de la dimension **vendeur** est indispensable pour assurer le suivi et l’analyse multi-tenant.

### Champs recommandés

La table `dim_seller` contient notamment :

- `seller_id` : identifiant unique du vendeur.
- `seller_name` : nom commercial.
- `country` : pays d’origine.
- `category` : catégorie principale du vendeur.
- `status` : état du vendeur (actif, suspendu, désactivé).
- `created_at`, `updated_at` : dates de création et de mise à jour.

Selon les besoins analytiques, une gestion **SCD (Slowly Changing Dimension)** peut être mise en place afin de conserver l’historique des évolutions (changement de statut, de catégorie, etc.).

---

## 6.3 Qualité des données

L’ouverture du SI à des sources externes impose des **règles strictes de qualité des données**.

### Contrôles de qualité appliqués

- **Présence des champs obligatoires** (`seller_id`, `product_id`, etc.).
- **Format des identifiants** (UUID, longueurs, unicité).
- **Validation des catégories produits** par rapport à une liste de référence.
- **Détection des doublons** (vendeurs ou produits).

### Traitement des anomalies

En cas de non-conformité :

- Rejet des enregistrements en **table d’erreurs** dédiée.
- Tentative de **nettoyage automatique** si possible (trim, cast, mapping).
- **Retour au fournisseur** avec description de l’erreur pour correction.

Ces mécanismes permettent de préserver la fiabilité du DWH.

---

## 6.4 Flux ETL Marketplace

Le flux ETL d’intégration des vendeurs suit une chaîne de traitement standardisée :

1. **Ingestion** des données dans la zone de staging.
2. **Contrôles qualité** et validation des formats.
3. **Normalisation** des données (mapping des champs, harmonisation).
4. **Chargement des dimensions** (`dim_seller`, `dim_product`).
5. **Chargement des tables de faits** (`fact_order`, autres faits Marketplace).
6. **Mise à jour des logs et du monitoring** (statuts, volumes, erreurs).

Ce pipeline garantit une intégration contrôlée, traçable et scalable.

---

## 6.5 Procédure : “Ajouter une nouvelle source vendeur”

Une procédure standardisée est définie afin d’assurer une intégration sécurisée et reproductible.

### Étapes de la procédure

1. **Collecte des informations de mapping** :
   - structure des données,
   - correspondance des champs,
   - règles spécifiques du vendeur.
2. **Tests de qualité** sur un jeu de données pilote.
3. **Activation de la source** dans les flux d’ingestion.
4. **Vérification post-production** :
   - contrôle des volumes,
   - vérification des indicateurs qualité,
   - validation des données dans le DWH.

Cette procédure permet une montée en charge progressive et maîtrisée du nombre de vendeurs intégrés.

---
