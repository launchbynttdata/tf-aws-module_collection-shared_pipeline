// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false
  default     = "launch"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false
  default     = "backend"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 1 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 1 to 100."
  }
}

variable "region" {
  type        = string
  description = "AWS Region in which the infra needs to be provisioned"
  default     = "us-east-2"
}

variable "pipelines" {
  description = "List of all custom pipelines to create."
  type        = any
}

variable "additional_codebuild_projects" {
  description = "Codebuild to trigger other pipelines. Used by the lambdas to trigger the correct pipeline."
  type        = any
  default     = null
}

variable "build_image" {
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "privileged_mode" {
  type        = bool
  default     = false
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
}

variable "build_image_pull_credentials_type" {
  type        = string
  default     = "CODEBUILD"
  description = "Type of credentials AWS CodeBuild uses to pull images in your build.Valid values: CODEBUILD, SERVICE_ROLE. When you use a cross-account or private registry image, you must use SERVICE_ROLE credentials."
}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
      type  = string
    }
  ))

  default = []

  description = "A list of maps, that contain the keys 'name', 'value', and 'type' to be used as additional environment variables for the build. Valid types are 'PLAINTEXT', 'PARAMETER_STORE', or 'SECRETS_MANAGER'"
}

variable "bulk_lambda_functions" {
  description = "Map of lambda functions to create."
  type = map(object({
    name                    = string
    description             = optional(string, "")
    handler                 = optional(string, "index.lambda_handler")
    runtime                 = optional(string, "python3.9")
    architectures           = optional(list(string), ["x86_64"])
    publish                 = optional(bool, true)
    ephemeral_storage_size  = optional(number, 512)
    environment_variables   = optional(map(string), {})
    memory_size             = optional(number, 128)
    timeout                 = optional(number, 3)
    create_package          = optional(bool, false)
    source_path             = optional(string)
    zip_file_path           = optional(string)
    store_on_s3             = optional(bool, false)
    s3_existing_package     = optional(map(string))
    s3_bucket               = optional(string)
    s3_prefix               = optional(string, "builds")
    layers                  = optional(list(string))
    hash_extra              = optional(string)
    ignore_source_code_hash = optional(bool, false)
    authorization_type      = optional(string, "NONE")
    cors = optional(object({
      allow_credentials = optional(bool, false)
      allow_headers     = optional(list(string), null)
      allow_methods     = optional(list(string), null)
      allow_origins     = optional(list(string), null)
      expose_headers    = optional(list(string), null)
      max_age           = optional(number, 0)
    }), {})
    create_lambda_function_url         = optional(bool, true)
    invoke_mode                        = optional(string, "BUFFERED")
    attach_policy_statements           = optional(bool, false)
    policy_statements                  = optional(map(string), {})
    attach_policy                      = optional(bool, false)
    policy                             = optional(string)
    attach_policies                    = optional(bool, false)
    policies                           = optional(list(string), [])
    attach_policy_json                 = optional(bool, false)
    policy_json                        = optional(string)
    attach_policy_jsons                = optional(bool, false)
    policy_jsons                       = optional(list(string), [])
    attach_dead_letter_policy          = optional(bool, false)
    dead_letter_target_arn             = optional(string)
    attach_network_policy              = optional(bool, false)
    attach_async_event_policy          = optional(bool, false)
    attach_tracing_policy              = optional(bool, false)
    assume_role_policy_statements      = optional(map(string), {})
    trusted_entities                   = optional(list(string), [])
    attach_cloudwatch_logs_policy      = optional(bool, true)
    attach_create_log_group_permission = optional(bool, true)
    cloudwatch_logs_kms_key_id         = optional(string)
    cloudwatch_logs_log_group_class    = optional(string, "STANDARD")
    cloudwatch_logs_retention_in_days  = optional(number, 30)
    cloudwatch_logs_skip_destroy       = optional(bool, false)
    cloudwatch_logs_tags               = optional(map(string))
    tracing_mode                       = optional(string, "PassThrough")
    vpc_security_group_ids             = optional(list(string))
    vpc_subnet_ids                     = optional(list(string))
    lambda_at_edge                     = optional(bool, false)
    lambda_at_edge_logs_all_regions    = optional(bool, true)
    tags                               = optional(map(string))
    create                             = optional(bool, true)
  }))
}

variable "secret_name" {
  description = "The name of the SecretsManager secret to use with the Lambda functions."
  type        = string
}

variable "tags" {
  description = "A map of custom tags to be associated with the resources"
  type        = map(string)
  default     = {}
}
