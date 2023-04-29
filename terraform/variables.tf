variable "rds_username" {
  description = "RDS instance master username"
  default     = ""
  type        = string
}

variable "rds_password" {
  description = "RDS instance master password"
  default     = ""
  sensitive   = true
  type        = string
}
