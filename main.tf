# -------------------------------------------------- 
# S3 bucket creation
# -------------------------------------------------- 

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

  tags = {
    Name        = var.project
  }
}

# -------------------------------------------------- 
# Acl website permission
# -------------------------------------------------- 

resource "aws_s3_bucket_acl" "bucketacl" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"
}

# -------------------------------------------------- 
# Acl website permission
# -------------------------------------------------- 

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

}

# # -------------------------------------------------- 
# # Website configration 
# # -------------------------------------------------- 

# resource "aws_s3_bucket_website_configuration" "website" {
#   bucket = aws_s3_bucket.mybucket.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }

# }

# -------------------------------------------------- 
# Website uploading files
# -------------------------------------------------- 

resource "aws_s3_object" "object" {
for_each = fileset("myfiles/", "**")
bucket = aws_s3_bucket.mybucket.id
key = each.value
source = "myfiles/${each.value}"
etag = filemd5("myfiles/${each.value}")
content_type = lookup(tomap(var.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
}

# -------------------------------------------------- 
# Adding-records
# -------------------------------------------------- 

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

# -------------------------------------------------- 
# Creating could front distribution for s3 static website
# -------------------------------------------------- 

locals {
  
  s3_origin_id = "s3.ap-south-1.amazonaws.com"
}

resource "aws_cloudfront_origin_access_identity" "bucketoai" {
  comment = "Neww_access"
}

resource "aws_cloudfront_distribution" "website_cdnnew" {
  origin {
    domain_name = aws_s3_bucket.mybucket.bucket_regional_domain_name
    origin_id   = "${aws_s3_bucket.mybucket.id}-locals.s3_origin_id"
    
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


