# Étape 7 – Sécurité, RGPD et gestion des accès  
**(C16 / C17 – Sécurité, conformité et gouvernance des données)**

## 7.1 Cloisonnement multi-vendeurs

Dans un contexte **Marketplace multi-vendeurs**, la sécurité des données repose sur un cloisonnement strict afin de garantir que chaque acteur n’accède qu’aux informations qui le concernent.

### Séparation logique des données

- Mise en place de **Row-Level Security (RLS)** au niveau du Data Warehouse, basée sur le champ `seller_id`.
- Les règles de sécurité sont appliquées directement au niveau de la base de données, indépendamment des outils de restitution.
- Chaque requête est automatiquement filtrée selon l’identité et le rôle de l’utilisateur.

### Accès différencié selon les usages

- Les **vendeurs** n’accèdent qu’aux données associées à leur `seller_id`.
- Les **équipes internes** disposent d’une vision consolidée et transverse de la Marketplace.
- Des **vues filtrées et sécurisées** sont utilisées pour exposer uniquement les données nécessaires selon les profils.

Ce mécanisme garantit :
- la confidentialité des données inter-vendeurs,
- la conformité contractuelle,
- une isolation forte sans duplication physique des données.

---

## 7.2 Rôles d’accès et gestion des permissions

La gestion des accès repose sur une définition claire des **rôles utilisateurs**, chacun disposant de permissions adaptées à ses responsabilités.

### Rôles définis

**Administrateur DWH**
- Accès complet aux données et aux structures.
- Gestion des utilisateurs, rôles et politiques de sécurité.
- Supervision des performances, sauvegardes, restaurations et journaux de sécurité.

**Analyste interne**
- Accès aux données agrégées et indicateurs métier.
- Pas d’accès direct aux données personnelles complètes (PII).
- Utilisation de **vues anonymisées ou pseudonymisées** pour l’analyse.

**Vendeur**
- Accès strictement limité aux données liées à son `seller_id`.
- Consultation des ventes, performances et indicateurs le concernant.
- Aucun accès aux données clients non nécessaires à son activité.

Cette organisation applique le **principe du moindre privilège** et réduit les risques d’exposition de données sensibles.

---

## 7.3 Conformité RGPD

La plateforme intègre des mécanismes de conformité au **Règlement Général sur la Protection des Données (RGPD)** afin de garantir une exploitation responsable des données personnelles.

### 7.3.1 Minimisation et contrôle des données personnelles

- Les données personnelles sont **centralisées dans la dimension `dim_customer`**.
- Les tables de faits utilisent des **identifiants techniques**.
- Les vendeurs n’ont aucun accès direct aux données clients identifiantes.
- Les analystes internes travaillent principalement sur des **données agrégées ou anonymisées**.

### 7.3.2 Politique de conservation des données

- Données de navigation : conservation courte.
- Données transactionnelles : conservation longue pour obligations légales.
- Données agrégées : conservation étendue.

Une **purge automatique planifiée** est mise en place pour supprimer les données obsolètes.

### 7.3.3 Droit à l’oubli et anonymisation

- Anonymisation des données personnelles.
- Conservation des faits métiers.
- Utilisation d’un identifiant client neutre (`ANON`).

Une procédure dédiée permet de traiter les demandes RGPD de manière sécurisée et traçable.

### 7.3.4 Traçabilité et gouvernance

- Journalisation des accès et actions sensibles.
- Suivi des opérations RGPD.
- Mise à jour du registre des traitements.

---

## Conclusion

L’architecture garantit une exploitation **sécurisée, conforme et gouvernée** des données Marketplace, en accord avec les exigences réglementaires et les bonnes pratiques de l’ingénierie des données.
