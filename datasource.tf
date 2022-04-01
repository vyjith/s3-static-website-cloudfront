data "template_file" "bucketpolicy"{

    template = "${file("bucketpolicy.json")}"
}

data "template_file" "bucketpolicyuser"{

    template = "${file("deployer.json")}"
}

data "aws_route53_zone" "selected" {
  name         = "vyjithks.tk."
  private_zone = false
}

# output "zone" {

# value = data.aws_route53_zone.selected.id

# }

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
