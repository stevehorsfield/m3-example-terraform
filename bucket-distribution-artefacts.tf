resource "aws_s3_bucket" "distribution-artefacts" {
  bucket = "${var.environment}-distribution-artefacts-${data.aws_region.this.name}"
  acl    = "private"

  tags {
    Name        = "${var.environment}-distribution-artefacts"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_public_access_block" "distribution-artefacts" {
  bucket = "${aws_s3_bucket.distribution-artefacts.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}