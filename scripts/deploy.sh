#!/usr/bin/env bash
set -euo pipefail

az login >/dev/null

terraform -chdir=infra/terraform init -backend-config=backend-example.hcl
terraform -chdir=infra/terraform plan -out=tfplan
terraform -chdir=infra/terraform apply -auto-approve tfplan

SQL_FQDN=$(terraform -chdir=infra/terraform output -raw sql_server_fqdn)
DB_NAME=$(terraform -chdir=infra/terraform output -raw sql_database_name)

sqlcmd -S "$SQL_FQDN" -d "$DB_NAME" -C -i sql/schema.sql
sqlcmd -S "$SQL_FQDN" -d "$DB_NAME" -C -i sql/roles.sql
sqlcmd -S "$SQL_FQDN" -d "$DB_NAME" -C -i sql/seed.sql
