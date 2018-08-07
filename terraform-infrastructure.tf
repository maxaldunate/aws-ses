variable "access_key" {}
variable "secret_key" {}
variable "domain_email_name" {}
variable "bucket_name" {}
variable "bucket_expiration_days" {}
variable "tag_project" {}
variable "tag_project_module" {}

locals {
  common_tags = {
    Project        = "${var.tag_project}"
    Project-Module = "${var.tag_project_module}"
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    id      = "remove"
    enabled = true

    expiration {
      days = "${var.bucket_expiration_days}"
    }
  }

  tags = "${local.common_tags}"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GiveSESPermissionToWriteEmail",
      "Effect": "Allow",
      "Principal": {
         "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
         "StringEquals": {
            "aws:Referer": "${data.aws_caller_identity.current.account_id}"
         }
      }
    } 
  ]
}
POLICY
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id  = "AllowExecutionFromSes"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.mail_forwarder_function.function_name}"
  principal     = "ses.amazonaws.com"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }   
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ses:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = "${aws_iam_role.iam_for_lambda.id}"
  policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}

resource "null_resource" "zip_lambda" {
  provisioner "local-exec" {
    command = "mail-forwarder-by-domain.bat"
  }
}

resource "aws_cloudwatch_log_group" "mail-forwarder" {
  name              = "/aws/lambda/mail-forwarder"
  retention_in_days = 60
  tags              = "${local.common_tags}"
}

resource "aws_lambda_function" "mail_forwarder_function" {
  depends_on       = ["null_resource.zip_lambda"]
  filename         = "mail-forwarder.zip"
  function_name    = "mail-forwarder"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "mail-forwarder-by-domain.handler"
  source_code_hash = "${base64sha256(file("mail-forwarder.zip"))}"
  runtime          = "nodejs4.3"
  timeout          = "30"
  tags             = "${local.common_tags}"

  environment {
    variables = {
      bucket_name = "${var.bucket_name}"
    }
  }
}

resource "aws_ses_receipt_rule" "mail-forwarder-rule" {
  name          = "mail-forwarder-rule"
  rule_set_name = "default-rule-set"
  recipients    = ["${var.domain_email_name}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = "${var.bucket_name}"
    object_key_prefix = ""
    position          = "1"
  }

  lambda_action {
    function_arn    = "${aws_lambda_function.mail_forwarder_function.arn}"
    invocation_type = "Event"
    position        = "2"
  }
}

output "mail-forwarder-function-arn" {
  value = "${aws_lambda_function.mail_forwarder_function.arn}"
}

output "bucket-arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}
