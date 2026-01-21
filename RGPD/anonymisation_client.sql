-- Creation d un client ANON
IF NOT EXISTS (SELECT 1 FROM dbo.dim_customer WHERE customer_id = 'ANON')
BEGIN
  INSERT INTO dbo.dim_customer(customer_id, name, email, address, city, country)
  VALUES ('ANON', 'ANONYMIZED', NULL, NULL, NULL, NULL);
END;
GO

-- Creation de la procedure pour anonymiser un client
CREATE OR ALTER PROCEDURE dbo.sp_forget_customer
  @customer_id VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    -- 1) Remplacer le customer_id dans les faits (on garde les ventes)
    UPDATE dbo.fact_order
    SET customer_id = 'ANON'
    WHERE customer_id = @customer_id;

    -- 2) Anonymiser la dimension client
    UPDATE dbo.dim_customer
    SET
      name    = 'ANONYMIZED',
      email   = NULL,
      address = NULL,
      city    = NULL,
      country = NULL
    WHERE customer_id = @customer_id;

    -- Optionnel : si tu avais une table d'audit RGPD
    -- INSERT INTO dbo.rgpd_audit(customer_id, action, action_date)
    -- VALUES (@customer_id, 'FORGET', SYSUTCDATETIME());

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO

-- Commande pour lancer la procedure d anonymisation
EXEC dbo.sp_forget_customer @customer_id = 'uuid_du_client_a_anonymiser';
