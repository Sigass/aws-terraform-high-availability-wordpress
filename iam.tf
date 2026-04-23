data "aws_iam_policy_document" "wordpress_ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "wordpress_s3_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [data.aws_s3_bucket.wordpress_storage.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${data.aws_s3_bucket.wordpress_storage.arn}/*"]
  }
}

# IAM Instance Profile for EC2 (WordPress S3 access example)
resource "aws_iam_role" "wordpress_ec2_role" {
  name = "wordpress-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "wordpress_s3_policy" {
  name = "wordpress-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "wordpress_s3_attach" {
  role       = aws_iam_role.wordpress_ec2_role.name
  policy_arn = aws_iam_policy.wordpress_s3_policy.arn
}

resource "aws_iam_instance_profile" "wordpress_ec2_profile" {
  name = "wordpress-ec2-profile"
  role = aws_iam_role.wordpress_ec2_role.name
}