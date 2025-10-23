locals {
  project_iam_map = {
    for key, member in var.invoker_iam_member_map :
    key => member if var.project_id != null && (var.function_location == null || var.function_name == null)
  }
  invoker_iam_map = {
    for key, member in var.invoker_iam_member_map :
    key => member if var.project_id != null && var.function_location != null && var.function_name != null
  }
}

resource "google_project_iam_member" "gen1" {
  for_each = local.project_iam_map

  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = each.value
}

resource "google_project_iam_member" "gen2" {
  for_each = local.project_iam_map

  project = var.project_id
  role    = "roles/run.invoker"
  member  = each.value
}

resource "google_cloudfunctions2_function_iam_member" "this" {
  for_each = local.invoker_iam_map

  project        = var.project_id
  location       = var.function_location
  cloud_function = var.function_name
  role           = "roles/cloudfunctions.invoker"
  member         = each.value
}

resource "google_cloud_run_v2_service_iam_member" "this" {
  for_each = local.invoker_iam_map

  project  = var.project_id
  location = var.function_location
  name     = var.function_name
  role     = "roles/run.invoker"
  member   = each.value
}

