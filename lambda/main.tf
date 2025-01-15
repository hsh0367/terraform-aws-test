provider aws {
  region = var.region
  profile = var.profile
}

resource "aws_s3_bucket" "lambda_test_bucket" {
  bucket = var.bucket_name
  tags = {
    id_env = var.id_env
    id_cat = var.id_cat
    id_group = var.id_group
    id_service = var.id_service
  }
}


data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/hello-world.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_test_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_test_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs20.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "terraform_lambda_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
  tags = {
    id_env = var.id_env
    id_cat = var.id_cat
    id_group = var.id_group
    id_service = var.id_service
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
