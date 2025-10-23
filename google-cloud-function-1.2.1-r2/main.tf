locals {
  name             = var.random_suffix ? "${var.name}-${random_id.this.hex}": var.name
  ingress_settings = var.public ? "ALLOW_ALL" : "ALLOW_INTERNAL_ONLY"
  function_uri     = google_cloudfunctions2_function.this.service_config[0].uri
  storage_object_event_mapping = {
    "storage_object/finalized"        = "google.cloud.storage.object.v1.finalized"
    "storage_object/archived"         = "google.cloud.storage.object.v1.archived"
    "storage_object/deleted"          = "google.cloud.storage.object.v1.deleted"
    "storage_object/metadata_updated" = "google.cloud.storage.object.v1.metadataUpdated"
  }
  storage_object_event_types = keys(local.storage_object_event_mapping)
  event_trigger_event_types  = flatten(["pubsub", local.storage_object_event_types])
  project_number             = data.google_project.this.number
  service_account_email      = var.create_service_account ? google_service_account.this["one"].email : var.service_account_email
  service_account_id         = data.google_service_account.this.name

  trigger_service_account_email           = var.create_trigger_service_account ? google_service_account.trigger["one"].email : null
  resulting_trigger_service_account_email = var.create_trigger_service_account ? local.trigger_service_account_email : "service-${local.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  resulting_trigger_service_account_id    = var.create_trigger_service_account ? google_service_account.trigger["one"].id : "projects/-/${local.resulting_trigger_service_account_email}"

  resulting_pubsub_topic = (var.event_trigger.event_type == "pubsub" && var.event_trigger.create_topic) ? resource.google_pubsub_topic.this["one"].id : var.event_trigger.pubsub_topic
}

data "google_project" "this" {
  project_id = var.project_id
}

resource "random_id" "this" {
  byte_length = 2
  keepers = {
    event_trigger_event_type = var.event_trigger.event_type
  }
}

resource "google_service_account" "this" {
  for_each = toset(var.create_service_account ? ["one"] : [])

  project      = var.project_id
  account_id   = local.name
  display_name = "Cloud Function SA for ${local.name}"
}

data "google_service_account" "this" {
  account_id = local.service_account_email
}

resource "google_service_account" "trigger" {
  for_each = toset(var.create_trigger_service_account ? ["one"] : [])

  project      = var.project_id
  account_id   = "trigger-${substr(var.name, 0, 30 - length("trigger-") - length("-${random_id.this.hex}"))}-${random_id.this.hex}"
  display_name = "Cloud Function Trigger for ${local.name}"
}

resource "google_project_iam_member" "trigger" {
  for_each = toset(var.create_trigger_service_account ? ["one"] : [])

  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.trigger["one"].email}"
}

