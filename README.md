# localstack-s3-sqs-java-lambda-pipeline
A complete, **production-grade event-driven architecture** demonstrating a fully decoupled serverless data processing pipeline:  **S3 (Input) → Java Lambda → SQS → Java Lambda → S3 (Output)**  Built with **Terraform**, **AWS Lambda (Java 17)**, **AWS SDK v2**, and **LocalStack** 

This project demonstrates a fully local, event‑driven pipeline using:

AWS LocalStack (S3, SQS, Lambda)
Terraform for Infrastructure as Code
Java (Lambda functions) for event processing

The flow:
S3 (input-bucket) ➝ Lambda #1 ➝ SQS ➝ Lambda #2 ➝ S3 (OUTPUT-BUCKET)

 1. Start LocalStack
Before deploying infrastructure, ensure LocalStack is running. ( refer localstack-script.txt)

2. Deploy Infra Using Terraform
Move into the infrastructure/ folder:
	terraform init
	
	terraform validate

	terraform plan

	terraform apply -auto-approve

This will create:

input-bucket
output-bucket
SQS queue
Lambda #1 (S3 → SQS)
Lambda #2 (SQS → S3)
Event notification + triggers

3. Test Using Postman (Upload File to S3)

Use Postman → PUT request to upload a file to your S3 bucket.
	Example pre‑created sample.txt.

	PUT Request Format
		PUT/POST http://localhost:4566/input-bucket/sample.txt
			In Postman:

			Set Body → binary → sample.txt
	Send the request

4. What Happens After Upload

	✔ S3 triggers Lambda #1
	✔ Lambda publishes to SQS
	✔ SQS triggers Lambda #2
	✔ Lambda #2 writes processed file to OUTPUT bucket

5. Destroy Resources (Cleanup)

	terraform destroy -auto-approve

6. Troubleshooting
	Refer to troubleshoot.txt in the root folder.

**Project Structure**

<img width="266" height="301" alt="image" src="https://github.com/user-attachments/assets/1e3b4c30-876a-4aa2-9c4b-8e3bdd7cd713" />

