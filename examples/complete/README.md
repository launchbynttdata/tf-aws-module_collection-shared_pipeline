# Complete example with TLS enabled
This example will provision a AppMesh ingress along with all its dependencies.

## Known Issues
1. Unable to provision all resources in 1 go. Need to do it in 2 batches
   ```shell
   # Apply the VPC and ecs_platform modules first
    terraform apply -target module.vpc
   # Apply remaining that is ecs_ingress
    terraform apply
    ```
2. Make sure that the app image is in the ECR of the same account not cross account. The VPC endpoints work only within same account. This example uses private network through VPC endpoints
3. Egress port 443 should be open for security groups of ECS Service to be able to pull images from ECR
4. Make sure the VPC endpoints are configured for AppMesh. Without that the ECS task containers would hang in pending state forever
5. This example module assumes that the `dns_zone` is already created. `private_ca` can be optionally created on passed in as input parameter. ECR image for app is already pushed to an ECR repo
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_shared_pipeline"></a> [shared\_pipeline](#module\_shared\_pipeline) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"backend"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_pipelines"></a> [pipelines](#input\_pipelines) | List of all custom pipelines to create. | `any` | n/a | yes |
| <a name="input_additional_codebuild_projects"></a> [additional\_codebuild\_projects](#input\_additional\_codebuild\_projects) | Codebuild to trigger other pipelines. Used by the lambdas to trigger the correct pipeline. | `any` | `null` | no |
| <a name="input_build_image"></a> [build\_image](#input\_build\_image) | Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | (Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images | `bool` | `false` | no |
| <a name="input_build_image_pull_credentials_type"></a> [build\_image\_pull\_credentials\_type](#input\_build\_image\_pull\_credentials\_type) | Type of credentials AWS CodeBuild uses to pull images in your build.Valid values: CODEBUILD, SERVICE\_ROLE. When you use a cross-account or private registry image, you must use SERVICE\_ROLE credentials. | `string` | `"CODEBUILD"` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | A list of maps, that contain the keys 'name', 'value', and 'type' to be used as additional environment variables for the build. Valid types are 'PLAINTEXT', 'PARAMETER\_STORE', or 'SECRETS\_MANAGER' | <pre>list(object(<br>    {<br>      name  = string<br>      value = string<br>      type  = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_bulk_lambda_functions"></a> [bulk\_lambda\_functions](#input\_bulk\_lambda\_functions) | Map of lambda functions to create. | <pre>map(object({<br>    name                    = string<br>    description             = optional(string, "")<br>    handler                 = optional(string, "index.lambda_handler")<br>    runtime                 = optional(string, "python3.9")<br>    architectures           = optional(list(string), ["x86_64"])<br>    publish                 = optional(bool, true)<br>    ephemeral_storage_size  = optional(number, 512)<br>    environment_variables   = optional(map(string), {})<br>    memory_size             = optional(number, 128)<br>    timeout                 = optional(number, 3)<br>    create_package          = optional(bool, false)<br>    source_path             = optional(string)<br>    zip_file_path           = optional(string)<br>    store_on_s3             = optional(bool, false)<br>    s3_existing_package     = optional(map(string))<br>    s3_bucket               = optional(string)<br>    s3_prefix               = optional(string, "builds")<br>    layers                  = optional(list(string))<br>    hash_extra              = optional(string)<br>    ignore_source_code_hash = optional(bool, false)<br>    authorization_type      = optional(string, "NONE")<br>    cors = optional(object({<br>      allow_credentials = optional(bool, false)<br>      allow_headers     = optional(list(string), null)<br>      allow_methods     = optional(list(string), null)<br>      allow_origins     = optional(list(string), null)<br>      expose_headers    = optional(list(string), null)<br>      max_age           = optional(number, 0)<br>    }), {})<br>    create_lambda_function_url         = optional(bool, true)<br>    invoke_mode                        = optional(string, "BUFFERED")<br>    attach_policy_statements           = optional(bool, false)<br>    policy_statements                  = optional(map(string), {})<br>    attach_policy                      = optional(bool, false)<br>    policy                             = optional(string)<br>    attach_policies                    = optional(bool, false)<br>    policies                           = optional(list(string), [])<br>    attach_policy_json                 = optional(bool, false)<br>    policy_json                        = optional(string)<br>    attach_policy_jsons                = optional(bool, false)<br>    policy_jsons                       = optional(list(string), [])<br>    attach_dead_letter_policy          = optional(bool, false)<br>    dead_letter_target_arn             = optional(string)<br>    attach_network_policy              = optional(bool, false)<br>    attach_async_event_policy          = optional(bool, false)<br>    attach_tracing_policy              = optional(bool, false)<br>    assume_role_policy_statements      = optional(map(string), {})<br>    trusted_entities                   = optional(list(string), [])<br>    attach_cloudwatch_logs_policy      = optional(bool, true)<br>    attach_create_log_group_permission = optional(bool, true)<br>    cloudwatch_logs_kms_key_id         = optional(string)<br>    cloudwatch_logs_log_group_class    = optional(string, "STANDARD")<br>    cloudwatch_logs_retention_in_days  = optional(number, 30)<br>    cloudwatch_logs_skip_destroy       = optional(bool, false)<br>    cloudwatch_logs_tags               = optional(map(string))<br>    tracing_mode                       = optional(string, "PassThrough")<br>    vpc_security_group_ids             = optional(list(string))<br>    vpc_subnet_ids                     = optional(list(string))<br>    lambda_at_edge                     = optional(bool, false)<br>    lambda_at_edge_logs_all_regions    = optional(bool, true)<br>    tags                               = optional(map(string))<br>    create                             = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | The name of the SecretsManager secret to use with the Lambda functions. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be associated with the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pipeline_ids"></a> [pipeline\_ids](#output\_pipeline\_ids) | n/a |
| <a name="output_pipeline_arns"></a> [pipeline\_arns](#output\_pipeline\_arns) | n/a |
| <a name="output_additional_codebuild_projects"></a> [additional\_codebuild\_projects](#output\_additional\_codebuild\_projects) | n/a |
| <a name="output_lambda_function_arns"></a> [lambda\_function\_arns](#output\_lambda\_function\_arns) | n/a |
| <a name="output_lambda_function_names"></a> [lambda\_function\_names](#output\_lambda\_function\_names) | n/a |
| <a name="output_lambda_cloudwatch_log_group_arns"></a> [lambda\_cloudwatch\_log\_group\_arns](#output\_lambda\_cloudwatch\_log\_group\_arns) | n/a |
| <a name="output_lambda_cloudwatch_log_group_names"></a> [lambda\_cloudwatch\_log\_group\_names](#output\_lambda\_cloudwatch\_log\_group\_names) | n/a |
| <a name="output_lambda_function_urls"></a> [lambda\_function\_urls](#output\_lambda\_function\_urls) | n/a |
| <a name="output_lambda_role_arns"></a> [lambda\_role\_arns](#output\_lambda\_role\_arns) | n/a |
| <a name="output_lambda_role_names"></a> [lambda\_role\_names](#output\_lambda\_role\_names) | n/a |
| <a name="output_secretsmanager_secret_id"></a> [secretsmanager\_secret\_id](#output\_secretsmanager\_secret\_id) | n/a |
| <a name="output_secretsmanager_secret_arn"></a> [secretsmanager\_secret\_arn](#output\_secretsmanager\_secret\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
