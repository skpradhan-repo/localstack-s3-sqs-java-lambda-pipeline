# -----------------------------
# S3 Buckets
# -----------------------------

resource "aws_s3_bucket" "input_bucket" {
  bucket = lower(var.s3_bucket_name)
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = lower(var.output_s3_bucket_name)
}

# -----------------------------
# SQS Queue
# -----------------------------

resource "aws_sqs_queue" "my_queue" {
  name = var.sqs_queue_name
}

# -----------------------------
# IAM Role
# -----------------------------

resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# -----------------------------
# IAM Policy
# -----------------------------

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # S3 Read (input)
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.input_bucket.arn}/*"
      },

      # S3 Write (output)
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.output_bucket.arn}/*"
      },

      # SQS Send
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.my_queue.arn
      },

      # SQS Consume
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.my_queue.arn
      },

      # Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# Lambda #1 (S3 → SQS)
# -----------------------------

resource "aws_lambda_function" "s3_to_sqs_lambda" {
  function_name = "s3-to-sqs-java"
  handler       = var.lambda1_handler
  runtime       = "java17"

  filename         = "${path.module}/lambda/build/s3tosqs-0.0.1-SNAPSHOT.jar"
  source_code_hash = filebase64sha256("${path.module}/lambda/build/s3tosqs-0.0.1-SNAPSHOT.jar")

  role = aws_iam_role.lambda_role.arn
}

# -----------------------------
# Lambda #2 (SQS → S3)
# -----------------------------

resource "aws_lambda_function" "sqs_to_s3_lambda" {
  function_name = "sqs-to-s3-java"
  handler       = var.lambda2_handler
  runtime       = "java17"

  filename         = "${path.module}/lambda2/build/sqstos3-0.0.1-SNAPSHOT.jar"
  source_code_hash = filebase64sha256("${path.module}/lambda2/build/sqstos3-0.0.1-SNAPSHOT.jar")

  role = aws_iam_role.lambda_role.arn
}

# -----------------------------
# Allow S3 → Lambda
# -----------------------------

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_sqs_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# -----------------------------
# S3 Notification
# -----------------------------

resource "aws_s3_bucket_notification" "s3_event" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_sqs_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# -----------------------------
# SQS → Lambda Trigger
# -----------------------------

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.my_queue.arn
  function_name    = aws_lambda_function.sqs_to_s3_lambda.arn
  batch_size       = 1
}