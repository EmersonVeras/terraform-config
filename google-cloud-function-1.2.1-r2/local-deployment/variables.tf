variable "name" {
  description = "The name prefix of the bucket"
}

variable "random_suffix" {
  description = "Wether a random id will be appended to the function name."
  type = bool
  default  = true
  nullable = false
}

variable "source_dir" {
  description = "The directory to copy files from"
}

variable "source_excludes" {
  description = "A list of files to exclude from the source directory"
  type        = set(string)
  default     = []
  nullable    = false
}

variable "create_bucket" {
  description = "Wether to create a new bucket or use an existing one."
  type        = bool
  default     = true
  nullable    = false
}

variable "bucket_name" {
  description = "The name of the bucket to use for an en existing bucket."
  type        = string
  default     = null
}

variable "bucket_location" {
  description = "The location of the bucket to create."
  type        = string
  default     = "EU"
  nullable    = false
}

variable "object_prefix" {
  description = "The prefix of the object name."
  type        = string
  default     = ""
  nullable    = false
}

variable "object_name" {
  description = "The name of the object to create on the bucket, otherwise filemd5 of the zip archive."
  type        = string
  default     = null
}

