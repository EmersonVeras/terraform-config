variable "project_id" {}
variable "location" {}
variable "function_name" {}
variable "function_uri" {}
variable "schedules" {
  type = set(string)
  default = []
  nullable = false
}
variable "service_account_email" {}

