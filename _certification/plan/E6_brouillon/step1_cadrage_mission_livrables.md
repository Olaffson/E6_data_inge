# Étape 1 – Cadrage de la mission et des livrables  
**(C16 / C17 – Cadrage et objectifs du projet)**

## 1.1 Contexte

La plateforme **ShopNow** est initialement conçue selon un modèle de **e-commerce classique**, dans lequel l’entreprise gère directement l’ensemble du catalogue produits, des ventes et de la relation client.

Dans une logique d’évolution métier, ShopNow engage une **transition vers un modèle Marketplace**, permettant à **plusieurs vendeurs externes** de publier, gérer et vendre leurs propres produits via la plateforme.

Cette évolution implique des impacts majeurs sur le **système d’information décisionnel**, et en particulier sur le **Data Warehouse (DWH)** existant :

- multiplication des sources de données,
- hétérogénéité des flux entrants,
- besoin de suivi et d’analyse par vendeur,
- exigences accrues en matière de sécurité, traçabilité et qualité des données.

Le DWH doit donc être repensé pour accompagner cette transformation stratégique.

---

## 1.2 Objectifs globaux de la mission

La mission confiée consiste à **adapter et sécuriser l’architecture décisionnelle** afin de répondre aux nouveaux besoins induits par le modèle Marketplace.

### Objectifs fonctionnels

- Adapter le **modèle de données du DWH** pour intégrer la notion de vendeur.
- Permettre des analyses multi-vendeurs (ventes, performance, volumes).
- Assurer une séparation logique des données dans un contexte multi-tenant.

### Objectifs techniques

- Garantir la **qualité des données** issues de sources externes.
- Sécuriser l’accès aux données et aux infrastructures.
- Renforcer la **fiabilité** et la **résilience** de la plateforme.
- Mettre en place des mécanismes de **journalisation, supervision et sauvegarde**.

### Objectifs méthodologiques (C16 / C17)

- Appliquer les bonnes pratiques de **maintenance, supervision et exploitation** (C16).
- Industrialiser les déploiements via **Infrastructure as Code (Terraform)** (C17).
- Structurer la documentation et les processus d’exploitation.

---

## 1.3 Livrables attendus

La mission donne lieu à la production des livrables suivants :

- **Rapport professionnel** détaillant :
  - l’analyse de l’existant,
  - les évolutions proposées,
  - les choix d’architecture et de maintenance  
  *(volume attendu : 5 à 10 pages)*.

- **Présentation orale** synthétique :
  - contexte,
  - problématique,
  - solution proposée,
  - démonstration des apports techniques  
  *(durée : 5 à 10 minutes)*.

- **Documentation d’exploitation** :
  - procédures de maintenance,
  - supervision et alertes,
  - sauvegardes et restauration,
  - rôles et responsabilités.

Ces livrables visent à démontrer la capacité à concevoir, exploiter et maintenir une plateforme décisionnelle conforme aux attentes professionnelles.

---
