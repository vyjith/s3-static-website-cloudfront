
output "s3-website-endpont" {

    value = aws_s3_bucket.mybucket.website_endpoint
  
}
output "s3-acl" {


    value = aws_s3_bucket.mybucket.acl

}

output "s3-bukcet-arn" {


    value = aws_s3_bucket.mybucket.arn

}

output "cloudfront-url" {

    value = "https://${aws_route53_record.cloudfront.name}"
  
}

