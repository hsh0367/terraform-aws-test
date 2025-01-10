provider "aws" {
	region = var.region
  access_key = var.access_key
  secret_key = var.secret_key 
}

# s3 버킷 생성하기
resource "aws_s3_bucket" "new_bucket" {
  bucket = var.bucket_name
  tags = {
    Environment = var.environment
  }
}

# Todo: 버킷 acl 구성 및 정책 추가
# Todo: 태그로 연결된 iam user 생성 및 지정된 정책 arn 연결

# # 버킷에 대한 public access block 구성을 변경해준다.
# resource "aws_s3_bucket_public_access_block" "public-access" {
#   bucket = aws_s3_bucket.new_bucket.id
#   block_public_acls = false
#   block_public_policy = false
#   ignore_public_acls = false
#   restrict_public_buckets = false
# }


# resource "aws_s3_bucket_policy" "bucket-policy" {
#   bucket = aws_s3_bucket.new_bucket.id
#   depends_on = [ 
#     aws_s3_bucket_public_access_block.public-access
#   ]
#   policy = var.bucket_policy
# }


resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  bucket = aws_s3_bucket.new_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "HEAD",
      "GET",
      "PUT",
      "POST",
      "DELETE"
    ]
    allowed_origins = [
      var.cors_allowed_origin
    ]
    expose_headers = [
      "ETag",
      "x-amz-meta-custom-header"
    ]
    max_age_seconds = 3000
  }
}