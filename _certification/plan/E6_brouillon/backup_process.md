sequenceDiagram
    participant Admin as Admin/Exploitant
    participant AzurePortal as Azure Portal / CLI
    participant SQL as Azure SQL (serveur)
    participant NewDB as dwh-shopnow-restore

    Admin->>AzurePortal: Choisit un point PITR<br/>et lance une restauration
    AzurePortal->>SQL: az sql db restore<br/>--dest-name dwh-shopnow-restore
    SQL-->>NewDB: Crée la nouvelle base restaurée

    Admin->>AzurePortal: Confirme que la base restaurée est OK
    Admin->>AzurePortal: Supprime l’ancienne dwh-shopnow
    AzurePortal->>SQL: az sql db delete dwh-shopnow

    Admin->>AzurePortal: Renomme dwh-shopnow-restore -> dwh-shopnow
    AzurePortal->>SQL: az sql db rename<br/>dwh-shopnow-restore → dwh-shopnow
