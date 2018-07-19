resource "aws_s3_bucket" "bucket_import" {
  bucket = "${var.bucket_import}"
  acl    = "private"

#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        kms_master_key_id = "${var.kms_key_id}"
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }
}

resource "aws_iam_role" "vmimport" {
  name = "vmimport"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vmie.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "vmimport"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "vmimport-role-pol" {
    name        = "vmimport-policy"
    description = "VMimport policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:GetParametersForImport",
        "s3:GetObject",
        "kms:ListKeyPolicies",
        "kms:GetKeyRotationStatus",
        "kms:ListRetirableGrants",
        "kms:GetKeyPolicy",
        "kms:DescribeKey",
        "s3:ListBucket",
        "kms:ListResourceTags",
        "s3:GetBucketLocation",
        "kms:ListGrants"
      ],
      "Effect": "Allow",
      "Resource": [
         "${aws_s3_bucket.bucket_import.arn}/*",
         "${aws_s3_bucket.bucket_import.arn}",
         "arn:aws:kms:eu-west-1:548303330441:key/7388f951-7668-4134-9a4d-bcf368bdc852"
       ]
    },
    {
      "Action": [
        "kms:ListKeys",
        "ec2:CopySnapshot",
        "ec2:Describe*",
        "kms:GenerateRandom",
        "ec2:ModifySnapshotAttribute",
        "kms:ListAliases",
        "ec2:RegisterImage",
        "kms:ReEncryptTo",
        "kms:ReEncryptFrom"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vmimport-attach" {
    role       = "${aws_iam_role.vmimport.name}"
    policy_arn = "${aws_iam_policy.vmimport-role-pol.arn}"
}

resource "aws_iam_role" "vmielambda" {
  name = "vmielambda-role"
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

resource "aws_iam_policy" "vmielambda-role-pol" {
    name        = "vmielambda-policy"
    description = "VMie lambda policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:ListBucketMultipartUploads",
        "kms:ListKeyPolicies",
        "kms:ListRetirableGrants",
        "kms:GetKeyPolicy",
        "s3:CreateBucket",
        "kms:ListResourceTags",
        "s3:ListBucket",
        "kms:ListGrants",
        "kms:GetParametersForImport",
        "s3:PutObject",
        "s3:GetObject",
        "s3:AbortMultipartUpload",
        "kms:GetKeyRotationStatus",
        "kms:DescribeKey",
        "s3:DeleteObject",
        "s3:GetBucketLocation",
        "s3:DeleteBucket"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:kms:eu-west-1:548303330441:key/7388f951-7668-4134-9a4d-bcf368bdc852",
         "${aws_s3_bucket.bucket_import.arn}/*",
         "${aws_s3_bucket.bucket_import.arn}"
       ]
    },
    {
      "Action": [
        "ec2:ImportVolume",
        "ec2:DescribeInstances",
        "kms:GenerateRandom",
        "ec2:DeleteTags",
        "events:EnableRule",
        "ec2:DescribeInstanceAttribute",
        "dynamodb:DeleteItem",
        "ec2:CreateImage",
        "sns:Publish",
        "ec2:StartInstances",
        "kms:ReEncryptTo",
        "dynamodb:GetItem",
        "ec2:DescribeExportTasks",
        "ec2:ImportImage",
        "ec2:DescribeInstanceStatus",
        "events:DisableRule",
        "ec2:CreateInstanceExportTask",
        "ec2:CancelExportTask",
        "events:DescribeRule",
        "ec2:TerminateInstances",
        "ec2:ImportInstance",
        "dynamodb:PutItem",
        "ec2:DescribeTags",
        "ec2:CreateTags",
        "ec2:CancelConversionTask",
        "ec2:ImportSnapshot",
        "dynamodb:Scan",
        "ec2:DescribeImportImageTasks",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "ec2:StopInstances",
        "kms:ReEncryptFrom",
        "ec2:DescribeImportSnapshotTasks",
        "sns:List*",
        "kms:ListKeys",
        "s3:ListAllMyBuckets",
        "kms:ListAliases",
        "ec2:CancelImportTask",
        "ec2:DescribeConversionTasks"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:::*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vmielambda-attach" {
    role       = "${aws_iam_role.vmielambda.name}"
    policy_arn = "${aws_iam_policy.vmielambda-role-pol.arn}"
}

resource "aws_dynamodb_table" "vmie_status_table" {
  name           = "vmie_status"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ImportTaskId"

  attribute {
    name = "ImportTaskId"
    type = "S"
  }
}


data "template_file" "cloudformation_sns_stack_first" {
    template = "${file("${path.module}/templates/email-sns-stack.json.tpl")}"

    vars {
        display_name  = "${var.display_name_first}"
        email_address = "${var.email_address}"
        protocol      = "${var.protocol}"
    }
}

data "template_file" "cloudformation_sns_stack_second" {
    template = "${file("${path.module}/templates/email-sns-stack-second.json.tpl")}"

    vars {
        display_name  = "${var.display_name_second}"
        email_address = "${var.email_address}"
        protocol      = "${var.protocol}"
    }
}

resource "aws_cloudformation_stack" "sns-topic-first" {
    name = "${var.stack_name_sns1}"
    template_body = "${data.template_file.cloudformation_sns_stack_first.rendered}"
}

resource "aws_cloudformation_stack" "sns-topic-second" {
    name = "${var.stack_name_sns2}"
    template_body = "${data.template_file.cloudformation_sns_stack_second.rendered}"
}

resource "aws_lambda_function" "ImportOva" {
  function_name    = "ImportOva"
  s3_bucket        = "${var.bucket_lambda}"
  s3_key           = "import_ova.zip"
  role             = "${aws_iam_role.vmielambda.arn}"
  handler          = "import_ova.lambda_handler"
  description      = "Lambda Function that automatically imports OVA that is put in a S3 bucket"
  runtime          = "python2.7"
  timeout          = "60"
}

resource "aws_lambda_function" "CheckImport" {
  function_name    = "CheckImport"
  s3_bucket        = "${var.bucket_lambda}"
  s3_key           = "check_import_status.zip"
  role             = "${aws_iam_role.vmielambda.arn}"
  handler          = "check_import_status.lambda_handler"
  description      = "Check VM import every 30 min to report on competion"
  runtime          = "python2.7"
  timeout          = "60"
}

resource "aws_cloudwatch_event_rule" "CheckImportRule" {
  name                = "CheckImportRule"
  schedule_expression = "cron(0/30 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "CheckImportRule" {
  target_id = "vmie_status_check"
  arn       = "${aws_lambda_function.CheckImport.arn}"
  rule      = "${aws_cloudwatch_event_rule.CheckImportRule.name}"
}

resource "aws_lambda_permission" "allow_checkimport" {
  statement_id   = "AllowCheckImport"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.CheckImport.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.CheckImportRule.arn}"
}

resource "aws_lambda_permission" "allow_importova" {
  statement_id   = "AllowImportOVA"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.ImportOva.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_s3_bucket.bucket_import.arn}"
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket_import.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.ImportOva.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".ova"
  }
}