resource "google_cloudfunctions2_function" "this" {
  depends_on = [
    google_project_iam_member.trigger,
  ]
  lifecycle {
    ignore_changes = [
      service_config[0].environment_variables["LOG_EXECUTION_ID"],
    ]
  }

  project     = var.project_id
  name        = local.name
  location    = var.location
  description = var.description

  build_config {
    runtime               = var.runtime
    entry_point           = var.entry_point
    environment_variables = var.build_env
    source {
      storage_source {
        bucket     = var.source_bucket
        object     = var.source_object_name
        generation = var.source_object_generation
      }
    }
  }

  service_config {
    max_instance_count               = var.max_instance_count
    min_instance_count               = var.min_instance_count
    available_memory                 = var.memory_limit
    timeout_seconds                  = var.timeout_seconds
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_cpu                    = var.cpu_limit
    vpc_connector                    = var.vpc_connector
    vpc_connector_egress_settings    = var.vpc_connector_egress_settings
    ingress_settings                 = local.ingress_settings
    all_traffic_on_latest_revision   = true
    service_account_email            = local.service_account_email
    environment_variables            = var.function_env

    dynamic "secret_environment_variables" {
      for_each = var.function_secret_env
      content {
        key        = secret_environment_variables.key
        project_id = secret_environment_variables.value.secret_project_id
        secret     = secret_environment_variables.value.secret_id
        version    = secret_environment_variables.value.secret_version
      }
    }
  }

  dynamic "event_trigger" {
    for_each = toset(var.event_trigger.event_type == "pubsub" ? ["one"] : [])
    content {
      trigger_region        = var.location
      service_account_email = local.trigger_service_account_email
      event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
      pubsub_topic          = local.resulting_pubsub_topic
      retry_policy          = var.event_trigger.retry_on_failure == null ? "RETRY_POLICY_UNSPECIFIED" : (var.event_trigger.retry_on_failure ? "RETRY_POLICY_RETRY" : "RETRY_POLICY_DO_NOT_RETRY")
    }
  }

  dynamic "event_trigger" {
    for_each = toset(contains(local.storage_object_event_types, var.event_trigger.event_type) ? ["one"] : [])
    content {
      trigger_region        = var.location
      service_account_email = local.trigger_service_account_email
      event_type            = local.storage_object_event_mapping[var.event_trigger.event_type]
      event_filters {
        attribute = "bucket"
        value     = var.event_trigger.bucket_name
      }
      retry_policy = var.event_trigger.retry_on_failure == null ? "RETRY_POLICY_UNSPECIFIED" : (var.event_trigger.retry_on_failure ? "RETRY_POLICY_RETRY" : "RETRY_POLICY_DO_NOT_RETRY")
    }
  }
}

resource "google_cloudfunctions2_function_iam_member" "trigger" {
  for_each = toset(contains(local.event_trigger_event_types, var.event_trigger.event_type) ? ["one"] : [])

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  cloud_function = google_cloudfunctions2_function.this.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${local.resulting_trigger_service_account_email}"
}

resource "google_cloud_run_v2_service_iam_member" "trigger_run_invoker" {
  for_each = toset(contains(local.event_trigger_event_types, var.event_trigger.event_type) ? ["one"] : [])

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  name           = google_cloudfunctions2_function.this.name
  role           = "roles/run.invoker"
  member         = "serviceAccount:${local.resulting_trigger_service_account_email}"
}

resource "google_secret_manager_secret_iam_member" "secret_env" {
  for_each = var.function_secret_env

  project   = each.value.secret_project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account_email}"
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  for_each = var.invoker_iam_members

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  cloud_function = google_cloudfunctions2_function.this.name
  role           = "roles/cloudfunctions.invoker"
  member         = each.value
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = var.invoker_iam_members

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  name           = google_cloudfunctions2_function.this.name
  role           = "roles/run.invoker"
  member         = each.value
}

module "scheduled_trigger" {
  source   = "./scheduled-trigger"
  for_each = toset(var.event_trigger.event_type == "schedule" ? ["one"] : [])

  project_id            = var.project_id
  location              = var.location
  function_name         = google_cloudfunctions2_function.this.name
  function_uri          = local.function_uri
  schedules             = var.event_trigger.schedules
  service_account_email = local.service_account_email
}

resource "google_pubsub_topic" "this" {
  for_each = toset(
    var.event_trigger.event_type == "pubsub" ? (
      var.event_trigger.create_topic ? ["one"] : []
    ) : []
  )

  project = var.project_id
  name    = var.event_trigger.pubsub_topic
}

resource "google_storage_bucket_iam_member" "storage_object_read" {
  for_each = toset(
    contains(local.storage_object_event_types, var.event_trigger.event_type) ? (
      var.event_trigger.bucket_grant_read_only ? ["one"] : []
    ) : []
  )

  bucket = var.event_trigger.bucket_name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${local.service_account_email}"
}

resource "google_storage_bucket_iam_member" "storage_object_read_write" {
  for_each = toset(
    contains(local.storage_object_event_types, var.event_trigger.event_type) ? (
      var.event_trigger.bucket_grant_read_write ? ["one"] : []
    ) : []
  )

  bucket = var.event_trigger.bucket_name
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${local.service_account_email}"
}

