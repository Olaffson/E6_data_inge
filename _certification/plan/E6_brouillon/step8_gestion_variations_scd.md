# Étape 8 – Gestion des variations (SCD – C17)
**Objectif :** gérer l’évolution des dimensions (client / produit / vendeur) dans le temps sans perdre l’historique analytique, tout en restant compatible avec la sécurité multi-vendeur (RLS) et le RGPD.

---

## 8.1 Dimensions concernées
- **Customer** : évolutions d’adresse / localisation, corrections de contact.
- **Product** : changements de catégorie, renommage, rattachement vendeur.
- **Seller** : statut (actif/suspendu), catégorie, pays.

> Rappel : les **tables de faits** ne sont pas historisées en SCD. Elles doivent pointer vers une **version** de dimension (via une clé technique “surrogate key”) afin de conserver le contexte historique.

---

## 8.2 Types de variations retenus

### SCD Type 1 (écrasement)
- Utilisé pour les attributs **non historiques** (corrections, informations sans enjeu d’historisation).
- Implémentation : `UPDATE` de la version courante.

### SCD Type 2 (historisation complète)
- Utilisé quand l’historique est nécessaire (pilotage, conformité, analyse temporelle).
- Implémentation : 
  1) clôturer la version courante (`valid_to`, `is_current = 0`)  
  2) insérer une nouvelle version (`valid_from`, `valid_to`, `is_current = 1`)

### SCD Type 3 (rare)
- Conservé uniquement en documentation (non implémenté ici) : une colonne “ancienne valeur”.

---

## 8.3 Modélisation DWH (SCD2)

### 8.3.1 Colonnes standard SCD2
Pour chaque dimension historisée :
- `*_sk` : **surrogate key** (IDENTITY) – clé technique utilisée dans les faits
- `*_id` : **natural key** (identifiant métier) – stable
- `valid_from` / `valid_to` : période de validité
- `is_current` : version courante

### 8.3.2 Conséquences sur les faits
Les faits doivent pointer sur la **version** de dimension :
- `fact_order` : `customer_sk`, `product_sk`, `seller_sk`
- `fact_clickstream` : selon disponibilité, `seller_id` peut rester nullable

✅ **Compatibilité RLS :** on conserve aussi `seller_id` (natural key) dans les tables où on applique le filtre RLS, ou on le conserve dans les dimensions filtrées.

---

## 8.4 Adaptation ETL (logique de traitement)

### 8.4.1 Principe général
1) Charger les données brutes en **staging** (ou flux stream → staging logique).
2) Comparer la “nouvelle” ligne entrante à la **version courante** (`is_current = 1`) de la dimension.
3) Appliquer les règles SCD :
- **SCD1** : mise à jour sur la ligne courante
- **SCD2** : clôture + insertion nouvelle version

### 8.4.2 Pseudo-algorithme SCD2
Pour une clé métier `X_id` :
- Si aucune ligne courante n’existe → `INSERT` (nouvelle version)
- Si existe et attribut(s) SCD2 différent(s) → 
  - `UPDATE` ligne courante : `valid_to = now`, `is_current = 0`
  - `INSERT` nouvelle ligne : `valid_from = now`, `valid_to = '9999-12-31'`, `is_current = 1`
- Sinon → rien à faire (idempotent)

### 8.4.3 Gestion des clés dans les faits
Au chargement des faits :
- Résoudre les `*_sk` en joignant sur la dimension (clé métier + timestamp) :
  - version valide à la date de l’événement (entre `valid_from` et `valid_to`)

> Pour un premier niveau (E6), on peut choisir :  
> **(A)** “version courante au moment du chargement” (plus simple)  
> ou **(B)** “version valide à l’instant T” (meilleure historisation).

---

## 8.5 Documentation (tableau SCD)

| Dimension | Attribut | Type SCD | Justification |
|---|---|---:|---|
| customer | name | SCD1 | correction / pas d’enjeu historique |
| customer | email | SCD1 | contact non utilisé pour analyse historique |
| customer | address / city / country | SCD2 | analyses géographiques dans le temps |
| product | name | SCD1 | renommage/correction |
| product | category | SCD2 | analyses “vente par catégorie” dans le temps |
| product | seller_id (changement de vendeur) | SCD2 | change le propriétaire du produit |
| seller | name | SCD1 | correction / libellé |
| seller | country / category | SCD2 | segmentation & reporting historique |
| seller | status | SCD2 | conformité / pilotage (suspension, réactivation) |

---

## Mise en œuvre dans le projet (résumé)
- Mettre à jour le schéma SQL (voir fichier `dwh_schema.sql`) pour intégrer les colonnes SCD2 (`valid_from`, `valid_to`, `is_current`) et les clés substitutives.
- Conserver les flux Stream Analytics en insert-only et déléguer l’historisation SCD2 à des triggers `INSTEAD OF INSERT` sur les dimensions.
- Supprimer les contraintes de clés étrangères sur les dimensions historisées (plusieurs versions par clé métier).
- Mettre à jour les pipelines d’ingestion/ETL (Stream Analytics ou batch) pour :
  - alimenter les dimensions via logique SCD
  - charger les faits avec les `*_sk` (ou au minimum stocker `seller_id` pour RLS)
- Tester :
  - changement d’adresse client → nouvelle version dim_customer
  - changement de statut vendeur → nouvelle version dim_seller
  - vérifier les faits avant/après (historique cohérent)

---

## Contrôles attendus (qualité / audit)
- Unicité d’une seule ligne `is_current = 1` par clé métier
- `valid_from < valid_to`
- `valid_to = '9999-12-31'` pour version courante (convention)
- Logs ETL : nombre d’INSERT / UPDATE SCD1 / UPDATE+INSERT SCD2

---

## Impacts sur sécurité (RLS) et RGPD (résumé)
- **RLS** : filtrer sur `seller_id` (clé métier) pour rester stable malgré SCD2.
- **RGPD** : droit à l’oubli = anonymisation de `dim_customer` (toutes versions) + éventuelle neutralisation des faits (selon politique).
