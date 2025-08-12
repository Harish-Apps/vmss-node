# Azure SQL Minimal Project

Opinionated Terraform setup for a private Azure SQL Database.

## Prerequisites
- Azure CLI
- Terraform
- Permissions to create resource groups, SQL, network and Log Analytics

## Quickstart
```bash
./scripts/deploy.sh
```

## Private Access
Connect from a VM or runner within the virtual network. No public endpoint is exposed.

## Security Model
- AAD administrator configured via Terraform
- Contained AAD users managed through `sql/roles.sql`
- No SQL logins are created

## Backup and Restore
- Point in time restore enabled by default
- Toggle long term retention with `enable_ltr`
- Restore example:
  ```bash
  az sql db restore --dest-name myrestore --name <db> --server <server> --time <timestamp>
  ```

## Disaster Recovery
Auto-failover group can be enabled with `enable_failover_group`. To fail over:
```bash
az sql failover-group set-primary --name <fog> --resource-group <rg> --server <dr-sql>
```

## Monitoring
- Diagnostic settings and auditing send logs to Log Analytics
- Import alerts from `monitoring/alerts`
- Sample KQL queries in `monitoring/kql`

## Performance
Query Store and automatic tuning are enabled. Validate:
```bash
sqlcmd -S <server> -d <db> -C -i sql/query_store.sql
```

## Troubleshooting
- Private DNS resolution failing: ensure your VM uses Azure DNS and the zone is linked
- Missing AAD admin: verify `aad_admin_login` and `aad_admin_object_id` variables
