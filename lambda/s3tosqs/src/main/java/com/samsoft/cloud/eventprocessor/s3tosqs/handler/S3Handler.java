package com.samsoft.cloud.eventprocessor.s3tosqs.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.S3Event;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

public class S3Handler implements RequestHandler<S3Event, String> {

    private final SqsClient sqsClient = SqsClient.builder()
            .endpointOverride(java.net.URI.create("http://10.89.0.2:4566"))
            .region(software.amazon.awssdk.regions.Region.US_EAST_1)
            .build();

    private final String queueUrl = "http://10.89.0.2:4566/000000000000/my-queue";

    @Override
    public String handleRequest(S3Event event, Context context) {

        event.getRecords().forEach(record -> {
            String bucket = record.getS3().getBucket().getName();
            String key = record.getS3().getObject().getKey();

            String message = bucket + ":" + key;

            sqsClient.sendMessage(SendMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .messageBody(message)
                    .build());
        });

        return "Message sent to SQS";
    }
}