package com.example.UserService;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.example.UserService.model.User;
import com.example.UserService.service.UserService;
import com.fasterxml.jackson.core.JsonProcessingException;
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
            logger.log("Handling Lambda request");

            AwsProxyRequest request = objectMapper.readValue(inputStream, AwsProxyRequest.class);
            logger.log("Received request: " + objectMapper.writeValueAsString(request));

            String path = request.getRequestContext().getPath();
            logger.log("Request path: " + path);

            if (path != null && !path.isEmpty()) {
                String[] pathSegments = path.split("/");
                String operation = pathSegments[pathSegments.length - 1];
                String httpMethod = request.getRequestContext().getHttpMethod();
                String responseBody;

                Map<String, String> pathParameters = request.getPathParameters();
                switch (httpMethod) {
                    case "POST":
                        if (operation.equals("users")) {
                            responseBody = createUser(request.getBody());
                        } else {
                            responseBody = "Unsupported operation for POST method: " + operation;
                        }
                        break;
                    case "GET":
                        if (pathParameters != null && pathParameters.containsKey("userId")) {
                            String userId = pathParameters.get("userId");
                            logger.log("User ID from pathParameters: " + userId);
                            User user = userService.getUserById(userId);
                            if (user != null) {
                                logger.log("User found: " + user.toString());
                                responseBody = objectMapper.writeValueAsString(user);
                            } else {
                                logger.log("User not found for ID: " + userId);
                                responseBody = "{\"error\": \"User not found\"}";
                            }
                        } else {
                            logger.log("No userId provided in pathParameters, retrieving all users");
                            responseBody = listUsers();
                        }
                        break;
                    case "DELETE":
                        if (pathParameters != null && pathParameters.containsKey("userId")) {
                            String userId = pathParameters.get("userId");
                            logger.log("Deleting user with ID: " + userId);
                            deleteUser(userId);
                            responseBody = "User with ID " + userId + " deleted successfully";
                        } else {
                            responseBody = "No userId provided in pathParameters for deletion";
                        }
                        break;
                    default:
                        responseBody = "Unsupported HTTP method: " + httpMethod;
                }

                writeResponse(outputStream, responseBody);
                logger.log("Lambda execution completed");
            } else {
                writeErrorResponse(outputStream, "Error: Invalid request path");
            }
        } catch (IOException e) {
            logger.log("Error handling Lambda request: " + e.getMessage());
            writeErrorResponse(outputStream, "Error processing request: Input/output issue");
        } catch (Exception e) {
            logger.log("Error handling Lambda request: " + e.getMessage());
            writeErrorResponse(outputStream, "Error processing request: Unexpected error occurred");
        }
    }

    private String createUser(String requestBody) throws JsonProcessingException {
        User user = objectMapper.readValue(requestBody, User.class);
        User createdUser = userService.createUser(user);
        return objectMapper.writeValueAsString(createdUser);
    }

    private String listUsers() throws JsonProcessingException {
        List<User> userList = userService.listUsers();
        return objectMapper.writeValueAsString(userList);
    }

    private void deleteUser(String userId) {
        try {
            userService.deleteUser(userId);
            logger.log("User deleted with ID: " + userId);
        } catch (Exception e) {
            logger.log("Error deleting user: " + e.getMessage());
            throw new RuntimeException("Error deleting user", e);
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