flowchart TB
    subgraph AzureSQL[Azure SQL DWH]
        Fact[fact_order / fact_clickstream]
        DimSeller[dim_seller]
        DimProduct[dim_product]
        DimCustomer[dim_customer]
    end

    subgraph Security
        RLSFn[Fonction RLS fn_rls_seller]
        Mapping[user_seller mapping]
    end

    SellerA[Vendeur A]
    SellerB[Vendeur B]
    Analyst[Analyste interne]

    SellerA -->|SELECT| Fact
    SellerB -->|SELECT| Fact
    Analyst -->|SELECT| Fact

    Fact --> RLSFn
    RLSFn --> Mapping

    RLSFn -->|seller_id=A| SellerA
    RLSFn -->|seller_id=B| SellerB
    RLSFn -->|Bypass| Analyst
