-- Purge des données de clickstream au-delà de X jours (souvent 90/180 jours)
-- Pour les commandes, attention : souvent conservation légale plus longue (ex 5 ans). Donc on ne purge pas fact_order sans validation métier

-- Creation de la procedure de purge
CREATE OR ALTER PROCEDURE dbo.sp_purge_obsolete_data
  @clickstream_retention_days INT = 90
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @cutoff DATETIME = DATEADD(day, -@clickstream_retention_days, SYSUTCDATETIME());

  -- Purge clickstream ancien
  DELETE FROM dbo.fact_clickstream
  WHERE event_timestamp < @cutoff;

  -- Optionnel : purge d'autres tables “techniques” si tu en as
  -- DELETE FROM dbo.stg_seller_raw WHERE ingest_timestamp < DATEADD(day, -30, SYSUTCDATETIME());
END;
GO

-- Commande pour lancer la procedure
EXEC dbo.sp_purge_obsolete_data @clickstream_retention_days = 90;
