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

module "pipelines" {
  source  = "terraform.registry.launch.nttdata.com/module_collection/codepipeline/aws"
  version = "~> 1.0"

  pipelines                         = var.pipelines
  additional_codebuild_projects     = var.additional_codebuild_projects
  build_image                       = var.build_image
  privileged_mode                   = var.privileged_mode
  build_image_pull_credentials_type = var.build_image_pull_credentials_type
  environment_variables             = var.environment_variables

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  environment             = var.class_env
  environment_number      = var.instance_env
  resource_number         = var.instance_resource

  tags = local.tags
}

module "lambda_functions" {
  source  = "terraform.registry.launch.nttdata.com/module_reference/bulk_lambda_function/aws"
  version = "~> 1.1"

  bulk_lambda_functions = local.transformed_bulk_lambda_functions

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  environment             = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
}

resource "random_password" "lambda_shared_secret" {
  length  = 24
  special = true
}

module "secretsmanager_secret" {
  source  = "terraform.registry.launch.nttdata.com/module_collection/secretsmanager_secret/aws"
  version = "~> 1.0"

  description             = "Shared secret for Github webhooks"
  secret_name             = var.secret_name
  secret_string           = random_password.lambda_shared_secret.result
  recovery_window_in_days = 7

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource

  tags = local.tags
}
