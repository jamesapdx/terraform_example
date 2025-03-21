variable "env" {
  description = "Environment"
  type        = string
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "jamesa-s3-bucket-${var.env}"
  force_destroy = true
  tags = {
    Name = "s3-bucket-${var.env}"
  }
}