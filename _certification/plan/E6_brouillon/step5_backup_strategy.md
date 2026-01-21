
# Étape 5 – Sauvegardes complètes et partielles

## 5.1 Ce qui doit être sauvegardé

Dans l’architecture ShopNow Marketplace, plusieurs éléments critiques nécessitent une stratégie de sauvegarde structurée :

### 1. Base SQL du DWH
Elle contient :
- dim_customer  
- dim_product  
- dim_seller  
- fact_order  
- fact_clickstream  

C’est la source de vérité analytique du système.

### 2. Schémas & métadonnées DWH / ETL
À sauvegarder :
- Le script SQL `dwh_schema.sql`
- La requête Stream Analytics (transformation_query)
- Les fichiers ETL / code producteurs (`producers.py`)
- La configuration Terraform (notamment stream_analytics/main.tf)

### 3. Zone de staging
Event Hub constitue la zone de transit des événements.  
La rétention native peut servir de sauvegarde minimale mais doit être complétée par **Event Hub Capture** si besoin d’archivage long terme.

---

## 5.2 Types de sauvegarde

### 🔵 1. Sauvegarde complète du DWH
- **Fréquence recommandée : quotidienne (nuit).**
- Méthode : Azure SQL Automatic Backups.
- Conservation : 7 à 35 jours selon le tier.

### 🟢 2. Sauvegarde partielle (tables critiques)
Les tables les plus sensibles :
- `fact_order` (transactions)
- `dim_seller` (nouveau modèle Marketplace)
- `dim_product` (relation produit–vendeur)

Exemple SQL simple :
```sql
SELECT * INTO backup.fact_order_20250201
FROM fact_order;
```

Ou export automatisé via `bcp` :
```bash
bcp "SELECT * FROM dim_seller" queryout dim_seller_20250201.csv -S server -d db -U user -P pass -c
```

### 🟣 3. Sauvegarde des métadonnées
Comprend :
- `dwh_schema.sql`
- `main.tf` du job Stream Analytics
- `producers.py`
- Scripts SQL de création de tables, vues, clés étrangères

Bonne pratique :
- Versionner l’ensemble dans GitHub.
- Snapshot hebdo automatique.

### 🟠 4. Sauvegarde Event Hub (staging)
- Rétention 1–7 jours → backup minimal
- Option recommandée : **Event Hub Capture vers Azure Blob Storage**
  - Permet de conserver un historique long terme du flux brut

---

## 5.3 Procédures de restauration

### 🔵 Restauration complète
1. Aller dans Azure SQL → Backups.
2. Choisir le point dans le temps.
3. Restaurer la base (overwrite ou nouvelle base).
4. Vérifier l’intégrité (COUNT(*), clés étrangères).
5. Redémarrer le job Stream Analytics et le conteneur `aeh-producers` si nécessaire.

---

### 🟢 Restauration partielle d’une table

#### Exemple : `dim_seller`
1. Créer une table temporaire :
```sql
SELECT * INTO dim_seller_restore
FROM backup.dim_seller_20250201;
```

2. Vérifier la cohérence.

3. Effectuer la restauration :
```sql
DELETE FROM dim_seller;
INSERT INTO dim_seller SELECT * FROM dim_seller_restore;
```

#### Exemple : `fact_order`
1. Sauvegarde préalable :
```sql
SELECT * INTO fact_order_before_restore FROM fact_order;
```

2. Restauration :
```sql
DELETE FROM fact_order;
INSERT INTO fact_order SELECT * FROM backup.fact_order_20250201;
```

---

### 🟠 Restauration des métadonnées

#### Stream Analytics
- Réappliquer le Terraform :
```bash
terraform apply
```
→ Recrée les outputs, inputs et transformation_query.

#### Schéma SQL
- Exécuter `dwh_schema.sql` pour reconstruire la structure en cas d’erreur critique.

---

## 5.4 Tests périodiques de restauration (C16)

### Test mensuel
1. Restaurer un full backup dans une base `dwh_restore_test`.
2. Vérifier :
   - volumes de données,
   - cohérence des dimensions,
   - qualité des relations vendeur–produit.

### Test trimestriel
- Restaurer un datamart (exemple : `dim_product`)
- Vérifier l’intégrité référentielle avec `dim_seller`

---

## Résumé
Cette stratégie garantit :
- la sécurité des données,
- la disponibilité opérationnelle,
- la conformité Marketplace,
- la traçabilité complète,
- et une résilience maîtrisée, conformément aux compétences C16 / C17.

