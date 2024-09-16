package testimpl

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/codepipeline"
	"github.com/aws/aws-sdk-go-v2/service/lambda"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	t.Run("TestPipelineExists", func(t *testing.T) {
		pipelineId := terraform.OutputList(t, ctx.TerratestTerraformOptions(), "pipeline_ids")[0]
		codepipelineClient := codepipeline.NewFromConfig(GetAWSConfig(t))

		getPipelineOutput, err := codepipelineClient.GetPipeline(context.TODO(), &codepipeline.GetPipelineInput{Name: &pipelineId})
		if err != nil {
			t.Errorf("Error getting pipeline %s: %v", pipelineId, err)
		}

		require.Equal(t, pipelineId, *getPipelineOutput.Pipeline.Name, "Pipeline ID does not match")
		require.NotEmpty(t, (*getPipelineOutput).Pipeline.Stages, "Pipeline does not have any stages")
	})

	t.Run("TestLambdaFunctionsExist", func(t *testing.T) {
		lambdaClient := GetAWSLambdaClient(t)

		functionArns := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "lambda_function_arns")
		functionNames := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "lambda_function_names")
		functionUrls := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "lambda_function_urls")

		for functionAlias, functionName := range functionNames {
			function, err := lambdaClient.GetFunction(context.TODO(), &lambda.GetFunctionInput{
				FunctionName: &functionName,
			})
			if err != nil {
				t.Errorf("Failure during GetFunction: %v", err)
			}

			functionUrlConfig, err := lambdaClient.GetFunctionUrlConfig(context.TODO(), &lambda.GetFunctionUrlConfigInput{
				FunctionName: &functionName,
			})
			if err != nil {
				t.Errorf("Failure during GetFunction: %v", err)
			}

			assert.Equal(t, *function.Configuration.FunctionArn, functionArns[functionAlias], "Expected ARN did not match actual ARN!")
			assert.Equal(t, *function.Configuration.FunctionName, functionNames[functionAlias], "Expected Name did not match actual Name!")
			assert.Equal(t, *functionUrlConfig.FunctionUrl, functionUrls[functionAlias], "Expected URL did not match actual URL!")
		}
	})

	t.Run("TestSecretsManagerSecretExists", func(t *testing.T) {
		secretsManagerClient := GetAWSSecretsManagerClient(t)
		secretId := terraform.Output(t, ctx.TerratestTerraformOptions(), "secretsmanager_secret_id")
		secretArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "secretsmanager_secret_arn")

		secret, err := secretsManagerClient.DescribeSecret(context.TODO(), &secretsmanager.DescribeSecretInput{
			SecretId: &secretId,
		})
		if err != nil {
			t.Errorf("Failure during DescribeSecret: %v", err)
		}
		assert.Equal(t, *secret.ARN, secretArn, "Expected ARN did not match actual ARN!")
	})
}

func GetAWSSecretsManagerClient(t *testing.T) *secretsmanager.Client {
	awsSecretsManagerClient := secretsmanager.NewFromConfig(GetAWSConfig(t))
	return awsSecretsManagerClient
}

func GetAWSLambdaClient(t *testing.T) *lambda.Client {
	awsLambdaClient := lambda.NewFromConfig(GetAWSConfig(t))
	return awsLambdaClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
