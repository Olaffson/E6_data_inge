# Étape 4 – Journalisation, supervision et alertes (C16)

## 4.1 Journalisation

L’objectif de la journalisation est de disposer d’une **traçabilité technique et fonctionnelle** de bout en bout sur la chaîne :

> Event producers → Event Hubs → Stream Analytics → Azure SQL DWH

### 4.1.1 Cible : centraliser les logs

Tous les logs sont centralisés dans un **Azure Log Analytics Workspace**, via les **Diagnostic Settings** :

- **Event Hubs**  
  - Logs : erreurs de consommation, quota, throttling  
  - Metrics : nombre de messages, latence, taille, etc.

- **Stream Analytics (asa-shopnow)**  
  - Logs : erreurs de requête, erreurs d’output, restart du job  
  - Metrics : nombre d’events traités, throughput, backlog

- **Azure SQL (dwh-shopnow)**  
  - Logs : erreurs SQL, deadlocks, timeouts  
  - Metrics : CPU/DTU, taille, connexions, I/O

- **Conteneur aeh-producers**  
  - Logs applicatifs (stdout / stderr) via Container Instances / Container Apps

### 4.1.2 Logs techniques vs logs fonctionnels

- **Logs techniques**
  - erreurs Event Hub (send/receive),
  - erreurs ASA (outputs, parsing),
  - erreurs SQL (timeouts, connexion).

- **Logs fonctionnels**
  - anomalies dans les données (`seller_id` manquant),
  - incohérences produit/vendeur,
  - contrôles de qualité sur le DWH.

### 4.1.3 Structure des logs (convention)

Format recommandé pour les logs applicatifs :

```json
{
  "timestamp": "2025-11-26T09:15:23Z",
  "source": "producer",
  "type": "TECH",
  "level": "ERROR",
  "message": "Failed to send order event",
  "error_code": "EH_SEND_FAIL",
  "seller_id": "f5b0e8d3-...",
  "order_id": "a3b1c2d4-..."
}
```

Champs standard :

- `timestamp`,  
- `source`,  
- `type` (TECH/FUNC),  
- `level` (INFO/WARN/ERROR),  
- `message`,  
- `error_code`,  
- `seller_id` (si applicable).

---

## 4.2 Catégorisation des logs

### 4.2.1 Niveaux de sévérité

- **INFO** : fonctionnement normal  
- **WARNING** : anomalie non bloquante  
- **ERROR** : incident critique / perte potentielle de données

### 4.2.2 Typologie par domaine

- **Sécurité** : connexions SQL échouées, rôle modifié  
- **Qualité** : anomalies dans les données, incohérences  
- **Exploitation** : erreurs ASA, backlog Event Hub, crash du container producers

---

## 4.3 Alertes automatiques

Les alertes reposent sur **Azure Monitor** et Log Analytics.

### 4.3.1 Cas d’alerte principaux

1. **Échec du job Stream Analytics**
   - ASA passe en `Failed` ou `Stopped`
   - Envoi e-mail + notification Teams

2. **Anomalies vendeur**
   - taux d’erreurs pour un vendeur > seuil
   - données invalides dans `fact_order`

3. **SLA DWH non respecté**
   - latence entre Event Hub et DWH > 5 min

4. **Anomalies Event Hub**
   - 0 messages reçus pendant 10 minutes
   - backlog anormalement élevé

### 4.3.2 Canaux d’alerte

- E-mail (default)
- Teams (critique)
- SMS (optionnel / production)

---

## 4.4 Tableau de bord de supervision

### 4.4.1 Indicateurs techniques

- **Taux de succès ETL**
- **Statut ASA** (Running / Failed)
- **Latence DWH**
- **Santé SQL** : CPU, DTU, connexions

### 4.4.2 Indicateurs fonctionnels

- Volume par vendeur  
- Taux d’erreurs vendeur  
- Qualité des données (`seller_id` null, `unit_price` incohérent)

### 4.4.3 Outils possibles

- **Azure Dashboard** (temps réel)
- **Log Analytics Workbooks** (KQL visuel)
- **Power BI** (préconisation cible)

---

## Conclusion

Cette étape met en place les fondations d’une supervision complète et alignée avec les attentes de la compétence C16 : visibilité, réactivité, maîtrise de la qualité et de la sécurité du système.
