output "bucket_name" {
  value = local.bucket_name
}

output "object_name" {
  value = google_storage_bucket_object.this.name
}

