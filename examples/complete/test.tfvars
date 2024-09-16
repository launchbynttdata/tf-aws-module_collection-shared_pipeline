logical_product_family  = "pipe"
logical_product_service = "example"
class_env               = "root"
instance_env            = "000"
instance_resource       = "000"

secret_name = "github/launchbynttdata/tg-aws-shared-terraform_pipeline" # pragma: allowlist secret

build_image                       = "ghcr.io/launchbynttdata/launch-build-agent-aws:latest"
build_image_pull_credentials_type = "SERVICE_ROLE"
additional_codebuild_projects = [{
  name                              = "trigger_pipeline"
  buildspec                         = "buildspec.yml"
  description                       = "Trigger the pipeline based on the event type."
  source_type                       = "NO_SOURCE"
  artifact_type                     = "NO_ARTIFACTS"
  build_image                       = "ghcr.io/launchbynttdata/launch-build-agent-aws:latest"
  build_image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [{
    name  = "LAUNCH_ACTION"
    value = "trigger-pipeline"
    type  = "PLAINTEXT"
    }, {
    name  = "IGNORE_INTERNALS"
    value = "false"
    type  = "PLAINTEXT"
    }, {
    name  = "USERVAR_S3_CODEPIPELINE_BUCKET"
    value = "pipe-example-pr-event-useast2-root-000-s3-000"
    type  = "PLAINTEXT"
    }, {
    name  = "INTERNALS_CODEPIPELINE_BUCKET"
    value = "pipe-example-internals-useast2-root-000-s3-000"
    type  = "PLAINTEXT"
    }, {
    "name" : "GITHUB_APPLICATION_ID",
    "value" : "997513",
    "type" : "PLAINTEXT"
    },
    {
      "name" : "GITHUB_INSTALLATION_ID",
      "value" : "54838492",
      "type" : "PLAINTEXT"
    },
    {
      "name" : "GITHUB_SIGNING_CERT_SECRET_NAME",
      "value" : "github/app/launch-ptfrm-accltr-pipeline-auth/private_key",
      "type" : "PLAINTEXT"
      }, {
      name  = "TARGETENV"
      value = "root"
      type  = "PLAINTEXT"
  }]
  codebuild_iam = <<EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": [
              "s3:PutObject",
              "s3:GetObjectAcl",
              "s3:GetObject",
              "s3:ListBucketMultipartUploads",
              "s3:ListBucketVersions",
              "s3:ListBucket",
              "s3:DeleteObject",
              "s3:PutObjectAcl",
              "s3:ListMultipartUploadParts"
            ],
            "Effect": "Allow",
            "Resource": "*"
          },
          {
            "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage"
            ],
            "Effect": "Allow",
            "Resource": "*"
          },
          {
            "Action": [
              "kms:Decrypt",
              "kms:DescribeKey"
            ],
            "Effect": "Allow",
            "Resource": "*"
          },
          {
            "Action": [ "secretsmanager:GetSecretValue" ],
            "Effect": "Allow",
            "Resource": "*"
          }
        ]
      }
    EOF
}]

