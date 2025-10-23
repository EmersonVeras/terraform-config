locals {
  # Note: Cloud Scheduler is not available in all regions.
  #       See also: https://cloud.google.com/about/locations#europe
  supported_regions = [
    "europe-west1",
    "europe-west2",
    "europe-west3",
    # "europe-west4",
    "europe-west6",
    # "europe-north1",
    "europe-central2",
    # "europe-west8",
    # "europe-southwest1",
    # "europe-west9",
    # "europe-west10",
    # "europe-west12",
    "us-west1",
    "us-west2",
    "us-west3",
    "us-west4",
    "us-central1",
    "us-east1",
    "us-east4",
    # "us-east5",
    # "us-south1",
    "northamerica-northeast1",
    # "northamerica-northeast2",
    # "southamerica-west1",
    "southamerica-east1",
    "asia-south1",
    # "asia-south2",
    "asia-southeast1",
    "asia-southeast2",
    "asia-east2",
    "asia-east1",
    "asia-northeast1",
    "asia-northeast2",
    "asia-northeast3",
    "australia-southeast1",
    # "australia-southeast2",
    # Note: None of the middle eastern regions support Cloud Scheduler
    # "me-west1",
    # "me-central1",
    # "me-central2",
    # Note: None of the africa regions support Cloud Scheduler
    # "africa-south1",
  ]
  resulting_region = contains(local.supported_regions, var.location) ? var.location : try(
    element([
      for region in local.supported_regions : region if startswith(region, replace(var.location, "/-.*$/", ""))
    ], 0),
    # If we hit a region that is not supported, default to europe-west1
    element(local.supported_regions, 0)
  )
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = var.project_id
  location       = var.location
  cloud_function = var.function_name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.service_account_email}"
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.location
  service  = var.function_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account_email}"
}

resource "random_id" "this" {
  for_each = toset(var.schedules)

  prefix      = "${var.function_name}-"
  byte_length = 2
}

resource "google_cloud_scheduler_job" "this" {
  for_each = toset(var.schedules)

  name        = random_id.this[each.key].hex
  description = "Scheduled trigger for Cloud Function ${var.function_name}"
  schedule    = each.value
  project     = var.project_id
  region      = local.resulting_region

  http_target {
    uri         = var.function_uri
    http_method = "POST"
    oidc_token {
      audience              = "${var.function_uri}/"
      service_account_email = var.service_account_email
    }
  }
}

