flowchart LR
    subgraph Ingestion
        Staging[Données entrantes]
    end

    subgraph Dimensions
        DimSCD[Dimension SCD2]
    end

    subgraph Facts
        FactTable[Tables de faits]
    end

    Staging -->|Comparaison| DimSCD
    DimSCD -->|UPDATE valid_to| DimSCD
    DimSCD -->|INSERT nouvelle version| DimSCD

    DimSCD -->|surrogate_key| FactTable
