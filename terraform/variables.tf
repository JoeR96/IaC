variable "rds_username" {
  description = "RDS instance master username"
  default     = ""
}

variable "rds_password" {
  description = "RDS instance master password"
  default     = ""
  sensitive   = true
}

variable "cognito_auth_api_image" {
  description = "The URL of the ECR repository containing the cognito-auth-api image"
  type        = string
}
