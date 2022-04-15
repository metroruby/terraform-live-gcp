# Enable required account services
module "gcp_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = ">=12.0.0"

  project_id                  = var.project_id

  disable_services_on_destroy = false
  disable_dependent_services  = false

  activate_apis = [
    "sqladmin.googleapis.com",
  ]
}

# Generate a random user name
resource "random_password" "user_name" {
  length  = 16
  special = false
}

# Create the Postgres instance
module "db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = ">=10.0.1"

  project_id = module.gcp_services.project_id

  name             = "${var.cloud_sql_name}-pg"
  user_name        = random_password.user_name.result
  database_version = "POSTGRES_12"

  zone      = var.zone
  region    = var.region
  disk_size = var.disk_size
  tier      = var.tier

  create_timeout = "30m"
  delete_timeout = "30m"
  update_timeout = "30m"

  backup_configuration = {
    enabled                         = var.enable_backups
    start_time                      = "00:00"
    location                        = null
    point_in_time_recovery_enabled  = false
    transaction_log_retention_days  = null
    retained_backups                = null
    retention_unit                  = null
  }

  ip_configuration = {
    authorized_networks = var.authorized_networks
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
    allocated_ip_range  = null
  }
}