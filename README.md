## LambdAuth

This is a sample authentication service implemented with a server-less architecture, using [AWS Lambda](http://aws.amazon.com/lambda/) to host and execute the code and [Amazon DynamoDB](http://aws.amazon.com/dynamodb/) as persistent storage. This provides a cost-efficient solution that is scalable and highly available.

The authentication can be used with [Amazon Cognito](http://aws.amazon.com/cognito/) to assume an Authenticated Role via [Developer Authenticated Identities](http://docs.aws.amazon.com/cognito/devguide/identity/developer-authenticated-identities/).

The password are not save in clear in the database, but "salted" (via [HMAC-SHA1](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code) using a dedicated, random salt for each password.

The basic functions implemented are:
- new user creation, validating the email address provided
- login, getting back an authentication "token" that can be used with Amazon Cognito to assume an Authenticated Role via Developer Authenticated Identities
- password change
- password reset, via email

## License

Copyright (c) 2015 Danilo Poccia, http://danilop.net

This code is licensed under the The MIT License (MIT). Please see the LICENSE file that accompanies this project for the terms of use.

## Installation

A sample installation script using Bash (`init.sh`) is provided to install and configure all necessary resources in your AWS account:

- the [Amazon S3](http://aws.amazon.com/s3/) bucket to host the sample HTML pages
- the [Amazon DynamoDB](http://aws.amazon.com/dynamodb/) table for users and credentials
- the [AWS Identity and Access Management (IAM)](http://aws.amazon.com/iam/) roles for Amazon Cognito and AWS Lambda
- the [Amazon Cognito](http://aws.amazon.com/cognito/) identity pool
- the [AWS Lambda](http://aws.amazon.com/lambda/) functions

The `init.sh` script requires a configured [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/) and the [jq](http://stedolan.github.io/jq/) tool.

*Before running the `init.sh` script, set up your configuration in the `config.json` file*:

- your AWS account (12-digit number)
- the AWS region (e.g. "eu-west-1")
- the S3 bucket to use for the sample HTML pages
- the Cache-Control: max-age value, in seconds, to use on S3 (e.g. if distributed by CloudFront or another CDN)
- the DynamoDB table to create/use
- the Cognito identity pool name to create/use (the identity pool id is automatically overwritten if present in the config.json file)
- the Developer Provider Name to use with Cognito
- the external name to be included in emails
- the email source for emails (must be verified via SES)
- the link to the verification page (usually http://bucket.s3.amazonaws.com/verify.html, but can be customized using a bucket name that is a DNS domain, CloudFront or another CDN)
- the link to the password reset page (usually http://bucket.s3.amazonaws.com/reset.html, but can be customized using a bucket name that is a DNS domain, CloudFront or another CDN)

```
{
  "AWS_ACCOUNT_ID": "123412341234",
  "REGION": "eu-west-1",
  "BUCKET": "bucket",
  "MAX_AGE": "10",
  "DDB_TABLE": "LambdAuthUsers",
  "IDENTITY_POOL_NAME": "LambdAuth",
  "DEVELOPER_PROVIDER_NAME": "login.mycompany.myapp",
  "EXTERNAL_NAME": "My Authentication",
  "EMAIL_SOURCE": "email@example.com",
  "VERIFICATION_PAGE": "http://bucket.s3.amazonaws.com/verify.html",
  "RESET_PAGE": "http://bucket.s3.amazonaws.com/reset.html",
}
```

A sample deployment script using Bash (`deploy.sh`) is provided to update the AWS Lambda functions and the sample HTML pages on the Amazon S3 bucket.

## Usage

Sample HTML pages are provided to showcase how to use this framework with a JavaScript application:

- signup.html - to create a new user, the email address will be validated sending a custom link to the verify.html page
- login.html - to login in, assuming an authenitcated role with Cognito
- verify.html - to validate the email address of a new user
- changePassword.html - to change password, knowing the old one
- lostPAssword.html - to ask for a passwrod reser, via email
- reset.html - to reset the password, linked by the email sent for a lost password

The same use cases can be implemented on a Mobile device using the [AWS Mobile SDK](http://aws.amazon.com/mobile/sdk/).

## APIs

The APIs are exposed as AWS Lambda Functions:

- LambdAuthCreateUser(email, password) -> { created: true / false }

- LambdAuthVerifyUser(email, verify) -> { verified: true / false}

- LambdAuthLogin(email, password) -> { login: true / false,	identityId: identityId, token: token }

- LambdAuthChangePassword(email, oldPassword, newPassword) -> { changed: true / false }

- LambdAuthLostPassword(email) -> { sent: true / false }

- LambdAuthResetPassword(email, lost, password) -> { changed: true / false }

