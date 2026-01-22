-- RGPD setup: registre des traitements + audit + procedures

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rgpd')
    EXEC('CREATE SCHEMA rgpd');
GO

IF OBJECT_ID('rgpd.processing_register', 'U') IS NULL
BEGIN
    CREATE TABLE rgpd.processing_register (
        processing_id      INT IDENTITY(1,1) PRIMARY KEY,
        processing_name    NVARCHAR(200) NOT NULL UNIQUE,
        purpose            NVARCHAR(500) NULL,
        data_categories    NVARCHAR(500) NULL,
        data_subjects      NVARCHAR(200) NULL,
        legal_basis        NVARCHAR(200) NULL,
        retention_policy   NVARCHAR(200) NULL,
        system_component   NVARCHAR(200) NULL,
        owner              NVARCHAR(200) NULL,
        last_reviewed_at   DATETIME2 NULL,
        notes              NVARCHAR(1000) NULL
    );
END;
GO

IF OBJECT_ID('rgpd.audit_log', 'U') IS NULL
BEGIN
    CREATE TABLE rgpd.audit_log (
        audit_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
        action     NVARCHAR(100) NOT NULL,
        subject_id NVARCHAR(100) NULL,
        details    NVARCHAR(1000) NULL,
        action_at  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM rgpd.processing_register WHERE processing_name = 'Marketplace DWH analytics')
BEGIN
    INSERT INTO rgpd.processing_register (
        processing_name,
        purpose,
        data_categories,
        data_subjects,
        legal_basis,
        retention_policy,
        system_component,
        owner,
        last_reviewed_at,
        notes
    )
    VALUES (
        'Marketplace DWH analytics',
        'Reporting ventes multi-vendeurs et pilotage',
        'orders, products, sellers, clickstream',
        'customers, sellers',
        'Legitimate interest',
        'PITR/LTR SQL + purge clickstream planifiee',
        'Azure SQL DWH',
        'Data team',
        SYSUTCDATETIME(),
        'Acces vendeur filtre par RLS sur seller_id'
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM rgpd.processing_register WHERE processing_name = 'Clickstream purge')
BEGIN
    INSERT INTO rgpd.processing_register (
        processing_name,
        purpose,
        data_categories,
        data_subjects,
        legal_basis,
        retention_policy,
        system_component,
        owner,
        last_reviewed_at,
        notes
    )
    VALUES (
        'Clickstream purge',
        'Respect de la retention des donnees de navigation',
        'clickstream',
        'customers',
        'Legal obligation',
        'Suppression automatique des donnees au-dela de la retention',
        'Azure SQL DWH',
        'Data team',
        SYSUTCDATETIME(),
        'Execution planifiee via Azure Automation'
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM rgpd.processing_register WHERE processing_name = 'Customer anonymization')
BEGIN
    INSERT INTO rgpd.processing_register (
        processing_name,
        purpose,
        data_categories,
        data_subjects,
        legal_basis,
        retention_policy,
        system_component,
        owner,
        last_reviewed_at,
        notes
    )
    VALUES (
        'Customer anonymization',
        'Droit a l''oubli et anonymisation des donnees personnelles',
        'customer PII',
        'customers',
        'Legal obligation',
        'Anonymisation sur demande',
        'Azure SQL DWH',
        'Data team',
        SYSUTCDATETIME(),
        'Audit des actions RGPD dans rgpd.audit_log'
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_forget_customer
  @customer_id VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    IF NOT EXISTS (SELECT 1 FROM dbo.dim_customer WHERE customer_id = 'ANON')
    BEGIN
      INSERT INTO dbo.dim_customer(customer_id, name, email, address, city, country)
      VALUES ('ANON', 'ANONYMIZED', NULL, NULL, NULL, NULL);
    END;

    UPDATE dbo.fact_order
    SET customer_id = 'ANON'
    WHERE customer_id = @customer_id;

    UPDATE dbo.dim_customer
    SET
      name    = 'ANONYMIZED',
      email   = NULL,
      address = NULL,
      city    = NULL,
      country = NULL
    WHERE customer_id = @customer_id;

    INSERT INTO rgpd.audit_log (action, subject_id, details)
    VALUES ('FORGET_CUSTOMER', @customer_id, 'Anonymisation client + facts reassigned to ANON');

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_purge_obsolete_data
  @clickstream_retention_days INT = 90
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @cutoff DATETIME = DATEADD(day, -@clickstream_retention_days, SYSUTCDATETIME());

  DELETE FROM dbo.fact_clickstream
  WHERE event_timestamp < @cutoff;

  DECLARE @deleted INT = @@ROWCOUNT;

  INSERT INTO rgpd.audit_log (action, subject_id, details)
  VALUES (
    'PURGE_CLICKSTREAM',
    NULL,
    CONCAT('Deleted ', @deleted, ' rows older than ', CONVERT(VARCHAR(19), @cutoff, 120))
  );
END;
GO
