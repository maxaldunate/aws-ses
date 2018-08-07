# AWS Mails Forwarder

> Based On  
> https://github.com/arithmetric/aws-lambda-ses-forwarder  
> http://www.daniloaz.com/en/use-gmail-with-your-own-domain-for-free-thanks-to-amazon-ses-lambda/  

### AWS Resources Generated
* S3-Bucket
  - aws_s3_bucket.bucket "bucket_name" w/lifecycle_rule = bucket_expiration_days
  - aws_s3_bucket_policy.bucket_policy = SES put objetcs
* Lambda 
  - aws_lambda_function.mail_forwarder_by_domain_function
  - null_resource.zip_lambda
  - aws_lambda_permission.allow_ses  
  - aws_iam_role.iam_for_lambda
  - aws_iam_role_policy.lambda_policy
* SES Rule
  - aws_ses_receipt_rule.mail-forwarder-by-domain-rule
    * s3_action
    * lambda_action

### Deployment

* Prerequisites
  - Verify Amazon SES Domains (Adding to hosted zones)
  - Generating DKIM Setting on Route53

* Generate `terraform.tfvars` file
```bash
  access_key             = "AK................6Q"
  secret_key             = "vR..../yW..............................i"
  domain_email_name      = "john@example.com"
  bucket_name            = "example-com-mail-30-days"
  bucket_expiration_days = "30"
  tag_project            = "max-pro"
  tag_project_module     = "mail-forwarder-aldunate-pro"
```

* RUN
```bash
$ terraform init
  ...
  Initializing provider plugins...
  - Checking for available provider plugins on https://releases.hashicorp.com...
  - Downloading plugin for provider "null" (1.0.0)...
  - Downloading plugin for provider "aws" (1.30.0)...
  ...


$ terraform apply
  ...
   Plan: 8 to add, 0 to change, 0 to destroy.
  ...

$ terraform show
$ terraform destroy
  ...
  Destroy Resources

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
  - destroy

  Terraform will perform the following actions:
  
  - aws_iam_role.iam_for_lambda
  - aws_iam_role_policy.lambda_policy
  - aws_lambda_function.mail_forwarder_by_domain_function
  - aws_lambda_permission.allow_ses
  - aws_s3_bucket.bucket
  - aws_s3_bucket_policy.bucket_policy
  - aws_ses_receipt_rule.mail-forwarder-by-domain-rule
  - null_resource.zip_lambda  
  ...
```


The End