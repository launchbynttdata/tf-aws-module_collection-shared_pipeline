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

module "shared_pipeline" {
  source = "../.."

  bulk_lambda_functions             = var.bulk_lambda_functions
  pipelines                         = var.pipelines
  additional_codebuild_projects     = var.additional_codebuild_projects
  build_image                       = var.build_image
  build_image_pull_credentials_type = var.build_image_pull_credentials_type
  privileged_mode                   = var.privileged_mode
  environment_variables             = var.environment_variables
  secret_name                       = var.secret_name

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource

  tags = var.tags
}
