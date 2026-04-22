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

resource "aws_iam_role" "wordpress_ec2_role" {
  count              = var.enable_wordpress_s3_iam_resources ? 1 : 0
  name               = "wordpress-ec2-s3-role"
  assume_role_policy = data.aws_iam_policy_document.wordpress_ec2_assume_role.json
}

resource "aws_iam_policy" "wordpress_s3_access" {
  count  = var.enable_wordpress_s3_iam_resources ? 1 : 0
  name   = "wordpress-s3-access"
  policy = data.aws_iam_policy_document.wordpress_s3_access.json
}

resource "aws_iam_role_policy_attachment" "wordpress_s3_access" {
  count      = var.enable_wordpress_s3_iam_resources ? 1 : 0
  role       = aws_iam_role.wordpress_ec2_role[0].name
  policy_arn = aws_iam_policy.wordpress_s3_access[0].arn
}

resource "aws_iam_instance_profile" "wordpress_ec2_profile" {
  count = var.enable_wordpress_s3_iam_resources ? 1 : 0
  name  = "wordpress-ec2-profile"
  role  = aws_iam_role.wordpress_ec2_role[0].name
}