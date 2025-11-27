# Documentation – Système de sauvegarde Azure SQL (ShopNow Marketplace)

## 1. Introduction

Dans le cadre du projet ShopNow Marketplace, un système de sauvegarde automatisé a été mis en place pour garantir :

- la disponibilité des données du Data Warehouse (DWH),
- la résilience face aux erreurs opérationnelles,
- la conformité aux bonnes pratiques Cloud (C16),
- la protection long terme pour audit et conformité.

Ce système s’appuie sur les capacités natives d’Azure SQL Database, entièrement configurées via Terraform.

---

## 2. Types de sauvegardes mises en place

Azure SQL offre deux mécanismes complémentaires :

### 2.1 Sauvegarde court terme – PITR (Point-in-Time Restore)

- Permet de restaurer la base à un **point précis dans le temps**.
- Rétention configurable entre 7 et 35 jours.
- Idéal pour une restauration rapide en cas d’erreur humaine ou corruption de données.

### 2.2 Sauvegarde long terme – LTR (Long-Term Retention)

- Conserve des sauvegardes hebdomadaires, mensuelles ou annuelles.
- Peut aller jusqu’à 10 ans.
- Utilisée pour des raisons de conformité, d’audit et d’archivage légal.

---

## 3. Configuration automatisée via Terraform

L’intégralité du système de sauvegarde est déclarée dans le module `sql_database`.

### 3.1 Rétention court terme (PITR)

```hcl
short_term_retention_policy {
  retention_days = 14
}
```

➡️ La base `dwh-shopnow` peut être restaurée à n’importe quel point dans les **14 derniers jours**.

### 3.2 Rétention long terme (LTR)

```hcl
long_term_retention_policy {
  weekly_retention  = "P4W"
  monthly_retention = "P12M"
  yearly_retention  = "P10Y"
  week_of_year      = 1
}
```

Configuration en place :

- **P4W** → conservation d’un backup par semaine pendant 4 semaines  
- **P12M** → un backup mensuel pendant 12 mois  
- **P10Y** → un backup annuel pendant 10 ans  
- Semaine annuelle : **1**

---

## 4. Vérification de la configuration via Azure CLI

Les commandes suivantes ont permis de confirmer l’application des politiques.

### 4.1 Vérification PITR

```bash
az sql db str-policy show   --name dwh-shopnow   --server sql-server-rg-e6-okotwica   --resource-group rg-e6-okotwica
```

Résultat attendu :

```json
{
  "retentionDays": 14,
  "diffBackupIntervalInHours": 24
}
```

### 4.2 Vérification LTR

```bash
az sql db ltr-policy show   --name dwh-shopnow   --server sql-server-rg-e6-okotwica   --resource-group rg-e6-okotwica
```

Résultat attendu :

```json
{
  "weeklyRetention": "P4W",
  "monthlyRetention": "P12M",
  "yearlyRetention": "P10Y",
  "weekOfYear": 1
}
```

➡️ Les politiques configurées via Terraform sont bien activées.

---

## 5. Fonctionnement opérationnel

### 5.1 Sauvegardes automatiques

Azure SQL génère automatiquement :

- backups complets,
- backups différentiels,
- logs de transactions.

Aucune action manuelle n’est requise.

### 5.2 Processus de restauration PITR

1. Ouvrir Azure Portal → SQL Database → **Backups**
2. Sélectionner un **point dans le temps**
3. Restaurer vers une nouvelle base (ex : `dwh-shopnow-restore`)
4. Supprimer la base source si nécessaire
5. Renommer la base restaurée en `dwh-shopnow`

### 5.3 Processus de restauration LTR

- Identique à PITR mais effectué à partir des backups long terme.
- Conçu pour restaurer des données très anciennes.

---

## 6. Procédure de restauration (pour documentation d’exploitation)

### 6.1 Restauration complète via PITR

```bash
az sql db restore   --name dwh-shopnow   --server sql-server-rg-e6-okotwica   --resource-group rg-e6-okotwica   --dest-name dwh-shopnow-restore   --time <timestamp-utc>
```

Puis remplacement :

```bash
az sql db delete --name dwh-shopnow --server sql-server-rg-e6-okotwica --resource-group rg-e6-okotwica --yes
az sql db rename --name dwh-shopnow-restore --new-name dwh-shopnow --server sql-server-rg-e6-okotwica --resource-group rg-e6-okotwica
```

---

## 7. Tests périodiques (exigence C16)

Tests recommandés :

### 7.1 Test mensuel
- Restaurer la base dans un environnement isolé
- Vérifier les volumes et la cohérence

### 7.2 Test trimestriel
- Restaurer partiellement une table clé (ex : `fact_order`)
- Vérifier les relations avec `dim_seller` et `dim_product`

---

## 8. Avantages du système de sauvegarde

| Avantage | Explication |
|---------|-------------|
| **Automatisé** | Déployé entièrement via Terraform |
| **Traçable** | Versionné dans le code |
| **Robuste** | Double mécanisme PITR + LTR |
| **Sécurisé** | Conformité aux meilleures pratiques Microsoft |
| **Flexible** | Restauration partielle ou totale |
| **Audit-ready** | Conservation jusqu’à 10 ans |

---

## 9. Conclusion

Le système de sauvegarde du DWH ShopNow Marketplace est complet, robuste et conforme aux bonnes pratiques Cloud. En combinant **PITR** pour la récupération rapide et **LTR** pour l’archivage long terme, la solution assure une protection optimale des données critiques.

L’approche Infrastructure-as-Code via Terraform garantit une traçabilité totale et une reproductibilité parfaite du système de sauvegarde.
