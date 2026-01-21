-- Create Tables for ShopNow DWH (Marketplace-ready)

-- On supprime d'abord les tables dans l'ordre des dependances
DROP TABLE IF EXISTS fact_clickstream;
DROP TABLE IF EXISTS fact_order;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_seller;
DROP TABLE IF EXISTS dim_customer;

----------------------------------------
-- 1. dim_customer (SCD2)
----------------------------------------
CREATE TABLE dim_customer (
    customer_sk INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    name        NVARCHAR(255),
    email       NVARCHAR(255),
    address     NVARCHAR(500),
    city        NVARCHAR(100),
    country     NVARCHAR(100),
    valid_from  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    valid_to    DATETIME2 NOT NULL DEFAULT '9999-12-31',
    is_current  BIT NOT NULL DEFAULT 1
);

----------------------------------------
-- 2. dim_seller (SCD2)
----------------------------------------
CREATE TABLE dim_seller (
    seller_sk    INT IDENTITY(1,1) PRIMARY KEY,
    seller_id    VARCHAR(50) NOT NULL,
    name         NVARCHAR(255),
    country      NVARCHAR(100),
    category     NVARCHAR(100),
    status       NVARCHAR(50),
    created_at   DATETIME,
    updated_at   DATETIME,
    valid_from   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    valid_to     DATETIME2 NOT NULL DEFAULT '9999-12-31',
    is_current   BIT NOT NULL DEFAULT 1
);

----------------------------------------
-- 3. dim_product (SCD2)
----------------------------------------
CREATE TABLE dim_product (
    product_sk INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    name       NVARCHAR(255),
    category   NVARCHAR(100),
    seller_id  VARCHAR(50) NOT NULL,
    -- optionnel : certains DWH stockent aussi un prix de reference
    -- price      DECIMAL(18, 2),
    valid_from DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    valid_to   DATETIME2 NOT NULL DEFAULT '9999-12-31',
    is_current BIT NOT NULL DEFAULT 1
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
    order_timestamp DATETIME
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
    seller_id       VARCHAR(50) NULL
);

----------------------------------------
-- 6. Triggers SCD2 (insert-only via ETL/ASA)
----------------------------------------
GO
CREATE OR ALTER TRIGGER dbo.tr_dim_customer_scd2
ON dbo.dim_customer
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
    SET valid_to = SYSUTCDATETIME(),
        is_current = 0
    FROM dbo.dim_customer c
    INNER JOIN inserted i ON i.customer_id = c.customer_id
    WHERE c.is_current = 1
      AND (
          ISNULL(c.name, '') <> ISNULL(i.name, '')
          OR ISNULL(c.email, '') <> ISNULL(i.email, '')
          OR ISNULL(c.address, '') <> ISNULL(i.address, '')
          OR ISNULL(c.city, '') <> ISNULL(i.city, '')
          OR ISNULL(c.country, '') <> ISNULL(i.country, '')
      );

    INSERT INTO dbo.dim_customer (
        customer_id, name, email, address, city, country, valid_from, valid_to, is_current
    )
    SELECT
        i.customer_id, i.name, i.email, i.address, i.city, i.country,
        SYSUTCDATETIME(), '9999-12-31', 1
    FROM inserted i
    LEFT JOIN dbo.dim_customer c
      ON c.customer_id = i.customer_id AND c.is_current = 1
    WHERE c.customer_id IS NULL
       OR (
           ISNULL(c.name, '') <> ISNULL(i.name, '')
           OR ISNULL(c.email, '') <> ISNULL(i.email, '')
           OR ISNULL(c.address, '') <> ISNULL(i.address, '')
           OR ISNULL(c.city, '') <> ISNULL(i.city, '')
           OR ISNULL(c.country, '') <> ISNULL(i.country, '')
       );
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_dim_seller_scd2
ON dbo.dim_seller
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE s
    SET valid_to = SYSUTCDATETIME(),
        is_current = 0
    FROM dbo.dim_seller s
    INNER JOIN inserted i ON i.seller_id = s.seller_id
    WHERE s.is_current = 1
      AND (
          ISNULL(s.name, '') <> ISNULL(i.name, '')
          OR ISNULL(s.country, '') <> ISNULL(i.country, '')
          OR ISNULL(s.category, '') <> ISNULL(i.category, '')
          OR ISNULL(s.status, '') <> ISNULL(i.status, '')
      );

    INSERT INTO dbo.dim_seller (
        seller_id, name, country, category, status, created_at, updated_at,
        valid_from, valid_to, is_current
    )
    SELECT
        i.seller_id, i.name, i.country, i.category, i.status,
        i.created_at, i.updated_at, SYSUTCDATETIME(), '9999-12-31', 1
    FROM inserted i
    LEFT JOIN dbo.dim_seller s
      ON s.seller_id = i.seller_id AND s.is_current = 1
    WHERE s.seller_id IS NULL
       OR (
           ISNULL(s.name, '') <> ISNULL(i.name, '')
           OR ISNULL(s.country, '') <> ISNULL(i.country, '')
           OR ISNULL(s.category, '') <> ISNULL(i.category, '')
           OR ISNULL(s.status, '') <> ISNULL(i.status, '')
       );
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_dim_product_scd2
ON dbo.dim_product
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET valid_to = SYSUTCDATETIME(),
        is_current = 0
    FROM dbo.dim_product p
    INNER JOIN inserted i ON i.product_id = p.product_id
    WHERE p.is_current = 1
      AND (
          ISNULL(p.name, '') <> ISNULL(i.name, '')
          OR ISNULL(p.category, '') <> ISNULL(i.category, '')
          OR ISNULL(p.seller_id, '') <> ISNULL(i.seller_id, '')
      );

    INSERT INTO dbo.dim_product (
        product_id, name, category, seller_id, valid_from, valid_to, is_current
    )
    SELECT
        i.product_id, i.name, i.category, i.seller_id,
        SYSUTCDATETIME(), '9999-12-31', 1
    FROM inserted i
    LEFT JOIN dbo.dim_product p
      ON p.product_id = i.product_id AND p.is_current = 1
    WHERE p.product_id IS NULL
       OR (
           ISNULL(p.name, '') <> ISNULL(i.name, '')
           OR ISNULL(p.category, '') <> ISNULL(i.category, '')
           OR ISNULL(p.seller_id, '') <> ISNULL(i.seller_id, '')
       );
END;
GO
