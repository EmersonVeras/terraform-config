locals {
  name = var.random_suffix ? "${var.name}-${random_id.this.hex}" : var.name
  files = [for file in fileset(var.source_dir, "**"): file if !contains(var.source_excludes, file)]
  files_md5 = md5(join("", [for file in local.files : filemd5("${var.source_dir}/${file}")]))
  bucket_name = var.create_bucket ? google_storage_bucket.this["one"].name : var.bucket_name
  object_name = join("", [
    var.object_prefix,
    var.object_name != null ? var.object_name : "${filemd5(data.archive_file.this.output_path)}.zip",
  ])
}

resource "random_id" "this" {
  byte_length = 2
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.root}/.terraform/tmp/${local.files_md5}.zip"
  excludes    = var.source_excludes
}

resource "google_storage_bucket" "this" {
  for_each = toset(var.create_bucket ? ["one"] : [])

  name                        = local.name
  location                    = var.bucket_location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "this" {
  name   = local.object_name
  bucket = local.bucket_name
  source = data.archive_file.this.output_path
}

