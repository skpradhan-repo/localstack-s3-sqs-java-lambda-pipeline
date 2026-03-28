package com.samsoft.cloud.eventprocessor.sqstos3.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.net.URI;
import java.nio.charset.StandardCharsets;

public class SqsHandler implements RequestHandler<SQSEvent, String> {

    private final S3Client s3Client;
    private final String outputBucket;

    public SqsHandler() {
        // Read endpoint from environment variable, fallback to container hostname
        String endpoint = "http://10.89.0.2:4566";
        if (endpoint == null || endpoint.isEmpty()) {
            endpoint = "http://localhost:4566"; // Podman container hostname
        }

        this.s3Client = S3Client.builder()
                .endpointOverride(URI.create(endpoint))
                .region(Region.US_EAST_1)
                .forcePathStyle(true) // Required for LocalStack
                .build();

        this.outputBucket = System.getenv("OUTPUT_BUCKET") != null
                ? System.getenv("OUTPUT_BUCKET")
                : "output-bucket";

        // Log initialization
        System.out.println("S3 client initialized with endpoint: " + endpoint);
        System.out.println("Output bucket: " + this.outputBucket);
    }

    @Override
    public String handleRequest(SQSEvent event, Context context) {
        context.getLogger().log("\n=== START PROCESSING SQS BATCH ===");
        context.getLogger().log("Number of messages in batch: " + event.getRecords().size());

        for (SQSEvent.SQSMessage msg : event.getRecords()) {
            try {
                String body = msg.getBody();
                String key = "processed-" + System.currentTimeMillis() + ".txt";

                context.getLogger().log("Received SQS message body: " + body);
                context.getLogger().log("Writing to S3 bucket: " + outputBucket + ", key: " + key);

                // Put object in S3
                s3Client.putObject(
                        PutObjectRequest.builder()
                                .bucket(outputBucket)
                                .key(key)
                                .build(),
                        RequestBody.fromString(body, StandardCharsets.UTF_8)
                );

                context.getLogger().log("✅ Successfully wrote object: " + key);

            } catch (Exception e) {
                context.getLogger().log("❌ ERROR processing message: " + e.toString());
                for (StackTraceElement element : e.getStackTrace()) {
                    context.getLogger().log(element.toString());
                }

                // Re-throw so SQS retries
                throw new RuntimeException("Failed to process SQS message", e);
            }
        }

        context.getLogger().log("=== FINISHED PROCESSING SQS BATCH ===\n");
        return "Successfully written all messages to S3";
    }
}