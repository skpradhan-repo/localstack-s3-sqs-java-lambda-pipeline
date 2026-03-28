# localstack-s3-sqs-java-lambda-pipeline
A complete, **production-grade event-driven architecture** demonstrating a fully decoupled serverless data processing pipeline:  **S3 (Input) → Java Lambda → SQS → Java Lambda → S3 (Output)**  Built with **Terraform**, **AWS Lambda (Java 17)**, **AWS SDK v2**, and **LocalStack** 

**Project Structure**
localstack-s3-sqs-java-lambda-pipeline/
├── infrastructure/                 # Terraform code
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── lambda/                     # Built JARs (Terraform will reference from here or ../)
│       ├── build/
│       │   └── s3tosqs-0.0.1-SNAPSHOT.jar
│       └── build2/
│           └── sqstos3-0.0.1-SNAPSHOT.jar
│
├── lambda/                         # Java Spring boot - S3 to SQS Lambda
│   ├── pom.xml..
│   └── src/main/java/.../S3Handler.java
│
├── lambda2/                        # Java Spring boot - SQS to S3 Lambda
│   ├── pom.xml..
│   └── src/main/java/.../SqsHandler.java 
│
├── .gitignore
└── README.md

<img width="266" height="301" alt="image" src="https://github.com/user-attachments/assets/1e3b4c30-876a-4aa2-9c4b-8e3bdd7cd713" />

