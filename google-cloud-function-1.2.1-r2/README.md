# Terraform Google Cloud Functions module

This README provides an overview of a Terraform module
which sets up Google Cloud Functions with various triggers,
such as Pub/Sub, HTTP, Cloud Storage events, and scheduled events.

The configuration dynamically handles different types of triggers
and creates the needed resources such as service accounts and
IAM bindings based on input variables.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_scheduled_trigger"></a> [scheduled\_trigger](#module\_scheduled\_trigger) | ./scheduled-trigger | n/a |

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_cloud_run_v2_service_iam_member.trigger_run_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_cloudfunctions2_function.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_cloudfunctions2_function_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function_iam_member) | resource |
| [google_cloudfunctions2_function_iam_member.trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function_iam_member) | resource |
| [google_project_iam_member.trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_secret_manager_secret_iam_member.secret_env](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_iam_member.storage_object_read](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.storage_object_read_write](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_env"></a> [build\_env](#input\_build\_env) | n/a | `map(string)` | `{}` | no |
| <a name="input_cpu_limit"></a> [cpu\_limit](#input\_cpu\_limit) | n/a | `number` | `1` | no |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Email of the service account to create and use as an identity for the cloud function. | `bool` | `true` | no |
| <a name="input_create_trigger_service_account"></a> [create\_trigger\_service\_account](#input\_create\_trigger\_service\_account) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_entry_point"></a> [entry\_point](#input\_entry\_point) | n/a | `string` | `"handler"` | no |
| <a name="input_event_trigger"></a> [event\_trigger](#input\_event\_trigger) | n/a | <pre>object({<br>    # one of: http, schedule, pubsub, storage_object/finalized, storage_object/archived, storage_object/deleted, storage_object/metadata_updated<br>    event_type = string<br>    # schedule<br>    schedules = optional(set(string), null)<br>    # pubsub<br>    create_topic = optional(bool, true)<br>    pubsub_topic = optional(string, null)<br>    # storage_object_finalization<br>    bucket_name             = optional(string, null)<br>    bucket_grant_read_only  = optional(bool, false)<br>    bucket_grant_read_write = optional(bool, true)<br>    # pubsub + storage_object_finalization<br>    retry_on_failure = optional(bool, false)<br>  })</pre> | <pre>{<br>  "event_type": "http"<br>}</pre> | no |
| <a name="input_function_env"></a> [function\_env](#input\_function\_env) | n/a | `map(string)` | `{}` | no |
| <a name="input_function_generated_secret_env"></a> [function\_generated\_secret\_env](#input\_function\_generated\_secret\_env) | Map of environment variables generated from a random or rotation controlled secret managed externally | <pre>map(object({<br>    keeper           = optional(string, "")<br>    length           = optional(number, 32)<br>    special          = optional(bool, true)<br>    override_special = optional(string)<br>    numeric          = optional(bool, true)<br>    lower            = optional(bool, true)<br>    upper            = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_function_secret_env"></a> [function\_secret\_env](#input\_function\_secret\_env) | n/a | <pre>map(<br>    object({<br>      secret_project_id = optional(string)<br>      secret_id         = string<br>      secret_version    = optional(string, "latest")<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_invoker_iam_members"></a> [invoker\_iam\_members](#input\_invoker\_iam\_members) | n/a | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"europe-west4"` | no |
| <a name="input_max_instance_count"></a> [max\_instance\_count](#input\_max\_instance\_count) | n/a | `number` | `1` | no |
| <a name="input_max_instance_request_concurrency"></a> [max\_instance\_request\_concurrency](#input\_max\_instance\_request\_concurrency) | n/a | `number` | `1` | no |
| <a name="input_memory_limit"></a> [memory\_limit](#input\_memory\_limit) | n/a | `string` | `"256Mi"` | no |
| <a name="input_min_instance_count"></a> [min\_instance\_count](#input\_min\_instance\_count) | n/a | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `any` | n/a | yes |
| <a name="input_public"></a> [public](#input\_public) | n/a | `bool` | `false` | no |
| <a name="input_random_suffix"></a> [random\_suffix](#input\_random\_suffix) | Wether a random id will be appended to the function name. | `bool` | `true` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | n/a | `string` | `"python38"` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email of the service account to use as an identity for the cloud function. | `any` | `null` | no |
| <a name="input_source_bucket"></a> [source\_bucket](#input\_source\_bucket) | n/a | `any` | n/a | yes |
| <a name="input_source_object_generation"></a> [source\_object\_generation](#input\_source\_object\_generation) | n/a | `any` | `null` | no |
| <a name="input_source_object_name"></a> [source\_object\_name](#input\_source\_object\_name) | n/a | `any` | n/a | yes |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | n/a | `number` | `60` | no |
| <a name="input_vpc_connector"></a> [vpc_connector](#input\_vpc\_connector) | n/a | `string` | `null` | no |
[vpc_connector_egress_settings](#vpc\_connector\_egress\_settings) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_trigger"></a> [event\_trigger](#output\_event\_trigger) | n/a |
| <a name="output_location"></a> [location](#output\_location) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | n/a |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | n/a |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | n/a |
| <a name="output_trigger_service_account_email"></a> [trigger\_service\_account\_email](#output\_trigger\_service\_account\_email) | n/a |
| <a name="output_trigger_service_account_id"></a> [trigger\_service\_account\_id](#output\_trigger\_service\_account\_id) | n/a |
| <a name="output_uri"></a> [uri](#output\_uri) | n/a |
| <a name="vpc_connector"></a> [vpc_connector](#vpc\_connector) | n/a |
| <a name="vpc_connector_egress_settings"></a> [vpc_connector_egress_settings](#vpc\_connector\_egress\_settings) | n/a |
<!-- END_TF_DOCS -->
