variable "project_id" {}

variable "function_location" {
  type    = string
  default = null
}

variable "function_name" {
  type    = string
  default = null
}

variable "invoker_iam_member_map" {
  type     = map(string)
  default  = {}
  nullable = false
}
