variable "s3_bucket_name" {
  default = "input-bucket"
}

variable "output_s3_bucket_name" {
  default = "output-bucket"
}

variable "sqs_queue_name" {
  default = "my-queue"
}

variable "lambda1_handler" {
  default = "com.ibm.cloud.eventprocessor.s3tosqs.handler.S3Handler::handleRequest"
}

variable "lambda2_handler" {
  default = "com.ibm.cloud.eventprocessor.sqstos3.handler.SqsHandler::handleRequest"
}