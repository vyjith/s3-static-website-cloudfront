# Creating s3 bucket and cloudfront using terraform to host a static website
-------------------------------------------------- 

# Description
-------------------------------------------------- 

For a long time, s3 has been an excellent choice for hosting static websites, but it's still a hassle to set up manually, To establish and manage users, buckets, certificates, a CDN, and roughly a hundred additional configuration choices, you must navigate through dozens of pages in the AWS console, it quickly becomes tiresome if you do this repeatedly. Terraform, a well-known "Infrastructure as code" tool, allows us to create resources (such as instances, storage buckets, users, rules, and DNS records)

## S3 static website Infrastructure
-------------------------------------------------- 

Hosting a static website on S3 only requires a few components. This setup creates the following resources:

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

```
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "bucketname" {}
variable "default_root" {}
variable "price" {}
variable "acmarn" {}
```
