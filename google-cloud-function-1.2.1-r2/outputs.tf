output "project_id" {
  value = google_cloudfunctions2_function.this.project
}

output "service_account_email" {
  value = local.service_account_email
}

output "service_account_id" {
  value = local.service_account_id
}

output "trigger_service_account_email" {
  value = local.resulting_trigger_service_account_email
}

output "trigger_service_account_id" {
  value = local.resulting_trigger_service_account_id
}

output "name" {
  value = google_cloudfunctions2_function.this.name
}

output "uri" {
  value = local.function_uri
}

output "location" {
  value = google_cloudfunctions2_function.this.location
}

output "event_trigger" {
  value = {
    trigger_type = var.event_trigger.event_type
    pubsub_topic = try(google_pubsub_topic.this["one"], null)
    bucket_name = var.event_trigger.bucket_name
  }
}

output "vpc_connector" {
  value       = google_cloudfunctions2_function.this.service_config[0].vpc_connector
  description = "The VPC connector being used"
}

output "vpc_connector_egress_settings" {
  value       = google_cloudfunctions2_function.this.service_config[0].vpc_connector_egress_settings
  description = "The VPC egress settings"
}