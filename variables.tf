# variable "impersonate_service_account" {
#   description = "The service account for Terraform."
#   type        = string
#   default     = "terraform@lucas-sandbox-lywd4.iam.gserviceaccount.com"
# }

variable "project_id" {
  description = "The project ID."
  type        = string
  default     = "deon-sandbox-lc7j4"
}

variable "region" {
  description = "The region."
  type        = string
  default     = "europe-west2"
}

variable "zone" {
  description = "The zone."
  type        = string
  default     = "europe-west2-a"
}

