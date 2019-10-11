resource "aws_s3_bucket" "bcam" {
  bucket = "bcam-prod"
  acl = "private"
  versioning {
    enabled = true
  }

  tags = {
    Name = "bcam-prod"
  
  }
}