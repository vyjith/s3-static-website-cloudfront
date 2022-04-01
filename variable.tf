variable "region" {}


variable "access_key" {}

variable "secret_key" {}


variable "project" {

    default = "bucket"
  
}

variable "bucketname" {

  default = "s3neww.vyjithks.tk"
  
}

variable "mime_types" {
  default = {
    htm   = "text/html"
    html  = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    json  = "application/json"
    png	  = "image/png"
    jpg  = "image/jpeg"    
    woff2 = "font/woff2" 
    woff  = "font/woff"
    eot	  = "application/vnd.ms-fontobject" 
    js	  = "text/javascript"
    otf   = "font/otf"
    svg   = "image/svg+xml"
    txt   = "text/plain"
 }
}
 
 variable "default_root" {

   default = "index.html"
   
 }

 variable "price" {

   default = "PriceClass_200"
   
 }

 variable "acmarn" {

   default = "arn:aws:acm:us-east-1:370200737204:certificate/7423ac28-40cf-42bc-b322-90db06fd95fb"
   
 }
