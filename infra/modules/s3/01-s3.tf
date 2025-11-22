data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket" "this" {
  bucket = "${var.env}-${var.project}-${var.bucket_name}"

  tags = {
    Name = "${var.env}-${var.project}-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.this.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { "AWS" : data.aws_elb_service_account.this.arn },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_acl.this,
    aws_s3_bucket_logging.this,
  ]
}
