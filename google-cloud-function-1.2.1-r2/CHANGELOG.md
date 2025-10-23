# Changelog

## `1.0.x -> 1.1.x`

* Service Account creation is now optional. You must rename `google_service_accoun.this` to `google_service_account.this["one"]` for modules configured with `create_service_account = true` (default). For example: `terraform state mv 'module.function.google_service_account.this' 'module.function.google_service_account.this["one"]'`.

