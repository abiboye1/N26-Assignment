###############################################################################
# GuardDuty
###############################################################################
resource "aws_guardduty_detector" "gd" {
  enable = true

  tags = {
    Name = "n26-guardduty"
  }
}

###############################################################################
# Macie
###############################################################################
resource "aws_macie2_account" "macie" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# If you want Macie to specifically monitor the S3 logs, you can configure Macie
# to classify data in a given S3 bucket, but that can be advanced usage.

###############################################################################
# CloudTrail
###############################################################################
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket = "n26-trail-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "trail_bucket_pab" {
  bucket                  = aws_s3_bucket.trail_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail_bucket_sse" {
  bucket = aws_s3_bucket.trail_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "trail_bucket_policy" {
  bucket = aws_s3_bucket.trail_bucket.bucket

  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

resource "aws_cloudtrail" "main_trail" {
  name                          = "n26-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  

  event_selector {
    read_write_type = "All"
  }

  tags = {
    Name = "n26-cloudtrail"
  }
}


