data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "wordpress_storage_public_read" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.wordpress_storage.arn}/*"]
  }
}

resource "aws_s3_bucket" "wordpress_storage" {
  bucket = "wordpress-storage-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "wordpress-storage"
  }
}

resource "aws_s3_bucket_versioning" "wordpress_storage" {
  bucket = aws_s3_bucket.wordpress_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "wordpress_storage" {
  bucket = aws_s3_bucket.wordpress_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "wordpress_storage" {
  bucket = aws_s3_bucket.wordpress_storage.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "wordpress_storage_public_read" {
  bucket = aws_s3_bucket.wordpress_storage.id
  policy = data.aws_iam_policy_document.wordpress_storage_public_read.json
}