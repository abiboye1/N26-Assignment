data "aws_caller_identity" "current" {}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AWSCloudTrailAclCheck20150319"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [aws_s3_bucket.trail_bucket.arn]
  }

  statement {
    sid       = "AWSCloudTrailWrite20150319"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [
      "${aws_s3_bucket.trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid       = "AWSCloudTrailBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [aws_s3_bucket.trail_bucket.arn]
  }
}



data "template_file" "userdata" {
  template = <<-EOF
  #!/bin/bash
  # For Amazon Linux 2:
  yum install -y ec2-instance-connect
  EOF
}

resource "aws_launch_template" "my_lt" {
  # ...
  user_data = base64encode(data.template_file.userdata.rendered)
  # ...
}
