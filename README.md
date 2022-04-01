# Creating s3 bucket and cloudfront using terraform to host a static website
-------------------------------------------------- 

[![Builds](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

# Description
-------------------------------------------------- 

For a long time, s3 has been an excellent choice for hosting static websites, but it's still a hassle to set up manually, To establish and manage users, buckets, certificates, a CDN, and roughly a hundred additional configuration choices, you must navigate through dozens of pages in the AWS console, it quickly becomes tiresome if you do this repeatedly. Terraform, a well-known "Infrastructure as code" tool, allows us to create resources (such as instances, storage buckets, users, rules, and DNS records)

## S3 static website Infrastructure
-------------------------------------------------- 

Hosting a static website on S3 only requires a few components. This setup creates the following resources:


![](https://i.ibb.co/3kj44G7/s3cloudfront-drawio.png)

* S3 bucket for the website files
* Cloudfront distribution as CDN
* Route53 records for the given domain


## Prerequisites
-------------------------------------------------- 

Before we get started you are going to need so basics:

* [Basic knowledge of Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Terraform installed](https://www.terraform.io/downloads)
* [Valid AWS IAM user credentials with required access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
* [A purchased domain](https://mailchimp.com/resources/how-to-buy-a-domain-name/)

## Installation

If you need to download terraform , then click here [Terraform](https://www.terraform.io/downloads) .

Lets create a file for declaring the variables.This is used to declare the variable and the values are passing through the terrafrom.tfvars file.

## Create a varriable.tf file

```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "bucketname" {}
variable "default_root" {}
variable "price" {}
variable "acmarn" {}
```

## Create a provider.tf file

```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

## Create a terraform.tfvars file

```sh
region = "Put-your-region-here"
access_key = "Put-your-access_key-here"
secret_key = "Put-your-secretkey-here"
project = "name-of-your-project"
bucketname = "put-your-bucket-name-here"
default_root = "Put-your-defaut-root-here"
price = "Put-your-price-deatils-here"
acmarn = "put-your-acm-arn-here" 
```
**Go to the directory that you wish to save your tfstate files.Then Initialize the working directory containing Terraform configuration files using below command.**
```
terraform init
```
**Lets start with main.tf file, the details are below**
> To creat s3 bukcet
```sh
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

  tags = {
    Name        = var.project
  }
}
```

> To create an acl permission for the created bukcet
```sh
resource "aws_s3_bucket_acl" "bucketacl" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"
}
```

> Gather the policy for the bucket
```sh
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.mybucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bucketoai.iam_arn]
    }
  }
}
```
>  To attach the policy to the bucket
```sh
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
```

>  To upload the website file

```sh
resource "aws_s3_object" "object" {
for_each = fileset("myfiles/", "**")
bucket = aws_s3_bucket.mybucket.id
key = each.value
source = "${/path}/${each.value}"
etag = filemd5("${/path}/${each.value}")
content_type = lookup(tomap(var.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
}
```

> Gather zone ID of my domain from route 53
```sh
data "aws_route53_zone" "selected" {
  name         = "domain.com."
  private_zone = false
}
```

> To creata an alias record for the cloud front

```sh
resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "${var.project}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name    =  aws_cloudfront_distribution.website_cdnnew.domain_name
    zone_id = "${aws_cloudfront_distribution.website_cdnnew.hosted_zone_id}"
    evaluate_target_health = false
  }
}
```

> To create cloudfront for my bucket
```sh
locals {
  
  s3_origin_id = "s3.ap-south-1.amazonaws.com"
}

resource "aws_cloudfront_origin_access_identity" "bucketoai" {
  comment = "Neww_access"
}

resource "aws_cloudfront_distribution" "website_cdnnew" {
  origin {
    domain_name = aws_s3_bucket.mybucket.bucket_regional_domain_name
    origin_id   = "${aws_s3_bucket.mybucket.id}-local.s3_origin_id"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bucketoai.cloudfront_access_identity_path
    }
  }
  aliases = ["${var.project}.${data.aws_route53_zone.selected.name}"]

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = var.default_root
  http_version = "http2"
  price_class = var.price
    

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.mybucket.id}-locals.s3_origin_id"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
    compress               = true

    viewer_protocol_policy = "redirect-to-https"

  }
  restrictions {
    geo_restriction {
      
      restriction_type = "none"

    }
  }
  viewer_certificate {
    acm_certificate_arn = var.acmarn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"

  }
}

```
## Create an output.tf for getting terrafrom output.

```sh
output "s3-website-endpont" {

    value = aws_s3_bucket.mybucket.website_endpoint
  
}

output "s3-bukcet-arn" {


    value = aws_s3_bucket.mybucket.arn

}

output "cloudfront-url" {

    value = "https://${aws_route53_record.cloudfront.name}"
  
}
```
Lets validate the terraform files using

```
terraform validate
```

Lets plan the architecture and verify once again

```
terraform plan
```

Lets apply the above architecture to the AWS.

```
terraform apply
```
## Conclusion

This is a simple static s3 website and cloudfront using terraform. Please contact me when you encounter any difficulty error while using this terrform code. Thank you!

### ⚙️ Connect with Me
<p align="center">
<a href="https://www.instagram.com/iamvyjith/"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/vyjith-ks-3bb8b7173/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a>

