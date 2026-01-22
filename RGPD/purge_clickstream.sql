-- Procedure creee dans RGPD/rgpd_setup.sql
-- Lancement manuel si besoin :
EXEC dbo.sp_purge_obsolete_data @clickstream_retention_days = 90;
