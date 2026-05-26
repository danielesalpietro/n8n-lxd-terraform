# variables.tf
variable "container_name" { type = string }
variable "cpu_limits" { type = string }
variable "ram_limits" { type = string }
variable "storage_pool" { type = string }

variable "db_user" { type = string }
variable "db_password" { type = string, sensitive = true }
variable "n8n_user" { type = string }
variable "n8n_password" { type = string, sensitive = true }
variable "timezone" { type = string }
