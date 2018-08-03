variable "access_key" {}
variable "secret_key" {}

variable "domain_name" {
  default = "aldunate.pro"
}

variable "bucket_name" {
  default = "aldunate-pro-mail-5ab38c6dc9a6905f540f29aa"
}

variable "tag_project" {
  default = {
    Project        = "max-pro"
    Project-Module = "mail-forwarder-aldunate-pro"
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = "${var.tag_project}"
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

#resource "aws_iam_role" "test" {
#  name               = "test-role"
#  assume_role_policy = "${file("assume-role-policy.json")}"
#}

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
    actions   = ["ses:SendRawEmail"]
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

resource "aws_lambda_function" "mail_forwarder_by_domain_function" {
  filename         = "mail-forwarder-by-domain.zip"
  function_name    = "mail-forwarder-by-domain"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "mail-forwarder-by-domain.handler"
  source_code_hash = "${base64sha256(file("mail-forwarder-by-domain.zip"))}"
  runtime          = "nodejs4.3"
  timeout          = "30"
  tags             = "${var.tag_project}"
}

output "mail-forwarder-by-domain-function-arn" {
  value = "${aws_lambda_function.mail_forwarder_by_domain_function.arn}"
}

output "bucket-arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}
