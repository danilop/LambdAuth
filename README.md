## LambdAuth

[![Join the chat at https://gitter.im/danilop/LambdAuth](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/danilop/LambdAuth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A sample authentication service implemented with a server-less architecture, using [AWS Lambda](http://aws.amazon.com/lambda/) to host and execute the code and [Amazon DynamoDB](http://aws.amazon.com/dynamodb/) as persistent storage. This provides a cost-efficient solution that is scalable and highly available.

The authentication can be used with [Amazon Cognito](http://aws.amazon.com/cognito/) to assume an Authenticated Role via [Developer Authenticated Identities](http://docs.aws.amazon.com/cognito/devguide/identity/developer-authenticated-identities/).

The basic functions implemented are:
- new user creation, an email is sent to validate the email address provided
- login, getting back an authentication "token" that can be used with Amazon Cognito to assume an Authenticated Role via Developer Authenticated Identities
- password change
- password reset, an email is sent with a link to reset the password

Passwords are not saved in clear in the database, but "salted" (via [HMAC-SHA1](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code)) using a dedicated, random salt for each password.

[Amazon SES](http://aws.amazon.com/ses/) is used to send all emails. 

The login function is calling in the backend [GetOpenIdTokenForDeveloperIdentity](http://docs.aws.amazon.com/cognitoidentity/latest/APIReference/API_GetOpenIdTokenForDeveloperIdentity.html), a Cognito API to register (or retrieve) the IdentityId and an OpenID Connect token for a user authenticated by your backend authentication process.

A sample implementation can be found at [http://lambdauth.danilop.net](http://lambdauth.danilop.net).

## License

Copyright (c) 2015 Danilo Poccia, http://danilop.net

This code is licensed under the The MIT License (MIT). Please see the LICENSE file that accompanies this project for the terms of use.

## Installation

**Install aws CLI**

- Check if the python is already installed by using `$ python --version`
- Download CLI by `$ curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"`
- UnZip CLI by `$ unzip awscli-bundle.zip`
- Install CLI by `$ sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws`
- check if the CLI is installed correctly by `$ aws --version`

**Configure CLI**

- Configure CLI with `$ aws configure`
- Put the AWS Access Key ID when asked
- Put the AWS Secret Access Key when asked
- Put Default region name when asked
- Put Default output format, press enter to keep the default which is JSON

**Install jq**

- Install jq on mac by `$ brew install jq`

More details of installing aws CLI can be found here, more details on installing jq can be found here. 

A sample installation script using Bash (`init.sh`) is provided to install and configure all necessary resources in your AWS account:

- the [Amazon S3](http://aws.amazon.com/s3/) bucket to host the sample HTML pages
- the [Amazon DynamoDB](http://aws.amazon.com/dynamodb/) table for users and credentials
- the [AWS Identity and Access Management (IAM)](http://aws.amazon.com/iam/) roles for Amazon Cognito and AWS Lambda
- the [Amazon Cognito](http://aws.amazon.com/cognito/) identity pool
- the [AWS Lambda](http://aws.amazon.com/lambda/) functions

The `init.sh` script requires a configured [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/) and the [jq](http://stedolan.github.io/jq/) tool. The script is designed to be non destructive, so you can run it again (e.g. if you delete a role) without affecting the other resources.

**Before running the `init.sh` script, set up your configuration in the `config.json` file**:

- your AWS account (12-digit number)
- the AWS region (e.g. "eu-west-1")
- the Amazon S3 bucket to use for the sample HTML pages
- the Cache-Control: max-age value, in seconds, to use on Amazon S3 (e.g. if distributed by [Amazon CloudFront](http://aws.amazon.com/cloudfront/) or another CDN)
- the Amazon DynamoDB table to create/use
- the Amazon Cognito identity pool name to create/use (the identity pool id is automatically overwritten if present in the config.json file)
- the Developer Provider Name to use with Amazon Cognito
- the external name to be included in emails
- the email source for emails (must be verified by Amazon SES)
- the link to the verification page (usually http://bucket.s3.amazonaws.com/verify.html, but can be customized using a bucket name that is a DNS domain, Amazon CloudFront or another CDN)
- the link to the password reset page (usually http://bucket.s3.amazonaws.com/reset.html, but can be customized using a bucket name that is a DNS domain, Amazon CloudFront or another CDN)

```json
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

At the end of the `init.sh` script, you can start creating users pointing your browser to:

`http://bucket.s3.amazonaws.com/index.html` (replacing `bucket` with your bucket name)

As an optional step, you may want to configure Amazon S3 for [Website Hosting](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html) and use Amazon CloudFront to [distribute the static content](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStarted.html).

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

| Function              | Input                         | Output                                 |
|-----------------------|-------------------------------|----------------------------------------|
|LambdAuthCreateUser    |email, password                | created: true / false                  |
|LambdAuthVerifyUser    |email, verify                  | verified: true / false                 |
|LambdAuthLogin         |email, password                | login: true / false,	identityId, token|
|LambdAuthChangePassword|email, oldPassword, newPassword | changed: true / false                 |
|LambdAuthLostPassword  |email                          | sent: true / false                     |
|LambdAuthResetPassword |email, lost, password          | changed: true / false                  |
