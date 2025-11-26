flowchart LR
    subgraph Producers["Event Producers (Container)"]
        APP["Container aeh-producers<br/>Python + Faker<br/>producers.py"]
    end

    subgraph EH["Azure Event Hubs"]
        EH_ORDERS["Event Hub<br/>orders"]
        EH_CLICK["Event Hub<br/>clickstream"]
    end

    subgraph ASA["Azure Stream Analytics Job<br/>asa-shopnow"]
        ASA_IN_ORDERS["Input<br/>InputOrders"]
        ASA_IN_CLICK["Input<br/>InputClickstream"]
        ASA_QUERY["transformation_query<br/>(JOIN, CROSS APPLY,<br/>GetArrayElements)"]
        ASA_OUT_FACT_ORDER["Output<br/>OutputFactOrder"]
        ASA_OUT_DIM_CUST["Output<br/>OutputDimCustomer"]
        ASA_OUT_DIM_PROD["Output<br/>OutputDimProduct"]
        ASA_OUT_DIM_SELLER["Output<br/>OutputDimSeller"]
        ASA_OUT_FACT_CLICK["Output<br/>OutputFactClickstream"]
    end

    subgraph SQL["Azure SQL Database<br/>dwh-shopnow"]
        DIM_CUST["dim_customer"]
        DIM_PROD["dim_product"]
        DIM_SELLER["dim_seller"]
        FACT_ORDER["fact_order"]
        FACT_CLICK["fact_clickstream"]
    end

    subgraph BACKUP["Sauvegardes Azure SQL"]
        PITR["PITR<br/>14 jours"]
        LTR["LTR<br/>Weekly: 4 semaines<br/>Monthly: 12 mois<br/>Yearly: 10 ans"]
    end

    %% Flux producteurs -> Event Hubs
    APP -->|JSON orders| EH_ORDERS
    APP -->|JSON clickstream| EH_CLICK

    %% Event Hubs -> ASA Inputs
    EH_ORDERS --> ASA_IN_ORDERS
    EH_CLICK --> ASA_IN_CLICK

    %% Inputs -> Query
    ASA_IN_ORDERS --> ASA_QUERY
    ASA_IN_CLICK --> ASA_QUERY

    %% Query -> Outputs vers SQL
    ASA_QUERY --> ASA_OUT_FACT_ORDER
    ASA_QUERY --> ASA_OUT_DIM_CUST
    ASA_QUERY --> ASA_OUT_DIM_PROD
    ASA_QUERY --> ASA_OUT_DIM_SELLER
    ASA_QUERY --> ASA_OUT_FACT_CLICK

    %% Outputs -> Tables DWH
    ASA_OUT_DIM_CUST --> DIM_CUST
    ASA_OUT_DIM_PROD --> DIM_PROD
    ASA_OUT_DIM_SELLER --> DIM_SELLER
    ASA_OUT_FACT_ORDER --> FACT_ORDER
    ASA_OUT_FACT_CLICK --> FACT_CLICK

    %% Backups liés à la base SQL
    SQL --> PITR
    SQL --> LTR

    classDef producers fill:#0ea5e9,stroke:#0369a1,stroke-width:1,color:#fff;
    classDef eventhub fill:#f97316,stroke:#c2410c,stroke-width:1,color:#111827;
    classDef asa fill:#22c55e,stroke:#15803d,stroke-width:1,color:#022c22;
    classDef sql fill:#6366f1,stroke:#4f46e5,stroke-width:1,color:#eef2ff;
    classDef backup fill:#e5e7eb,stroke:#6b7280,stroke-width:1,color:#111827;

    class Producers producers;
    class EH eventhub;
    class ASA asa;
    class SQL sql;
    class BACKUP backup;
