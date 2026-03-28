output "input_bucket" {
  value = aws_s3_bucket.input_bucket.id
}

output "output_bucket" {
  value = aws_s3_bucket.output_bucket.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.my_queue.id
}

output "lambda1_name" {
  value = aws_lambda_function.s3_to_sqs_lambda.function_name
}

output "lambda2_name" {
  value = aws_lambda_function.sqs_to_s3_lambda.function_name
}