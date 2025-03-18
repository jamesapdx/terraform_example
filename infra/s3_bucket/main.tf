resource "aws_s3_bucket" "s3_bucket" {
  bucket = "jamesa_s3_bucket"
  force_destroy =  true
  tags = {
    Name = "S3 Bucket"
  }
}