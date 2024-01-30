package com.example.UserService;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;

import java.io.*;

import com.amazonaws.services.lambda.runtime.LambdaLogger;

public class LambdaHandler implements RequestStreamHandler {

    private static final SpringBootLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;

    static {
        try {
            handler = SpringBootLambdaContainerHandler.getAwsProxyHandler(UserServiceApplication.class);
        } catch (ContainerInitializationException e) {
            // Handle initialization error
            throw new RuntimeException("Could not initialize Spring Boot application", e);
        }
    }

    @Override
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {
        LambdaLogger logger = context.getLogger();
        try {
            logger.log("Handling Lambda request");

            ByteArrayOutputStream proxyOutputStream = new ByteArrayOutputStream();
            handler.proxyStream(inputStream, proxyOutputStream, context);
            byte[] responseBytes = proxyOutputStream.toByteArray();

            logRequest(inputStream, logger);

            outputStream.write(responseBytes);
        } catch (IOException e) {

            logger.log("Error handling Lambda request: " + e.getMessage());
            outputStream.write("Error processing request: Input/output issue".getBytes());
        } catch (Exception e) {
            logger.log("Error handling Lambda request: " + e.getMessage());
            outputStream.write("Error processing request: Unexpected error occurred".getBytes());
        } finally {
            logger.log("Lambda execution completed");
            outputStream.close();
        }
    }


    private void logRequest(InputStream inputStream, LambdaLogger logger) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        StringBuilder requestPayload = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            requestPayload.append(line).append("\n");
        }
        logger.log("Incoming request payload:\n" + requestPayload.toString());
    }
}
