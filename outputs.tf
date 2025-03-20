output "aws_instance_ip1" {
    description = "IPs of instance 1"
    value = module.infra_aws_instance.aws_instance_ip1
}

output "aws_instance_ip2" {
    description = "IPs of instance 2"
    value = module.infra_aws_instance.aws_instance_ip2
}

output "s3_bucket_name" {
    description = "Name of s3 bucket"
    value = module.infra_s3_bucket.s3_bucket_name
}
output "s3_bucket_arn" {
    description = "ARN of the S3 bucket"
    value = module.infra_s3_bucket.s3_bucket_arn
}