pipelines = [
  {
    name             = "pr_event"
    pipeline_type    = "V2"
    execution_mode   = "SUPERSEDED"
    create_s3_source = true
    source_stage = {
      stage_name = "Source"
      name       = "Source"
      category   = "Source"
      provider   = "S3"
      configuration = {
        S3ObjectKey          = "trigger_pipeline.zip"
        PollForSourceChanges = "false"
      }
      output_artifacts = ["SourceArtifact"]
    }
    stages = [
      {
        stage_name      = "Pending-Commit-Status"
        name            = "Pending-Commit-Status"
        description     = "Set the commit's status to pending so that PRs are blocked until completion."
        category        = "Build"
        provider        = "CodeBuild"
        project_name    = "status"
        buildspec       = "buildspec.yml"
        input_artifacts = ["SourceArtifact"]
        configuration = {
          EnvironmentVariables = <<EOF
            [
              {
                "name":"LAUNCH_ACTION",
                "value":". $CODEBUILD_SRC_DIR/set_vars.sh ; env ; GITHUB_TOKEN=$(launch github auth application --application-id-parameter-name \"$GITHUB_APPLICATION_ID\" --installation-id-parameter-name \"$GITHUB_INSTALLATION_ID\" --signing-cert-secret-name \"$GITHUB_SIGNING_CERT_SECRET_NAME\") launch github commit status set --repository-name \"$GIT_REPO\" --commit-hash \"$MERGE_COMMIT_ID\" --status \"pending\" --target-url \"$CODEBUILD_BUILD_URL\" --context \"ci/shared-aws-terraform-pipeline\" --description \"Build in progress...\"",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_APPLICATION_ID",
                "value":"997513",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_INSTALLATION_ID",
                "value":"54838492",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_SIGNING_CERT_SECRET_NAME",
                "value":"github/app/launch-ptfrm-accltr-pipeline-auth/private_key",
                "type":"PLAINTEXT"
              }
            ]
          EOF
        }
        codebuild_iam = <<EOF
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Action": [
                  "kms:Decrypt",
                  "kms:DescribeKey"
                ],
                "Effect": "Allow",
                "Resource": "*"
              },
              {
                "Action": [ "secretsmanager:GetSecretValue" ],
                "Effect": "Allow",
                "Resource": "*"
              }
            ]
          }
        EOF
        }, {
        stage_name      = "Simulated-Merge"
        name            = "Sim-Merge"
        description     = "Simulate the merge of the PR branch into the target branch."
        category        = "Build"
        provider        = "CodeBuild"
        project_name    = "sim_merge"
        buildspec       = "buildspec.yml"
        input_artifacts = ["SourceArtifact"]
        configuration = {
          EnvironmentVariables = <<EOF
            [
              {
                "name":"LAUNCH_ACTION",
                "value":"simulated-merge",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_APPLICATION_ID",
                "value":"997513",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_INSTALLATION_ID",
                "value":"54838492",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_SIGNING_CERT_SECRET_NAME",
                "value":"github/app/launch-ptfrm-accltr-pipeline-auth/private_key",
                "type":"PLAINTEXT"
              }
            ]
          EOF
        }
        codebuild_iam = <<EOF
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Action": [
                  "kms:Decrypt",
                  "kms:DescribeKey"
                ],
                "Effect": "Allow",
                "Resource": "*"
              },
              {
                "Action": [ "secretsmanager:GetSecretValue" ],
                "Effect": "Allow",
                "Resource": "*"
              }
            ]
          }
        EOF
        }, {
        stage_name      = "Make-Check"
        name            = "Make-Check"
        description     = "Run make check against the Terraform module."
        category        = "Build"
        provider        = "CodeBuild"
        project_name    = "make_check"
        buildspec       = "buildspec.yml"
        input_artifacts = ["SourceArtifact"]
        configuration = {
          EnvironmentVariables = <<EOF
            [
              {
                "name": "LAUNCH_ACTION",
                "value": "make-check",
                "type": "PLAINTEXT"
              },
              {
                "name": "IS_PIPELINE",
                "value": "true",
                "type": "PLAINTEXT"
              },
              {
                "name": "IS_PIPELINE_LAST_STAGE",
                "value": "true",
                "type": "PLAINTEXT"
              },
              {
                "name": "TARGETENV",
                "value": "sandbox",
                "type": "PLAINTEXT"
              },
              {
                "name":"ROLE_TO_ASSUME",
                "value":"arn:aws:iam::020127659860:role/shared_pipeline-terraform-useast2-sandbox-000-role-000",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_APPLICATION_ID",
                "value":"997513",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_INSTALLATION_ID",
                "value":"54838492",
                "type":"PLAINTEXT"
              },
              {
                "name":"GITHUB_SIGNING_CERT_SECRET_NAME",
                "value":"github/app/launch-ptfrm-accltr-pipeline-auth/private_key",
                "type":"PLAINTEXT"
              }
            ]
          EOF
        }
        codebuild_iam = <<EOF
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Action": [
                  "kms:Decrypt",
                  "kms:DescribeKey"
                ],
                "Effect": "Allow",
                "Resource": "*"
              },
              {
                "Action": [ "secretsmanager:GetSecretValue" ],
                "Effect": "Allow",
                "Resource": "*"
              },
              {
                "Action": [ "sts:AssumeRole" ],
                "Effect": "Allow",
                "Resource": "arn:aws:iam::020127659860:role/shared_pipeline-terraform-useast2-sandbox-000-role-000"
              }
            ]
          }
        EOF
    }]
  }
]

