output "s3_bucket_name" {
  description = "Name of created S3 bucket"
  value = aws_s3_bucket.s3_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of created S3 bucket"
  value = aws_s3_bucket.s3_bucket.arn
}