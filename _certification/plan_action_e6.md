# Plan d’action E6 – ShopNow Marketplace  
Version complète et détaillée

## Étape 1 – Cadrage de la mission et des livrables

### 1.1 Contexte
ShopNow migre d’un modèle classique e-commerce vers une **Marketplace** où plusieurs vendeurs externes publient et gèrent leurs produits. Cette transition impacte directement l’architecture du **Data Warehouse (DWH)** existant.

### 1.2 Objectifs globaux
- Adapter le DWH aux nouveaux besoins Marketplace.  
- Garantir la **qualité**, la **sécurité**, la **fiabilité** et la **traçabilité** des données.  
- Mettre en place les pratiques de maintenance correspondant aux compétences **C16** et **C17**.

### 1.3 Livrables attendus
- Rapport professionnel (5–10 pages).  
- Présentation orale (5–10 minutes).  
- Documentation d’exploitation.  

---

## Étape 2 – Analyse de l’existant

### 2.1 Architecture DWH actuelle
- Modèle en étoile avec : `dim_customer`, `dim_product`, `fact_order`, `fact_clickstream`.
- Ingestion en temps réel via Event Hub / Streaming.
- Processus ETL quotidiens.

### 2.2 Limites actuelles
- Absence de la dimension **vendeur**.  
- Pas de cloisonnement multi-tenant.  
- Peu de mécanismes de qualité des données pour les sources externes.  
- Process ETL non adaptés à des flux hétérogènes.

### 2.3 Analyse de l’infra déjà en place
- Vérification des ressources (Terraform) créant stockage, base, monitoring, etc.  
- État des logs, sauvegardes, niveaux d’accès existants.

---

## Étape 3 – Organisation de la maintenance (C16 – Méthodologie)

### 3.1 Modèle d’organisation (inspiré ITIL)
- Utilisation d’un outil de ticketing (Jira/GLPI/Wrike/etc.).
- Classification en incidents, problèmes, demandes de service, évolutions.

### 3.2 Priorisation & SLA
- P1 : Rupture de service – résolution < 4h.  
- P2 : Dégradation – résolution < 24h.  
- P3 : Demande ou faible impact – < 72h.

### 3.3 Rôles et responsabilités
- Data Engineer  
- Administrateur DWH  
- Exploitant  
Chaque rôle est associé à un périmètre de prise en charge défini.

---

## Étape 4 – Journalisation, supervision et alertes (C16)

### 4.1 Journalisation
- Logs techniques (ETL, infra).  
- Logs fonctionnels (qualité, événements critiques).  
- Conventions : timestamp, source, type, message, code erreur, seller_id.

### 4.2 Catégorisation des logs
- INFO / WARNING / ERROR.  
- Journaux de sécurité (connexion, rôles, permissions).  
- Journaux qualité (contrôles KO).

### 4.3 Alertes automatiques
- Échec d’un job ETL.  
- Dépassement du SLA d’un datamart.  
- Taux d’erreurs fournisseur > seuil.  
Canaux : e-mail, Teams, SMS (selon criticité).

### 4.4 Tableau de bord de supervision
- Taux de succès ETL.  
- Latence DWH.  
- Volume par vendeur.  
- Indicateurs sécurité.

---

## Étape 5 – Sauvegardes complètes et partielles

### 5.1 Ce qui doit être sauvegardé
- Base DWH.  
- Schémas + métadonnées ETL.  
- Zone de staging (temporairement).  

### 5.2 Types de sauvegarde
- **Complète** : hebdomadaire (ou quotidienne selon volume).  
- **Partielle** : sur schémas critiques (quotidien).  
- Export schéma/métadonnées.

### 5.3 Procédures
- Décrire étapes de restauration complète.  
- Décrire restauration partielle (datamart ou table).  
- Tests périodiques de restauration.

---

## Étape 6 – Intégration des nouvelles sources Marketplace

### 6.1 Zone de staging / ingestion
- Normalisation des fichiers/API des vendeurs.  
- Contrôles automatiques format/structure.

### 6.2 Nouvelle dimension : `dim_seller`
Champs recommandés :
- seller_id  
- seller_name  
- country  
- category  
- status  
- dates d’historisation (si SCD)

### 6.3 Qualité des données
- Présence des champs obligatoires.  
- Format des identifiants.  
- Vérification des catégories produits.  
- Détection doublons.

Traitement des anomalies :
- Rejet en table d’erreurs.  
- Nettoyage automatique.  
- Retour au fournisseur.

### 6.4 Flux ETL Marketplace
1. Ingestion → staging  
2. Contrôles qualité  
3. Normalisation  
4. Chargement dimensions  
5. Chargement faits  
6. Mise à jour logs & monitoring

### 6.5 Procédure “Ajouter une source vendeur”
- Collecte mapping.  
- Tests qualité.  
- Activation.  
- Vérification post-production.

---

## Étape 7 – Sécurité, RGPD et gestion des accès

### 7.1 Cloisonnement multi-vendeurs
- RLS (Row-Level Security) sur seller_id.  
- Vues filtrées pour chaque vendeur.  
- Données agrégées pour équipe interne.

### 7.2 Rôles d’accès
- Admin DWH  
- Analyste interne (pas d’accès PII complet).  
- Vendeur (accès restreint sur seller_id).

### 7.3 RGPD
- Minimisation : supprimer champs inutiles.  
- Conservation : durée limitée.  
- Pseudonymisation / anonymisation du client.  
- Procédure droit à l’oubli.  
- Mise à jour registre des traitements.

---

## Étape 8 – Gestion des variations (SCD – C17)

### 8.1 Dimensions concernées
- customer  
- product  
- seller

### 8.2 Types de variations
- **SCD1** : écrasement → attributs non historiques.  
- **SCD2** : historisation complète → changement d’adresse, catégorie produit, statut vendeur.  
- **SCD3** : très rare, ancienne valeur conservée.

### 8.3 Modélisation DWH
Pour SCD2 :
- surrogate_key  
- natural_key  
- valid_from  
- valid_to  
- is_current  

### 8.4 Adaptation ETL
- Comparaison staging vs dimension.  
- SCD1 → UPDATE.  
- SCD2 → UPDATE + INSERT nouvelle version.

### 8.5 Documentation
- Tableau : attribut → type SCD choisi → justification.

---

## Étape 9 – Monitoring, documentation et rapport final

### 9.1 Indicateurs de monitoring
- Succès ETL.  
- Temps d’exécution.  
- Taux d’erreurs vendeur.  
- État des sauvegardes.  
- Charges par vendeur.

### 9.2 Documentation d’exploitation
- Ajouter un vendeur.  
- Ajouter un accès.  
- Restaurer sauvegarde.  
- Ajouter un datamart.  
- Vérifier logs / alertes.

### 9.3 Rapport professionnel
Plan conseillé :
1. Contexte  
2. Problématique Marketplace  
3. État des lieux  
4. Organisation maintenance  
5. Journalisation & monitoring  
6. Sauvegardes  
7. Intégration vendeurs  
8. Sécurité & RGPD  
9. SCD & évolutions ETL  
10. Conclusion

### 9.4 Préparation orale
- Pitch 5–7 min.  
- Schémas simples.  
- Mettre en avant démarche + justification.  
- Préparer réponses aux questions types.

---

## Conclusion
Ce plan constitue la feuille de route complète pour la réalisation du projet E6 autour de la transition vers la plateforme Marketplace ShopNow, couvrant C16 (maintenance) et C17 (évolution du DWH).

