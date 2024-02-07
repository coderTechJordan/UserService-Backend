package com.example.CreateUser;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.example.UserService.UserService;
import com.example.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;

public class LambdaHandler implements RequestStreamHandler {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final UserService userService = new UserService();
    private LambdaLogger logger;

    @Override
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {
        logger = context.getLogger(); // Assign logger here

        try {
            logger.log("Handling CreateUser Lambda request");

            AwsProxyRequest request = objectMapper.readValue(inputStream, AwsProxyRequest.class);
            logger.log("Received request: " + objectMapper.writeValueAsString(request));

            String requestBody = request.getBody();
            User user = objectMapper.readValue(requestBody, User.class);
            logger.log("Creating user: " + user.toString());
            User createdUser = userService.createUser(user);

            String responseBody = objectMapper.writeValueAsString(createdUser);
            writeResponse(outputStream, responseBody);

            logger.log("CreateUser Lambda execution completed");
        } catch (IOException e) {
            logger.log("Error handling CreateUser Lambda request: " + e.getMessage());
            writeErrorResponse(outputStream, "Error processing request: Input/output issue");
        } catch (Exception e) {
            logger.log("Error handling CreateUser Lambda request: " + e.getMessage());
            writeErrorResponse(outputStream, "Error processing request: Unexpected error occurred");
        }
    }

    private void writeErrorResponse(OutputStream outputStream, String errorMessage) throws IOException {
        AwsProxyResponse errorResponse = new AwsProxyResponse(400, null, errorMessage);
        objectMapper.writeValue(outputStream, errorResponse);
    }

    private void writeResponse(OutputStream outputStream, String responseBody) throws IOException {
        AwsProxyResponse response = new AwsProxyResponse(200, null, responseBody);
        objectMapper.writeValue(outputStream, response);
    }
}
