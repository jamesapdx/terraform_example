resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "jamesa-s3-bucket"
  force_destroy = true
  tags = {
    Name = "s3-bucket"
  }
}