bulk_lambda_functions = {
  pr_opened = {
    name          = "opened"
    zip_file_path = "lambda.zip"
    handler       = "codeBuildHandler.lambda_handler"
    environment_variables = {
      CODEBUILD_ENV_VARS_MAP         = <<EOF
{
  "SOURCE_REPO_URL": "repository.clone_url",
  "FROM_BRANCH": "pull_request.head.ref",
  "TO_BRANCH": "pull_request.base.ref",
  "MERGE_COMMIT_ID": "pull_request.head.sha"
}
EOF
      CODEBUILD_PROJECT_NAME         = "pipe-example_trigger_pipeline-useast2-root-000-cb-000"
      CODEBUILD_URL                  = "https://us-east-2.console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-2"
      GIT_SERVER_URL                 = "https://github.com"
      GIT_SECRET_SM_ARN              = "<replaced by module>" # pragma: allowlist secret
      GIT_TOKEN_SM_ARN               = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token"
      GIT_USERNAME_SM_ARN            = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username"
      LOGGING_LEVEL                  = "INFO"
      USERVAR_S3_CODEPIPELINE_BUCKET = "pipe-example-pr-event-useast2-root-000-s3-000"
      VALIDATE_DIGITAL_SIGNATURE     = "false"
      WEBHOOK_EVENT_TYPE             = "opened"
    }
    attach_policy_json = true
    cors = {
      allow_credentials = true
      allow_origins     = ["*"]
      allow_methods     = ["*"]
      allow_headers     = ["date", "keep-alive"]
      expose_headers    = ["keep-alive", "date"]
      max_age           = 86400
    }
    policy_json = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "codebuild:startBuild"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "kms:Decrypt",
          "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "SECRETSMANAGER_SECRET_ARN",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username-??????",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token-??????"
      ]
    }
  ]
}
EOF
  }
  pr_edited = {
    name          = "edited"
    zip_file_path = "lambda.zip"
    handler       = "codeBuildHandler.lambda_handler"
    environment_variables = {
      CODEBUILD_ENV_VARS_MAP         = <<EOF
{
  "SOURCE_REPO_URL": "repository.clone_url",
  "FROM_BRANCH": "pull_request.head.ref",
  "TO_BRANCH": "pull_request.base.ref",
  "MERGE_COMMIT_ID": "pull_request.head.sha"
}
EOF
      CODEBUILD_PROJECT_NAME         = "pipe-example_trigger_pipeline-useast2-root-000-cb-000"
      CODEBUILD_URL                  = "https://us-east-2.console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-2"
      GIT_SERVER_URL                 = "https://github.com"
      GIT_SECRET_SM_ARN              = "<replaced by module>" # pragma: allowlist secret
      GIT_TOKEN_SM_ARN               = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token"
      GIT_USERNAME_SM_ARN            = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username"
      LOGGING_LEVEL                  = "INFO"
      USERVAR_S3_CODEPIPELINE_BUCKET = "pipe-example-pr-event-useast2-root-000-s3-000"
      VALIDATE_DIGITAL_SIGNATURE     = "false"
      WEBHOOK_EVENT_TYPE             = "edited"
    }
    attach_policy_json = true
    cors = {
      allow_credentials = true
      allow_origins     = ["*"]
      allow_methods     = ["*"]
      allow_headers     = ["date", "keep-alive"]
      expose_headers    = ["keep-alive", "date"]
      max_age           = 86400
    }
    policy_json = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "codebuild:startBuild"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "kms:Decrypt",
          "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "SECRETSMANAGER_SECRET_ARN",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username-??????",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token-??????"
      ]
    }
  ]
}
EOF
  }
  pr_sync = {
    name          = "synchronize"
    zip_file_path = "lambda.zip"
    handler       = "codeBuildHandler.lambda_handler"
    environment_variables = {
      CODEBUILD_ENV_VARS_MAP         = <<EOF
{
  "SOURCE_REPO_URL": "repository.clone_url",
  "FROM_BRANCH": "pull_request.head.ref",
  "TO_BRANCH": "pull_request.base.ref",
  "MERGE_COMMIT_ID": "pull_request.head.sha"
}
EOF
      CODEBUILD_PROJECT_NAME         = "pipe-example_trigger_pipeline-useast2-root-000-cb-000"
      CODEBUILD_URL                  = "https://us-east-2.console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-2"
      GIT_SERVER_URL                 = "https://github.com"
      GIT_SECRET_SM_ARN              = "<replaced by module>" # pragma: allowlist secret
      GIT_TOKEN_SM_ARN               = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token"
      GIT_USERNAME_SM_ARN            = "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username"
      LOGGING_LEVEL                  = "INFO"
      USERVAR_S3_CODEPIPELINE_BUCKET = "pipe-example-pr-event-useast2-root-000-s3-000"
      VALIDATE_DIGITAL_SIGNATURE     = "false"
      WEBHOOK_EVENT_TYPE             = "synchronize"
    }
    attach_policy_json = true
    cors = {
      allow_credentials = true
      allow_origins     = ["*"]
      allow_methods     = ["*"]
      allow_headers     = ["date", "keep-alive"]
      expose_headers    = ["keep-alive", "date"]
      max_age           = 86400
    }
    policy_json = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "codebuild:startBuild"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "kms:Decrypt",
          "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "SECRETSMANAGER_SECRET_ARN",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/username-??????",
        "arn:aws:secretsmanager:us-east-2:538234414982:secret:launch/dso-platform/github/service_user/http_access_token-??????"
      ]
    }
  ]
}
EOF
  }
}
