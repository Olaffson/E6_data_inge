-- Procedure creee dans RGPD/rgpd_setup.sql
-- Exemple d'execution :
EXEC dbo.sp_forget_customer @customer_id = 'uuid_du_client_a_anonymiser';
