# Script oral chronométré – Soutenance E6 ShopNow Marketplace

Durée cible : 6 minutes

## Introduction (30s)
Bonjour, je m’appelle Olivier Kotwica, Data Ingénieur.
Je vais vous présenter le projet E6 qui consiste à adapter un Data Warehouse existant à un modèle Marketplace multi‑vendeurs, en respectant les contraintes de sécurité, de gouvernance et de conformité RGPD.

## Contexte & objectifs (45s)
ShopNow évolue d’un modèle e‑commerce classique vers une Marketplace.
Cela implique de nouveaux enjeux : cloisonnement des données, qualité des flux, historisation et conformité réglementaire.
L’objectif est de rendre le DWH scalable, sécurisé et maintenable.

## Architecture globale (60s)
Les données sont ingérées en temps réel via Azure Event Hubs.
Azure Stream Analytics transforme les flux avant chargement dans Azure SQL DWH.
L’ensemble est supervisé via Log Analytics avec alertes et tableaux de bord.
L’architecture est modulaire et automatisée via Terraform.

## Sécurité & RGPD (75s)
Le cloisonnement repose sur la Row‑Level Security basée sur le seller_id.
Chaque vendeur n’accède qu’à ses données.
Côté RGPD, nous appliquons minimisation, rétention limitée et droit à l’oubli par anonymisation.

## Gestion des évolutions – SCD (60s)
Les dimensions critiques sont gérées en SCD Type 2.
Cela permet d’historiser les changements tout en conservant la cohérence analytique.
Les tables de faits pointent vers la version active via des clés de substitution.

## Monitoring & sauvegardes (60s)
Le monitoring repose sur Log Analytics, alertes et workbooks.
Les sauvegardes Azure SQL sont automatiques via PITR et LTR.
La plateforme est résiliente et supervisée.

## Conclusion (30s)
Cette architecture répond aux besoins Marketplace actuels tout en anticipant les évolutions futures.
Elle combine performance, sécurité et conformité.
