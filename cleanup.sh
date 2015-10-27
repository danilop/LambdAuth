#!/bin/bash
echo "Starting cleanup."

# Check if jq is in the PATH
found=$(which jq)
if [ -z "$found" ]; then
  echo "Please install jq under your PATH: http://stedolan.github.io/jq/"
  exit 1
fi

# Ensure config.json exists
if [ ! -f config.json ]; then
	echo "config.json not found!"
	exit 1
fi

# Get config parmaters
echo "Loading config parameters"
REGION=$(jq -r '.REGION' config.json)
if [  -z "$REGION"  ]; then
	echo "config.json: REGION value is required, but missing!"
	exit 1
fi

BUCKET=$(jq -r '.BUCKET' config.json)
if [  -z "$BUCKET"  ]; then
	echo "config.json: BUCKET value is required, but missing!"
	exit 1
fi

# Remove IAM Roles Created for Lambda functions and Cognito
echo "Removing IAM Roles"
aws iam delete-role-policy --role-name LambdAuthChangePassword --policy-name LambdAuthChangePassword
aws iam delete-role --role-name LambdAuthChangePassword

aws iam delete-role-policy --role-name LambdAuthCreateUser --policy-name LambdAuthCreateUser
aws iam delete-role --role-name LambdAuthCreateUser

aws iam delete-role-policy --role-name LambdAuthLogin --policy-name LambdAuthLogin
aws iam delete-role --role-name LambdAuthLogin

aws iam delete-role-policy --role-name LambdAuthLostPassword --policy-name LambdAuthLostPassword
aws iam delete-role --role-name LambdAuthLostPassword

aws iam delete-role-policy --role-name LambdAuthResetPassword --policy-name LambdAuthResetPassword
aws iam delete-role --role-name LambdAuthResetPassword

aws iam delete-role-policy --role-name LambdAuthVerifyUser --policy-name LambdAuthVerifyUser
aws iam delete-role --role-name LambdAuthVerifyUser

aws iam delete-role-policy --role-name Cognito_LambdAuthAuth_Role --policy-name Cognito_LambdAuthAuth_Role
aws iam delete-role --role-name Cognito_LambdAuthAuth_Role

aws iam delete-role-policy --role-name Cognito_LambdAuthUnauth_Role --policy-name Cognito_LambdAuthUnauth_Role
aws iam delete-role --role-name Cognito_LambdAuthUnauth_Role


# Remove Cognito Identity Pool
echo "Removing Cognito Identity Pool"
aws cognito-identity delete-identity-pool --identity-pool-id `aws cognito-identity list-identity-pools --max-results 2 --region $REGION | jq -r '.IdentityPools[] | select(.IdentityPoolName == "LambdAuth") .IdentityPoolId'` --region $REGION

# Remove dynamodb Table
echo "Removing DynamoDB table"
aws dynamodb delete-table --table-name LambdAuthUsers --region $REGION

# Remove the S3 Bucket
echo "Removing S3 Bucket"
aws s3 rm s3://$BUCKET --recursive
aws s3 rb s3://$BUCKET --force

# Remove Lambda functions
echo "Removing Lambda functions..."
aws lambda delete-function --function-name LambdAuthChangePassword --region $REGION
aws lambda delete-function --function-name LambdAuthCreateUser --region $REGION
aws lambda delete-function --function-name LambdAuthLogin --region $REGION
aws lambda delete-function --function-name LambdAuthLostPassword --region $REGION
aws lambda delete-function --function-name LambdAuthResetPassword --region $REGION
aws lambda delete-function --function-name LambdAuthVerifyUser --region $REGION

# Remove CloudWatch Logs and Streams
for f in $(aws logs describe-log-groups --region $REGION | jq -r '.logGroups[] | select(.logGroupName | contains("LambdAuth")) .logGroupName'); do
	echo "Deleting Log group: $f"
	aws logs delete-log-group --log-group-name "$f" --region $REGION
done

echo "Cleanup complete."
