package com.example.UserService.dynamodb;

import com.example.UserService.model.User;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.dynamodb.model.ScanResponse;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class GetAllUsers {

    public static List<User> execute(String[] args) {
        final String usage = """

            Usage:
                <tableName> <userId>

            Where:
                tableName - The Amazon DynamoDB table from which user items are retrieved (for example, Users).\s
                userId - The unique identifier of the user to retrieve.
            """;
        if (args.length != 1) {
            System.out.println(usage);
            System.exit(1);
        }

        String tableName = args[0];
        System.out.println("Querying all users from table: " + tableName);
        // Set up your DynamoDB client and region
        Region region = Region.US_EAST_2;
        DynamoDbClient ddb = DynamoDbClient.builder()
                .region(region)
                .build();

        // Call the method to query all user items from DynamoDB
        return getAllUserItemsFromDynamoDB(ddb, tableName);
    }

    public static List<User> getAllUserItemsFromDynamoDB(DynamoDbClient ddb, String tableName) {
        List<User> userList = new ArrayList<>();

        ScanRequest scanRequest = ScanRequest.builder()
                .tableName(tableName)
                .build();

        try {
            ScanResponse response = ddb.scan(scanRequest);
            List<Map<String, AttributeValue>> items = response.items();

            for (Map<String, AttributeValue> item : items) {
                // Construct User object for each item and add to the userList
                userList.add(mapToUser(item));
            }

            return userList;
        } catch (DynamoDbException e) {
            System.err.println(e.getMessage());
            // Handle the exception according to your application's requirements
            return null;
        }
    }

    private static User mapToUser(Map<String, AttributeValue> item) {
        String userId = item.containsKey("userId") ? item.get("userId").s() : null;
        String firstName = item.containsKey("firstName") ? item.get("firstName").s() : null;
        String lastName = item.containsKey("lastName") ? item.get("lastName").s() : null;
        String username = item.containsKey("username") ? item.get("username").s() : null;
        String password = item.containsKey("password") ? item.get("password").s() : null;
        String email = item.containsKey("email") ? item.get("email").s() : null;
        String createdAt = item.containsKey("createdAt") ? item.get("createdAt").s() : null;

        return new User(userId, firstName, lastName, username, password, email, createdAt);
    }
}