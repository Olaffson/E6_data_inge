-- ==========================================
-- Sécurité Marketplace : cloisonnement vendeur
-- Row-Level Security (RLS) basé sur seller_id
-- ==========================================

-- 1) Schéma dédié
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'security')
    EXEC('CREATE SCHEMA security');
GO

-- 2) Table de mapping : login SQL -> seller_id
IF OBJECT_ID('security.user_seller', 'U') IS NULL
BEGIN
    CREATE TABLE security.user_seller (
        principal_name SYSNAME NOT NULL,   -- ex: 'seller_123' ou un email
        seller_id      VARCHAR(50) NOT NULL,
        is_active      BIT NOT NULL DEFAULT 1,
        CONSTRAINT pk_user_seller PRIMARY KEY (principal_name, seller_id)
    );
END
GO

-- 3) Fonction de prédicat RLS
CREATE OR ALTER FUNCTION security.fn_rls_seller(@seller_id VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_access
    WHERE
        IS_MEMBER('dwh_admin') = 1
        OR IS_MEMBER('internal_analyst') = 1
        OR EXISTS (
            SELECT 1
            FROM security.user_seller us
            WHERE us.principal_name = USER_NAME()
              AND us.seller_id = @seller_id
              AND us.is_active = 1
        )
);
GO

-- 4) Security policy appliquée aux tables contenant seller_id
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'seller_rls_policy')
    DROP SECURITY POLICY security.seller_rls_policy;
GO

CREATE SECURITY POLICY security.seller_rls_policy
ADD FILTER PREDICATE security.fn_rls_seller(seller_id) ON dbo.dim_seller,
ADD FILTER PREDICATE security.fn_rls_seller(seller_id) ON dbo.dim_product,
ADD FILTER PREDICATE security.fn_rls_seller(seller_id) ON dbo.fact_order,
ADD FILTER PREDICATE security.fn_rls_seller(seller_id) ON dbo.fact_clickstream
WITH (STATE = ON);
GO

-- 5) Rôles
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'dwh_admin')
    CREATE ROLE dwh_admin;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'internal_analyst')
    CREATE ROLE internal_analyst;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'seller_role')
    CREATE ROLE seller_role;
GO

-- 6) Permissions
GRANT CONTROL ON DATABASE::[dwh-shopnow] TO dwh_admin;
GO

GRANT SELECT ON dbo.fact_order TO internal_analyst;
GRANT SELECT ON dbo.fact_clickstream TO internal_analyst;
GRANT SELECT ON dbo.dim_product TO internal_analyst;
GRANT SELECT ON dbo.dim_seller TO internal_analyst;
GO

GRANT SELECT ON dbo.fact_order TO seller_role;
GRANT SELECT ON dbo.fact_clickstream TO seller_role;
GRANT SELECT ON dbo.dim_product TO seller_role;
GRANT SELECT ON dbo.dim_seller TO seller_role;
GO
