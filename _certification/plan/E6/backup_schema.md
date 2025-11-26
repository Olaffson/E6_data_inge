flowchart LR
    subgraph Terraform["Terraform – Infrastructure as Code"]
        TF_SQL["Module sql_database<br/>short_term_retention_policy<br/>long_term_retention_policy"]
    end

    subgraph AzureSQL["Azure SQL – dwh-shopnow"]
        DWH["Base DWH<br/>dwh-shopnow"]
    end

    subgraph Backups["Sauvegardes Azure SQL"]
        PITR["PITR<br/>Rétention 14 jours"]
        LTR["LTR<br/>Weekly: 4 semaines<br/>Monthly: 12 mois<br/>Yearly: 10 ans"]
    end

    subgraph RestoreProcess["Processus de restauration"]
        NewDB["Nouvelle base restaurée<br/>ex: dwh-shopnow-restore"]
        OldDB["Ancienne base<br/>dwh-shopnow (corrompue)"]
        RenamedDB["Base renommée<br/>dwh-shopnow (restaurée)"]
    end

    TF_SQL -->|Configure les politiques<br/>PITR + LTR| AzureSQL
    AzureSQL -->|Génère automatiquement<br/>backups| Backups
    Backups -->|Choix d'un point dans le temps<br/>PITR ou LTR| NewDB

    NewDB -->|Suppression| OldDB
    NewDB -->|Rename -> dwh-shopnow| RenamedDB

    classDef main fill:#2563eb,stroke:#1e40af,stroke-width:1,color:#fff;
    classDef sec fill:#e5e7eb,stroke:#9ca3af,stroke-width:1,color:#111827;
    classDef process fill:#10b981,stroke:#047857,stroke-width:1,color:#022c22;

    class Terraform main;
    class AzureSQL main;
    class Backups sec;
    class RestoreProcess process;


