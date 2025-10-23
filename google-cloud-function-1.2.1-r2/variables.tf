variable "project_id" {}

variable "location" {
  default = "europe-west4"
}

variable "name" {}

variable "random_suffix" {
  description = "Wether a random id will be appended to the function name."
  type = bool
  default  = true
  nullable = false
}

variable "description" {
  type    = string
  default = null
}

variable "runtime" {
  default  = "python38"
  nullable = false
}

variable "entry_point" {
  default  = "handler"
  nullable = false
}

variable "event_trigger" {
  type = object({
    # one of: http, schedule, pubsub, storage_object/finalized, storage_object/archived, storage_object/deleted, storage_object/metadata_updated
    event_type = string
    # schedule
    schedules = optional(set(string), null)
    # pubsub
    create_topic = optional(bool, true)
    pubsub_topic = optional(string, null)
    # storage_object_finalization
    bucket_name             = optional(string, null)
    bucket_grant_read_only  = optional(bool, false)
    bucket_grant_read_write = optional(bool, true)
    # pubsub + storage_object_finalization
    retry_on_failure = optional(bool, false)
  })
  default = {
    event_type = "http"
  }
  nullable = false
}

variable "create_trigger_service_account" {
  type     = bool
  default  = true
  nullable = false
}

variable "public" {
  type     = bool
  default  = false
  nullable = false
}

variable "invoker_iam_members" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "min_instance_count" {
  type     = number
  default  = 0
  nullable = false
}

variable "max_instance_count" {
  type     = number
  default  = 1
  nullable = false
}

variable "max_instance_request_concurrency" {
  type     = number
  default  = 1
  nullable = false
}

variable "cpu_limit" {
  type     = number
  default  = 1
  nullable = false
}

variable "memory_limit" {
  default  = "256Mi"
  nullable = false
}

variable "timeout_seconds" {
  type     = number
  default  = 60
  nullable = false
}

variable "source_bucket" {}

variable "source_object_name" {}

variable "source_object_generation" {
  default = null
}

variable "build_env" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "function_env" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "function_secret_env" {
  type = map(
    object({
      secret_project_id = optional(string)
      secret_id         = string
      secret_version    = optional(string, "latest")
    })
  )
  default  = {}
  nullable = false
}

variable "function_generated_secret_env" {
  description = "Map of environment variables generated from a random or rotation controlled secret managed externally"
  type = map(object({
    keeper           = optional(string, "")
    length           = optional(number, 32)
    special          = optional(bool, true)
    override_special = optional(string)
    numeric          = optional(bool, true)
    lower            = optional(bool, true)
    upper            = optional(bool, true)
  }))
  default  = {}
  nullable = false
}

variable "service_account_email" {
  description = "Email of the service account to use as an identity for the cloud function."
  default  = null
}

variable "create_service_account" {
  description = "Email of the service account to create and use as an identity for the cloud function."
  type = bool
  default  = true
  nullable = false
}

variable "vpc_connector" {
  type        = string
  default     = null
  description = "The VPC Access Connector name to route traffic through VPC network. Format: projects/PROJECT/locations/REGION/connectors/CONNECTOR_NAME or just CONNECTOR_NAME"
}

variable "vpc_connector_egress_settings" {
  type        = string
  default     = null
  description = "Controls what traffic is routed through VPC. Options: ALL_TRAFFIC or PRIVATE_RANGES_ONLY"
  
  validation {
    condition = var.vpc_connector_egress_settings == null ? true : contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_connector_egress_settings)
    error_message = "vpc_connector_egress_settings must be either ALL_TRAFFIC or PRIVATE_RANGES_ONLY"
  }
}