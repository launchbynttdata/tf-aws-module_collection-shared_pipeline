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

locals {

  default_tags = {
    provisioner = "Terraform"
  }

  update_environment_variables = {
    GIT_SECRET_SM_ARN      = local.secret_partial_arn
    CODEBUILD_PROJECT_NAME = module.pipelines.additional_codebuild_projects[0][0]
  }

  secret_full_arn = module.secretsmanager_secret.arn
  # Strip the -xxxxxx off the full secret ARN to get the partial ARN
  secret_partial_arn = replace(local.secret_full_arn, regex("-[\\w\\d]{6}$", local.secret_full_arn), "")
  # Readd the wildcard for IAM purposes
  secret_wildcard_arn = "${local.secret_partial_arn}-??????"

  environment_variables             = { for k, v in var.bulk_lambda_functions : k => merge(v.environment_variables, local.update_environment_variables) }
  policy_updates                    = { for k, v in var.bulk_lambda_functions : k => replace(v.policy_json, "SECRETSMANAGER_SECRET_ARN", local.secret_wildcard_arn) }
  transformed_bulk_lambda_functions = { for k, v in var.bulk_lambda_functions : k => merge(v, { policy_json = local.policy_updates[k], environment_variables = local.environment_variables[k] }) }

  tags = merge(local.default_tags, var.tags)
}
