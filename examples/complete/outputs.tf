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

output "pipeline_ids" {
  value = module.shared_pipeline.pipeline_ids
}

output "pipeline_arns" {
  value = module.shared_pipeline.pipeline_arns
}

output "additional_codebuild_projects" {
  value = module.shared_pipeline.additional_codebuild_projects
}

output "lambda_function_arns" {
  value = module.shared_pipeline.lambda_function_arns
}

output "lambda_function_names" {
  value = module.shared_pipeline.lambda_function_names
}

output "lambda_cloudwatch_log_group_arns" {
  value = module.shared_pipeline.lambda_cloudwatch_log_group_arns
}

output "lambda_cloudwatch_log_group_names" {
  value = module.shared_pipeline.lambda_cloudwatch_log_group_names
}

output "lambda_function_urls" {
  value = module.shared_pipeline.lambda_function_urls
}

output "lambda_role_arns" {
  value = module.shared_pipeline.lambda_role_arns
}

output "lambda_role_names" {
  value = module.shared_pipeline.lambda_role_names
}

output "secretsmanager_secret_id" {
  value = module.shared_pipeline.secretsmanager_secret_id
}

output "secretsmanager_secret_arn" {
  value = module.shared_pipeline.secretsmanager_secret_arn
}
