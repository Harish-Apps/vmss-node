output "sql_server_fqdn" {
  value = module.sql.server_fqdn
}

output "sql_database_name" {
  value = module.sql.database_name
}

output "private_endpoint_ip" {
  value = module.network.private_endpoint_ip
}
