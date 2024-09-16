# tf-aws-module_collection-shared_pipeline

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform module wraps functionality required to publish a shared pipeline together into a single deployable unit.

The following resources will be deployed in the shared model:
- SecretsManager secret to share with GitHub Webhooks
- Lambda Functions to serve as webhook targets and trigger CodeBuild
- CodeBuild Trigger to initiate CodePipeline
- CodePipeline to perform common actions across a set of repositories

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `aws_env.sh` file on local workstation. Developer would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `aws` specific. If primitive/segment under development uses any other cloud provider than AWS, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "aws" {
  profile = "<profile_name>"
  region  = "<region_name>"
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests

# Know Issues
Currently, the `encrypt at transit` is not supported in terraform. There is an open issue for this logged with Hashicorp - https://github.com/hashicorp/terraform-provider-aws/pull/26987

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pipelines"></a> [pipelines](#module\_pipelines) | terraform.registry.launch.nttdata.com/module_collection/codepipeline/aws | ~> 1.0 |
| <a name="module_lambda_functions"></a> [lambda\_functions](#module\_lambda\_functions) | terraform.registry.launch.nttdata.com/module_reference/bulk_lambda_function/aws | ~> 1.1 |
| <a name="module_secretsmanager_secret"></a> [secretsmanager\_secret](#module\_secretsmanager\_secret) | terraform.registry.launch.nttdata.com/module_collection/secretsmanager_secret/aws | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.lambda_shared_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

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
