# Questions probables du jury – Projet E6

## Pourquoi avoir choisi une architecture streaming ?
Le streaming permet une ingestion quasi temps réel, une meilleure réactivité métier et une architecture plus adaptée aux flux Marketplace hétérogènes.

## Comment garantissez‑vous le cloisonnement des vendeurs ?
Grâce à la Row‑Level Security au niveau SQL, basée sur le seller_id et le contexte utilisateur.

## Comment gérez‑vous le RGPD et le droit à l’oubli ?
Les données sont anonymisées ou supprimées selon les règles métier, sans casser l’historique analytique.

## Pourquoi utiliser les SCD Type 2 ?
Ils permettent de conserver l’historique des changements et d’assurer des analyses temporelles fiables.

## Que se passe‑t‑il en cas d’incident majeur ?
La base peut être restaurée via PITR ou LTR Azure SQL, avec des procédures documentées.

## Quelles améliorations possibles ?
Ajout de Data Factory, tests qualité automatisés, chiffrement avancé, self‑service BI.
