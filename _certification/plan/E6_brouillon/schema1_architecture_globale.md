flowchart LR
    subgraph Sources
        Sellers[Vendeurs Marketplace]
        Users[Utilisateurs / Clients]
    end

    subgraph Ingestion
        EH[Azure Event Hubs]
    end

    subgraph Streaming
        ASA[Azure Stream Analytics]
    end

    subgraph Storage
        DWH[(Azure SQL DWH)]
    end

    subgraph Governance
        RLS[Row-Level Security]
        RGPD[RGPD / Anonymisation]
        Backup[Sauvegardes PITR & LTR]
    end

    subgraph Monitoring
        LA[Log Analytics]
        Alerts[Alertes]
        WB[Workbooks]
    end

    Sellers --> EH
    Users --> EH
    EH --> ASA
    ASA --> DWH

    DWH --> RLS
    DWH --> RGPD
    DWH --> Backup

    EH --> LA
    ASA --> LA
    DWH --> LA
    LA --> Alerts
    LA --> WB
