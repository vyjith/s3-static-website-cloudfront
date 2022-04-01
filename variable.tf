variable "region" {

  default = "ap-south-1"
}


variable "access_key" {

  default = "AKIAVMMNO6W2N5ZQGAUT"
}

variable "secret_key" {

  default = "s5l4plsmcZh/7myOH0+ce6cItkX+bP4zm6NeMGde"
}


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