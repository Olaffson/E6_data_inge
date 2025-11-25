-- Create Tables for ShopNow DWH (Marketplace-ready)

-- On supprime d'abord les tables dans l'ordre des dépendances
DROP TABLE IF EXISTS fact_clickstream;
DROP TABLE IF EXISTS fact_order;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_seller;
DROP TABLE IF EXISTS dim_customer;

----------------------------------------
-- 1. dim_customer (inchangée)
----------------------------------------
CREATE TABLE dim_customer (
    customer_id VARCHAR(50) PRIMARY KEY,
    name        NVARCHAR(255),
    email       NVARCHAR(255),
    address     NVARCHAR(500),
    city        NVARCHAR(100),
    country     NVARCHAR(100)
);

----------------------------------------
-- 2. dim_seller (NOUVELLE TABLE)
----------------------------------------
CREATE TABLE dim_seller (
    seller_id    VARCHAR(50) PRIMARY KEY,
    name         NVARCHAR(255),
    country      NVARCHAR(100),
    category     NVARCHAR(100),
    status       NVARCHAR(50),
    created_at   DATETIME,
    updated_at   DATETIME
);

----------------------------------------
-- 3. dim_product (lien vers le vendeur)
----------------------------------------
CREATE TABLE dim_product (
    product_id VARCHAR(50) PRIMARY KEY,
    name       NVARCHAR(255),
    category   NVARCHAR(100),
    seller_id  VARCHAR(50) NOT NULL,
    -- optionnel : certains DWH stockent aussi un prix de référence
    -- price      DECIMAL(18, 2),

    CONSTRAINT fk_product_seller
        FOREIGN KEY (seller_id) REFERENCES dim_seller(seller_id)
);

----------------------------------------
-- 4. fact_order (ajout seller_id)
----------------------------------------
CREATE TABLE fact_order (
    order_id        VARCHAR(50),
    product_id      VARCHAR(50),
    customer_id     VARCHAR(50),
    seller_id       VARCHAR(50),
    quantity        INT,
    unit_price      DECIMAL(18, 2),
    status          NVARCHAR(50),
    order_timestamp DATETIME,

    -- Clés étrangères (optionnel selon ton moteur)
    CONSTRAINT fk_fact_order_product
        FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    CONSTRAINT fk_fact_order_customer
        FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT fk_fact_order_seller
        FOREIGN KEY (seller_id) REFERENCES dim_seller(seller_id)
);

----------------------------------------
-- 5. fact_clickstream (seller_id optionnel)
----------------------------------------
CREATE TABLE fact_clickstream (
    event_id        VARCHAR(50) PRIMARY KEY,
    session_id      VARCHAR(50),
    user_id         VARCHAR(50),
    url             NVARCHAR(MAX),
    event_type      NVARCHAR(50),
    event_timestamp DATETIME,
    seller_id       VARCHAR(50) NULL,

    CONSTRAINT fk_fact_clickstream_seller
        FOREIGN KEY (seller_id) REFERENCES dim_seller(seller_id)
);
